import { useState, useEffect } from "react";
import { useParams } from "react-router";
import useInvoice from "../../hooks/useInvoice";
import { HoneyButton, HoneyInput, HoneyPageLoader } from "../../components";
import apiClient from "../../api/client";
import type { CreatePaymentRequest } from "../../types/api";

const InvoiceStatus = {
  selecting: 0,
  payingDeposit: 1,
  payingTotal: 2,
  creatingOrder: 3,
  capturing: 4,
  error: 5,
  success: 6,
  awaitingPaypal: 7,
  declined: 8,
};

// Define a type for the status values
type InvoiceStatusType = (typeof InvoiceStatus)[keyof typeof InvoiceStatus];

// Define types for PayPal events
interface PayPalApproveEvent {
  type: "PAYPAL_APPROVE";
  orderId: string;
}

interface PayPalErrorEvent {
  type: "PAYPAL_ERROR";
  error: string;
}

interface PayPalCloseEvent {
  type: "PAYPAL_CLOSE";
}

type PayPalEvent = PayPalApproveEvent | PayPalErrorEvent | PayPalCloseEvent;

function Invoice() {
  const { reservationCode } = useParams();
  const { data: photoShoot, isLoading, isError } = useInvoice(reservationCode);
  const [status, setStatus] = useState<InvoiceStatusType>(
    InvoiceStatus.selecting,
  );
  const [amountToBePaid, setAmountToBePaid] = useState(0);
  const [tip, setTip] = useState(0);
  const [errorString, setErrorString] = useState("");
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [order, setOrder] = useState<any>(null);

  const createPaymentMutation = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/createPayment",
  );
  const capturePaymentMutation = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/capturePayment",
  );

  // Define handlers first so they can be used in useEffect
  const onError = (error: string) => {
    setStatus(InvoiceStatus.error);
    setErrorString(error);
  };

  const payPalWindowClosed = () => {
    if (status !== InvoiceStatus.awaitingPaypal) {
      return;
    }
    setStatus(InvoiceStatus.selecting);
  };

  const onApprove = async (orderId: string) => {
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
          externalOrderId: orderId,
          paymentProcessor: 1, // PayPal
          reservationCode: reservationCode,
          invoiceId: order.invoiceId,
        },
      });

      // Check for success based on the response structure
      // Assuming BooleanResultModel has isSuccess and potentially other fields
      const success = response.isSuccess === true;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const shouldTryAgain = (response as any).shouldTryAgain === true;

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

      // Refetch invoice to update status
      // In React Query, we can invalidate queries, but for now we'll just set success
      setStatus(InvoiceStatus.success);
    } catch (e) {
      console.error(e);
      setStatus(InvoiceStatus.error);
      setErrorString("An unexpected error occurred.");
    }
  };

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const data = event.data as PayPalEvent;
      if (data?.type === "PAYPAL_APPROVE") {
        onApprove(data.orderId);
      } else if (data?.type === "PAYPAL_ERROR") {
        onError(data.error);
      } else if (data?.type === "PAYPAL_CLOSE") {
        payPalWindowClosed();
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status, order]);

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

  const createPayment = async () => {
    if (!photoShoot) return;
    setStatus(InvoiceStatus.creatingOrder);

    try {
      const createRequest: CreatePaymentRequest = {
        amount: amountToBePaid,
        reservationCode: photoShoot.reservationCode,
        description: photoShoot.nameOfShoot,
        paymentProcessorEnum: 1, // PayPal
      };

      const response = await createPaymentMutation.mutateAsync({
        body: createRequest,
      });
      setOrder(response);

      if (response.isSuccess !== true || !response.processorOrderId) {
        setStatus(InvoiceStatus.error);
        return;
      }

      setStatus(InvoiceStatus.awaitingPaypal);
      // TODO: Implement actual PayPal window opening
      // PayPalInterop.openPayPalWindow(amountToBePaid, '', order!.processorOrderId!);
      // For now, alerting
      alert(
        `Opening PayPal for order ${response.processorOrderId}. This part needs JS implementation similar to Flutter's PayPalInterop.`,
      );
    } catch (e) {
      console.error(e);
      setStatus(InvoiceStatus.error);
    }
  };

  if (isLoading) {
    return <HoneyPageLoader />;
  }

  if (isError || !photoShoot) {
    return (
      <div className="flex h-[400px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-6xl">
          {/* Using text for icon placeholder if FontAwesome isn't globally available or configured */}
          <span role="img" aria-label="error">
            ⚠️
          </span>
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

  if (status === InvoiceStatus.awaitingPaypal) {
    return (
      <div className="flex h-[300px] items-center justify-center">
        <p className="max-w-lg text-center text-xl">
          Please complete your payment in the PayPal window.
        </p>
      </div>
    );
  }

  if (status === InvoiceStatus.error) {
    return (
      <div className="flex h-[300px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-4xl">⚠️</div>
        <h2 className="text-3xl">Something went wrong</h2>
        <p className="text-xl">{errorString}</p>
      </div>
    );
  }

  if (status === InvoiceStatus.declined) {
    return (
      <div className="flex h-[300px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-4xl">💳</div>
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
      <div className="flex h-[300px] flex-col items-center justify-center text-center">
        <div className="text-honey-gold mb-4 text-4xl">✅</div>
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
    <div className="mx-auto flex max-w-[600px] flex-col items-center p-4">
      <h1 className="im-fell-english-sc mb-4 text-3xl">Invoice Summary</h1>

      <div className="w-full max-w-[300px]">
        <div className="flex justify-between text-xl">
          <span>Invoice for:</span>
          <span>{photoShoot.responsiblePartyName}</span>
        </div>
        <div className="flex justify-between text-xl">
          <span>Service:</span>
          <span>{photoShoot.nameOfShoot}</span>
        </div>
        <div className="flex justify-between text-xl">
          <span>Date of Service:</span>
          <span>
            {photoShoot.dateTimeUtc
              ? new Date(photoShoot.dateTimeUtc).toLocaleDateString() +
                " " +
                new Date(photoShoot.dateTimeUtc).toLocaleTimeString([], {
                  hour: "2-digit",
                  minute: "2-digit",
                })
              : ""}
          </span>
        </div>
        <div className="flex justify-between text-xl">
          <span>Total Billed:</span>
          <span>${photoShoot.price}</span>
        </div>
        {hasDiscount && (
          <div className="flex justify-between text-xl">
            <span>Discount:</span>
            <span>
              {photoShoot.discountName} ${photoShoot.discount}
            </span>
          </div>
        )}
        <div className="flex justify-between text-xl">
          <span>Total Paid:</span>
          <span>${totalPaid}</span>
        </div>
        <div className="flex justify-between text-xl">
          <span>Total Remaining:</span>
          <span>${photoShoot.paymentRemaining}</span>
        </div>
        <div className="flex justify-between text-xl">
          <span>Payment Status:</span>
          <span>{photoShoot.paymentRemaining === 0 ? "Paid" : "Unpaid"}</span>
        </div>
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
          />
        </div>
      )}

      {(status === InvoiceStatus.payingTotal ||
        status === InvoiceStatus.payingDeposit) && (
        <div className="mt-2 flex flex-col gap-2">
          <HoneyButton onClick={createPayment}>
            Confirm Pay ${amountToBePaid}
          </HoneyButton>
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

      {status === InvoiceStatus.creatingOrder && (
        <div className="mt-4">
          <HoneyPageLoader />
        </div>
      )}

      <div className="mt-5 max-w-[500px] text-center text-lg">
        Deposit is non-refundable and will not be returned if the client misses
        for any reason. Balance is due the day of the shoot and must be paid in
        order to receive photos. If the client arrives late, they may be subject
        to a shorter photo shoot or rescheduling. Turn around time is typically
        two weeks but could be longer during busy seasons. Honey+Thyme reserves
        the right to use any and all photos for marketing purposes. By inquiring
        about our services or doing business with us, you are giving your
        consent to receive notifications and messages (e-mail or text) regarding
        our promotions or services.
      </div>
    </div>
  );
}

export default Invoice;
