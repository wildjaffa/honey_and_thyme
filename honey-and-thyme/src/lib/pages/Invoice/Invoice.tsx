import { useState } from "react";
import { useParams } from "react-router";
import { PayPalScriptProvider, PayPalButtons } from "@paypal/react-paypal-js";
import useInvoice from "../../hooks/useInvoice";
import { HoneyButton, HoneyInput, HoneyPageLoader } from "../../components";
import apiClient from "../../api/client";
import type {
  CreatePaymentRequest,
  CreatePaymentResponse,
} from "../../types/api";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCreditCard,
  faSquareCheck,
  faTriangleExclamation,
} from "@fortawesome/free-solid-svg-icons";
import PaymentProcessor from "../../enums/paymentProcessor";

const InvoiceStatus = {
  selecting: 0,
  payingDeposit: 1,
  payingTotal: 2,
  creatingOrder: 3,
  acceptingInput: 4,
  capturing: 5,
  error: 6,
  success: 7,
  declined: 8,
};

// Define a type for the status values
type InvoiceStatusType = (typeof InvoiceStatus)[keyof typeof InvoiceStatus];

function Invoice() {
  const { reservationCode } = useParams();
  const {
    data: photoShoot,
    isLoading,
    isError,
    refetch,
  } = useInvoice(reservationCode);
  const [status, setStatus] = useState<InvoiceStatusType>(
    InvoiceStatus.selecting,
  );
  const [amountToBePaid, setAmountToBePaid] = useState(0);
  const [tip, setTip] = useState(0);
  const [errorString, setErrorString] = useState("");
  const [order, setOrder] = useState<CreatePaymentResponse | null>(null);

  const createPaymentMutation = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/createPayment",
  );
  const capturePaymentMutation = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/capturePayment",
  );

  const onError = (error: unknown) => {
    console.error("PayPal error", error);
    setStatus(InvoiceStatus.error);
    setErrorString("An unexpected error occurred with PayPal.");
  };

  const onApprove = async (data: { orderID: string }) => {
    console.log("PayPal approved", data);
    if (!order) {
      setStatus(InvoiceStatus.declined);
      setErrorString(
        "There was an issue communicating with PayPal, but your card was not charged. Please try again.",
      );
      return;
    }
    setStatus(InvoiceStatus.capturing);

    try {
      const response = await capturePaymentMutation.mutateAsync({
        body: {
          amountToBeCharged: amountToBePaid,
          externalOrderId: data.orderID,
          paymentProcessor: PaymentProcessor.PayPal as 0 | 1,
          reservationCode: reservationCode,
          invoiceId: order.invoiceId,
        },
      });

      const success = response.isSuccess === true;
      const shouldTryAgain = response.shouldTryAgain === true;

      if (!success && !shouldTryAgain) {
        setStatus(InvoiceStatus.error);
        setErrorString(
          "There was a problem communicating with PayPal please reach out to Honey and Thyme to confirm you payment was completed.",
        );
        return;
      } else if (!success && shouldTryAgain) {
        setStatus(InvoiceStatus.declined);
        setErrorString(
          "There was a problem charging your card, please try again.",
        );
        return;
      }
      refetch();
      setStatus(InvoiceStatus.success);
    } catch (e) {
      console.error(e);
      setStatus(InvoiceStatus.error);
      setErrorString("An unexpected error occurred.");
    }
  };

  const payDeposit = () => {
    if (!photoShoot) return;
    setAmountToBePaid(photoShoot.deposit ?? 0);
    setStatus(InvoiceStatus.payingDeposit);
  };

  const payTotal = () => {
    if (!photoShoot) return;
    setAmountToBePaid(photoShoot.paymentRemaining ?? 0);
    setStatus(InvoiceStatus.payingTotal);
  };

  const createOrder = async () => {
    if (!photoShoot) throw new Error("No photoShoot data");
    setStatus(InvoiceStatus.creatingOrder);
    try {
      const createRequest: CreatePaymentRequest = {
        amount: amountToBePaid,
        reservationCode: photoShoot.reservationCode,
        description: photoShoot.nameOfShoot,
        paymentProcessorEnum: PaymentProcessor.PayPal as 0 | 1,
      };

      const response = await createPaymentMutation.mutateAsync({
        body: createRequest,
      });
      setOrder(response);
      setStatus(InvoiceStatus.acceptingInput);
      if (response.isSuccess !== true || !response.processorOrderId) {
        setStatus(InvoiceStatus.error);
        throw new Error("Failed to create order");
      }
      console.log("Order created", response);
      return response.processorOrderId;
    } catch (e) {
      console.error(e);
      setStatus(InvoiceStatus.error);
      throw e;
    }
  };
  if (isLoading) {
    return <HoneyPageLoader />;
  }

  if (isError || !photoShoot) {
    return (
      <div className="im-fell-english flex h-[400px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-6xl">
          <FontAwesomeIcon icon={faTriangleExclamation} aria-label="error" />
        </div>
        <h2 className="mb-4 text-2xl font-bold">Unable to Load Invoice</h2>
        <p className="mb-8 max-w-md text-lg">
          Your reservation may have expired or the link may be invalid. Please
          try booking another appointment or contact us if you believe this is a
          mistake.
        </p>
        <div className="flex gap-4">
          <HoneyButton onClick={() => window.open("/book", "_self")}>
            Book Appointment
          </HoneyButton>
          <div className="bg-honey-gold/90 hover:bg-honey-gold relative flex min-w-20 cursor-pointer items-center justify-center px-4 py-1 text-black shadow-sm transition-colors hover:shadow-md">
            <button
              type="button"
              onClick={() => window.open("/contact", "_self")}
              className="im-fell-english w-full"
            >
              Contact Us
            </button>
          </div>
        </div>
      </div>
    );
  }

  const totalPaid =
    (photoShoot.price ?? 0) - (photoShoot.paymentRemaining ?? 0);
  const depositPaid = (photoShoot.deposit ?? 0) <= totalPaid;
  const paymentNeeded = (photoShoot.paymentRemaining ?? 0) > 0;
  const hasDiscount =
    photoShoot.discount !== undefined && (photoShoot.discount ?? 0) > 0;

  if (status === InvoiceStatus.error) {
    return (
      <div className="im-fell-english flex h-[300px] flex-col items-center justify-center text-center">
        <FontAwesomeIcon
          icon={faTriangleExclamation}
          className="text-honey-gold mb-4 text-4xl"
        />
        <h2 className="text-3xl">Something went wrong</h2>
        <p className="text-xl">{errorString}</p>
      </div>
    );
  }

  if (status === InvoiceStatus.declined) {
    return (
      <div className="im-fell-english flex h-[300px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-4xl">
          <FontAwesomeIcon icon={faCreditCard} />
        </div>
        <h2 className="text-3xl">Something went wrong</h2>
        <p className="text-xl">{errorString}</p>
        <div className="mt-4">
          <HoneyButton
            onClick={() => {
              setStatus(InvoiceStatus.selecting);
              setErrorString("");
            }}
          >
            Try Again
          </HoneyButton>
        </div>
      </div>
    );
  }

  if (status === InvoiceStatus.success) {
    return (
      <div className="im-fell-english flex h-[300px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-4xl">
          <FontAwesomeIcon icon={faSquareCheck} />
        </div>
        <h2 className="text-3xl">Your payment was successful!</h2>
        {paymentNeeded && (
          <p className="mt-2 text-xl">
            You have a remaining balance of ${photoShoot.paymentRemaining} due
            the day of your shoot which you can pay anytime by returning to this
            page.
          </p>
        )}
        <p className="mt-2 text-xl">Thank you for your business!</p>
      </div>
    );
  }

  return (
    <PayPalScriptProvider
      options={{
        clientId: import.meta.env.VITE_PAYPAL_CLIENT_ID,
        currency: "USD",
        intent: "capture",
      }}
    >
      {(status == InvoiceStatus.creatingOrder ||
        status == InvoiceStatus.capturing) && <HoneyPageLoader />}
      <div className="im-fell-english mx-auto flex max-w-[500px] flex-col items-center p-4">
        <h1 className="im-fell-english-sc mb-4 text-3xl">Invoice Summary</h1>

        <div className="grid w-full grid-cols-[auto_1fr] gap-x-8 gap-y-2 text-xl">
          <span>Invoice for:</span>
          <span className="text-right">{photoShoot.responsiblePartyName}</span>

          <span>Service:</span>
          <span className="text-right">{photoShoot.nameOfShoot}</span>

          <span>Date of Service:</span>
          <span className="text-right">
            {photoShoot.dateTimeUtc
              ? new Date(photoShoot.dateTimeUtc).toLocaleDateString() +
                " " +
                new Date(photoShoot.dateTimeUtc).toLocaleTimeString([], {
                  hour: "2-digit",
                  minute: "2-digit",
                })
              : ""}
          </span>

          <span>Total Billed:</span>
          <span className="text-right">${photoShoot.price}</span>

          {hasDiscount && (
            <>
              <span>Discount:</span>
              <span className="text-right">
                {photoShoot.discountName} ${photoShoot.discount}
              </span>
            </>
          )}

          <span>Total Paid:</span>
          <span className="text-right">${totalPaid}</span>

          <span>Total Remaining:</span>
          <span className="text-right">
            $
            {(photoShoot.paymentRemaining ?? 0) > 0
              ? photoShoot.paymentRemaining
              : 0}
          </span>

          <span>Payment Status:</span>
          <span className="text-right">
            {(photoShoot.paymentRemaining ?? 0) > 0 ? "Unpaid" : "Paid"}
          </span>
        </div>

        <div className="h-5"></div>

        {status === InvoiceStatus.selecting && paymentNeeded && (
          <div className="flex w-[300px] justify-evenly gap-2">
            {!depositPaid && (
              <HoneyButton onClick={payDeposit}>Pay Deposit</HoneyButton>
            )}
            <HoneyButton onClick={payTotal}>Pay Total</HoneyButton>
          </div>
        )}

        {status === InvoiceStatus.payingTotal && (
          <div className="w-[300px]">
            <HoneyInput
              label="Tip never expected, always a nice surprise"
              value={tip.toString()}
              onChange={(val) => {
                const newTip = parseFloat(val) || 0;
                setTip(newTip);
                setAmountToBePaid((photoShoot.paymentRemaining ?? 0) + newTip);
              }}
              type="number"
              startIcon={<div>$</div>}
            />
          </div>
        )}

        {(status === InvoiceStatus.payingTotal ||
          status === InvoiceStatus.payingDeposit ||
          status === InvoiceStatus.acceptingInput ||
          status === InvoiceStatus.creatingOrder) && (
          <div className="z-0 mt-2 flex w-[300px] flex-col gap-2">
            <PayPalButtons
              style={{ layout: "vertical", color: "gold" }}
              createOrder={createOrder}
              onApprove={onApprove}
              onError={onError}
            />

            <div className="bg-honey-gold/90 hover:bg-honey-gold relative flex min-w-20 cursor-pointer items-center justify-center px-4 py-1 text-black shadow-sm transition-colors hover:shadow-md">
              <button
                type="button"
                onClick={() => setStatus(InvoiceStatus.selecting)}
                className="im-fell-english w-full"
              >
                Cancel
              </button>
            </div>
          </div>
        )}

        <div className="mt-5 max-w-[500px] text-center text-lg">
          Deposit is non-refundable and will not be returned if the client
          misses for any reason. Balance is due the day of the shoot and must be
          paid in order to receive photos. If the client arrives late, they may
          be subject to a shorter photo shoot or rescheduling. Turn around time
          is typically two weeks but could be longer during busy seasons.
          Honey+Thyme reserves the right to use any and all photos for marketing
          purposes. By inquiring about our services or doing business with us,
          you are giving your consent to receive notifications and messages
          (e-mail or text) regarding our promotions or services.
        </div>
      </div>
    </PayPalScriptProvider>
  );
}

export default Invoice;
