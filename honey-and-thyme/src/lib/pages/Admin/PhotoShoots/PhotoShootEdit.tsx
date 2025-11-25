import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  HoneyButton,
  HoneyInput,
  HoneyAlbumPicker,
  HoneyDropDownSelector,
  HoneyPageLoader,
} from "../../../components";
import apiClient from "../../../api/client";
import usePhotoShoot from "../../../hooks/usePhotoShoot";
import useProducts from "../../../hooks/useProducts";
import type { PhotoShootModel } from "../../../types/api";
import { toast } from "react-toastify";
import PaymentProcessor from "../../../enums/paymentProcessor";

const PhotoShootStatusMap: Record<number, string> = {
  0: "Unbooked",
  1: "Scheduled",
  2: "Booked",
  3: "Confirmed",
  4: "Paid",
  5: "Delivered",
  6: "Deleted",
};

function PhotoShootEdit() {
  const { photoShootId } = useParams();
  const navigate = useNavigate();
  const isNew = !photoShootId || photoShootId === "new";

  const { data: photoShootData, isLoading: isLoadingPhotoShoot } =
    usePhotoShoot(photoShootId);
  const { data: productsData } = useProducts();

  const [formState, setFormState] = useState<PhotoShootModel>({
    status: 2, // Booked default
  });
  const [showAdditionalFields, setShowAdditionalFields] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (photoShootData && !isNew) {
      setFormState(photoShootData);
    }
  }, [photoShootData, isNew]);

  const handleChange = (field: keyof PhotoShootModel, value: unknown) => {
    setFormState((prev) => ({ ...prev, [field]: value }));
  };

  const handleProductChange = (productName: string) => {
    const product = productsData?.find((p) => p.name === productName);
    if (product) {
      setFormState((prev) => ({
        ...prev,
        nameOfShoot: product.name,
        price: product.price,
        deposit: product.deposit,
        description: product.description,
      }));
    }
  };

  const createPhotoShoot = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/create",
  );
  const updatePhotoShoot = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/update",
  );
  const deletePhotoShoot = apiClient.useMutation(
    "delete",
    "/api/PhotoShoot/{id}",
  );
  const createPayment = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/createPayment",
  );
  const capturePayment = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/capturePayment",
  );

  const handleSave = async () => {
    if (!formState.nameOfShoot) {
      toast.error("Name of Shoot is required");
      return;
    }

    setIsSubmitting(true);
    try {
      if (isNew) {
        await createPhotoShoot.mutateAsync({
          body: formState,
        });
      } else {
        await updatePhotoShoot.mutateAsync({
          body: formState,
        });
      }
      navigate("/Admin/PhotoShoots");
    } catch (error) {
      console.error("Error saving photo shoot:", error);
      toast.error("Error saving photo shoot");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    if (!photoShootId) {
      toast.error("Photo shoot ID is required");
      return;
    }
    if (!confirm("Are you sure you want to cancel this shoot?")) return;
    setIsSubmitting(true);
    try {
      await deletePhotoShoot.mutateAsync({
        params: { path: { id: photoShootId } },
      });
      navigate("Admin/PhotoShoots");
    } catch (error) {
      console.error("Error deleting photo shoot:", error);
      toast.error("Error deleting photo shoot");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleMarkPaid = async () => {
    if (!formState.paymentRemaining) {
      toast.error("Payment remaining is required");
      return;
    }
    if (!confirm("Are you sure you want to mark this shoot as paid?")) return;
    setIsSubmitting(true);
    try {
      // Create payment
      const createRes = await createPayment.mutateAsync({
        body: {
          amount: formState.paymentRemaining,
          description: "Admin Payment",
          paymentProcessorEnum: (PaymentProcessor.External as 0) || 1,
          reservationCode: formState.reservationCode,
        },
      });

      if (createRes.invoiceId) {
        // Capture payment
        await capturePayment.mutateAsync({
          body: {
            amountToBeCharged: formState.paymentRemaining,
            externalOrderId: photoShootId,
            paymentProcessor: (PaymentProcessor.External as 0) || 1,
            reservationCode: formState.reservationCode,
            invoiceId: createRes.invoiceId,
          },
        });
        navigate("/Admin/PhotoShoots");
      }
    } catch (error) {
      console.error("Error marking paid:", error);
      toast.error("Error marking paid");
    } finally {
      setIsSubmitting(false);
    }
  };

  const copyInvoiceLink = () => {
    const url = `${window.location.origin}/invoice/${formState.reservationCode}`;
    navigator.clipboard.writeText(
      `You can pay for your upcoming photo shoot at ${url}`,
    );
    toast.success("Link copied to clipboard");
  };

  if (isLoadingPhotoShoot) {
    return <HoneyPageLoader />;
  }

  return (
    <div className="mx-auto max-w-2xl p-4">
      <div className="mb-6 flex items-center gap-4">
        <h1 className="im-fell-english text-3xl font-bold text-gray-900">
          {isNew ? "New Photo Shoot" : "Edit Photo Shoot"}
        </h1>
      </div>

      <div className="space-y-4">
        <HoneyInput
          label="Client Name"
          value={formState.responsiblePartyName ?? ""}
          onChange={(val) => handleChange("responsiblePartyName", val)}
        />
        <HoneyInput
          label="Client Email"
          value={formState.responsiblePartyEmailAddress ?? ""}
          onChange={(val) => handleChange("responsiblePartyEmailAddress", val)}
        />

        <HoneyInput
          type="datetime-local"
          label="Date & Time"
          value={formState.dateTimeUtc ?? ""}
          onChange={(val) => handleChange("dateTimeUtc", val)}
        />

        <div className="flex flex-col gap-1">
          <HoneyAlbumPicker
            label="Album"
            onAlbumSelected={(id) => handleChange("albumId", id)}
          />
          {formState.albumId && (
            <div className="text-xs text-gray-500">
              Selected Album ID: {formState.albumId}
            </div>
          )}
        </div>

        {!isNew && (
          <div className="text-sm font-medium">
            Balance: $
            {(formState.paymentRemaining ?? 0) > 0
              ? formState.paymentRemaining
              : 0}
          </div>
        )}

        {isNew && (
          <HoneyDropDownSelector
            label="Product"
            items={productsData ?? []}
            displayValue={(p) => p.name ?? ""}
            keyExtractor={(p) => p.productId ?? ""}
            onSelect={(p) => p && p.name && handleProductChange(p.name)}
            placeholder="Select a product..."
          />
        )}

        <div className="flex items-center justify-between">
          <button
            type="button"
            onClick={() => setShowAdditionalFields(!showAdditionalFields)}
            className="text-honey-gold hover:text-honey-gold/80 cursor-pointer text-sm font-medium"
          >
            {showAdditionalFields
              ? "Hide Additional Fields"
              : "Show Additional Fields"}
          </button>
        </div>

        {showAdditionalFields && (
          <div className="space-y-4">
            <HoneyInput
              label="Name of Shoot"
              value={formState.nameOfShoot ?? ""}
              onChange={(val) => handleChange("nameOfShoot", val)}
            />
            <HoneyInput
              label="Description"
              value={formState.description ?? ""}
              onChange={(val) => handleChange("description", val)}
              type="textarea"
            />
            <HoneyInput
              label="Price"
              value={formState.price?.toString() ?? ""}
              onChange={(val) => handleChange("price", parseFloat(val))}
              type="number"
              startIcon={<div>$</div>}
            />
            <HoneyInput
              label="Deposit"
              value={formState.deposit?.toString() ?? ""}
              onChange={(val) => handleChange("deposit", parseFloat(val))}
              type="number"
              startIcon={<div>$</div>}
            />
            <HoneyInput
              label="Discount"
              value={formState.discount?.toString() ?? ""}
              onChange={(val) => handleChange("discount", parseFloat(val))}
              type="number"
            />
            <HoneyInput
              label="Discount Name"
              value={formState.discountName ?? ""}
              onChange={(val) => handleChange("discountName", val)}
            />
            <div className="flex flex-col gap-1">
              <label className="text-sm font-medium text-gray-700">
                Status
              </label>
              <select
                className="border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-full rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none"
                value={formState.status}
                onChange={(e) =>
                  handleChange("status", parseInt(e.target.value))
                }
              >
                {Object.entries(PhotoShootStatusMap).map(([key, value]) => (
                  <option key={key} value={key}>
                    {value}
                  </option>
                ))}
              </select>
            </div>
          </div>
        )}

        <div className="flex flex-col gap-3 pt-4">
          <HoneyButton onClick={handleSave} isLoading={isSubmitting} isSubmit>
            Save
          </HoneyButton>

          {!isNew && (
            <>
              <HoneyButton onClick={copyInvoiceLink}>
                Copy Link to Invoice
              </HoneyButton>
              <HoneyButton onClick={handleMarkPaid} isLoading={isSubmitting}>
                Mark as Paid
              </HoneyButton>
              <HoneyButton
                onClick={handleDelete}
                isLoading={isSubmitting}
                disabled={isSubmitting}
              >
                Cancel Shoot
              </HoneyButton>
            </>
          )}
          <HoneyButton
            onClick={() => navigate("/Admin/PhotoShoots")}
            disabled={isSubmitting}
          >
            Back
          </HoneyButton>
        </div>
      </div>
    </div>
  );
}

export default PhotoShootEdit;
