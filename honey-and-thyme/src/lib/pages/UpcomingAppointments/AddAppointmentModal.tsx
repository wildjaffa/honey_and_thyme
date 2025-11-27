import { useState } from "react";
import { HoneyModal, HoneyInput } from "../../components";
import apiClient from "../../api/client";
import { toast } from "react-toastify";
import PhotoShootType from "../../enums/photoShootType";
import { faDollarSign } from "@fortawesome/free-solid-svg-icons";
import { PhotoShootStatusEnum } from "../../enums/photoShootStatus";
import { addDays } from "../../utils/date";

interface AddAppointmentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface FormData {
  name: string;
  location: string;
  price: number;
  deposit: number;
  startDate: string;
  endDate: string;
  appointmentDuration: number;
  breakDuration: number;
  description: string;
}

export default function AddAppointmentModal({
  isOpen,
  onClose,
  onSuccess,
}: AddAppointmentModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState<FormData>({
    name: "",
    location: "",
    price: 0,
    deposit: 0,
    startDate: addDays(new Date(), 1).toISOString().slice(0, 16), // Tomorrow
    endDate: addDays(new Date(), 1).toISOString().slice(0, 16), // Tomorrow + 1h
    appointmentDuration: 15,
    breakDuration: 5,
    description: "",
  });

  const createPhotoShoot = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/create-many",
  );

  const handleChange = (field: keyof FormData, value: string | number) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async () => {
    if (
      !formData.name ||
      !formData.location ||
      !formData.startDate ||
      !formData.endDate
    ) {
      toast.error("Please fill in all required fields");
      return;
    }

    setIsSubmitting(true);
    try {
      const photoShoots = [];
      let currentStart = new Date(formData.startDate);
      const end = new Date(formData.endDate);
      const durationMs = formData.appointmentDuration * 60 * 1000;
      const breakMs = formData.breakDuration * 60 * 1000;

      while (currentStart.getTime() + durationMs + breakMs <= end.getTime()) {
        const currentEnd = new Date(currentStart.getTime() + durationMs);

        photoShoots.push({
          photoShootId: crypto.randomUUID(),
          dateTimeUtc: currentStart.toISOString(),
          location: formData.location,
          nameOfShoot: formData.name,
          price: formData.price,
          deposit: formData.deposit,
          endDateTimeUtc: currentEnd.toISOString(),
          description: formData.description,
          photoShootType: PhotoShootType.calendarBooking as 0 | 1,
          status: PhotoShootStatusEnum.Unbooked as 0 | 1 | 2 | 3 | 4 | 5 | 6,
        });

        currentStart = new Date(currentEnd.getTime() + breakMs);
      }

      const result = await createPhotoShoot.mutateAsync({ body: photoShoots });

      toast.success(`${result.length} appointment slots created`);
      onSuccess();
      onClose();
    } catch (error) {
      console.error("Error creating appointments:", error);
      toast.error("Failed to create appointments");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <HoneyModal
      isOpen={isOpen}
      onClose={onClose}
      onSubmit={handleSubmit}
      submitText={isSubmitting ? "Saving..." : "Save"}
    >
      <div className="space-y-4">
        <h2 className="im-fell-english mb-4 text-center text-2xl font-bold">
          Add Appointments
        </h2>

        <HoneyInput
          label="Name"
          value={formData.name}
          onChange={(val) => handleChange("name", val)}
          required
        />

        <HoneyInput
          label="Location"
          value={formData.location}
          onChange={(val) => handleChange("location", val)}
          required
        />

        <HoneyInput
          label="Price"
          type="number"
          value={formData.price.toString()}
          onChange={(val) => handleChange("price", parseFloat(val) || 0)}
          startIcon={faDollarSign}
        />
        <HoneyInput
          label="Deposit"
          type="number"
          value={formData.deposit.toString()}
          onChange={(val) => handleChange("deposit", parseFloat(val) || 0)}
          startIcon={faDollarSign}
        />

        <HoneyInput
          label="Start Date"
          type="datetime-local"
          value={formData.startDate}
          onChange={(val) => handleChange("startDate", val)}
          required
        />
        <HoneyInput
          label="End Date"
          type="datetime-local"
          value={formData.endDate}
          onChange={(val) => handleChange("endDate", val)}
          required
        />

        <HoneyInput
          label="Duration (min)"
          type="number"
          value={formData.appointmentDuration.toString()}
          onChange={(val) =>
            handleChange("appointmentDuration", parseInt(val) || 0)
          }
        />
        <HoneyInput
          label="Break (min)"
          type="number"
          value={formData.breakDuration.toString()}
          onChange={(val) => handleChange("breakDuration", parseInt(val) || 0)}
        />

        <HoneyInput
          label="Description"
          value={formData.description}
          onChange={(val) => handleChange("description", val)}
        />
      </div>
    </HoneyModal>
  );
}
