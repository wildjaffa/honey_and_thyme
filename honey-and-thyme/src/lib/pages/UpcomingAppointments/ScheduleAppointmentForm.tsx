import { useState } from "react";
import { HoneyModal, HoneyInput, HoneyButton } from "../../components";
import apiClient from "../../api/client";
import type { PhotoShootModel } from "../../types/api";
import {
  faCheckCircle,
  faLocationDot,
  faCalendar,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { useNavigate } from "react-router";

interface ScheduleAppointmentFormProps {
  photoShoot: PhotoShootModel;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export default function ScheduleAppointmentForm({
  photoShoot,
  isOpen,
  onClose,
  onSuccess,
}: ScheduleAppointmentFormProps) {
  const navigate = useNavigate();
  const [name, setName] = useState(photoShoot.responsiblePartyName || "");
  const [email, setEmail] = useState(
    photoShoot.responsiblePartyEmailAddress || "",
  );
  const [isSuccess, setIsSuccess] = useState(false);
  const [reservationCode, setReservationCode] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [errorDetails, setErrorDetails] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const scheduleMutation = apiClient.useMutation(
    "post",
    "/api/PhotoShoot/schedule-appointment",
  );

  const handleSubmit = async () => {
    if (!name || !email) {
      setErrorMessage("Name and Email are required.");
      setErrorDetails(null);
      return;
    }
    if (!email.includes("@")) {
      setErrorMessage("Please enter a valid email address.");
      setErrorDetails(null);
      return;
    }

    setErrorMessage(null);
    setErrorDetails(null);

    try {
      setIsSubmitting(true);
      const response = await scheduleMutation.mutateAsync({
        body: {
          photoShootId: photoShoot.photoShootId,
          name,
          email,
        },
      });

      if (response.success && response.photoShoot) {
        setIsSuccess(true);
        setReservationCode(response.photoShoot.reservationCode || null);
        onSuccess();
      } else if (response.error && response.error.code !== "UNKNOWN_ERROR") {
        // Handle specific error codes if available in the response type
        // For now, using the message or a default
        setErrorMessage(
          response.error.message ||
            "An error occurred while booking the appointment.",
        );
        setErrorDetails(response.error.details || null);
      } else {
        setErrorMessage("Something went wrong, please try again.");
      }
    } catch (error: unknown) {
      console.error("Booking error:", error);
      setErrorMessage(
        "Network connection issue. Please check your internet connection and try again.",
      );
    }
    setIsSubmitting(false);
  };

  const handlePayNow = () => {
    if (reservationCode) {
      navigate(`/invoice/${reservationCode}`);
    }
  };

  const handleClose = () => {
    // Reset state on close
    setIsSuccess(false);
    setReservationCode(null);
    setErrorMessage(null);
    setName("");
    setEmail("");
    onClose();
  };

  if (isSuccess) {
    return (
      <HoneyModal isOpen={isOpen} onClose={handleClose}>
        <div className="flex flex-col items-center text-center">
          <FontAwesomeIcon
            icon={faCheckCircle}
            className="text-honey-gold mb-6 text-6xl"
          />
          <h2 className="mb-4 text-2xl font-bold">Congratulations!</h2>
          <p className="mb-4 text-base">
            Your appointment time has been requested. Your appointment will NOT
            be considered confirmed until your deposit is paid which you can do
            now, or by clicking the link in the email we have sent you.
          </p>
          <p className="mb-8 text-base text-red-500">
            If deposit is not paid within 30 minutes, your time slot will be
            released for other clients.
          </p>

          <div className="flex w-full flex-col space-y-3">
            <HoneyButton onClick={handlePayNow} label="Pay Now" />
            <HoneyButton onClick={handleClose} label="Pay Later" />
          </div>
        </div>
      </HoneyModal>
    );
  }

  return (
    <HoneyModal
      isLoading={isSubmitting}
      isOpen={isOpen}
      onClose={handleClose}
      onSubmit={handleSubmit}
      submitText={scheduleMutation.isPending ? "Submitting..." : "Submit"}
    >
      <div className="space-y-6 text-left">
        <h2 className="text-xl font-bold">Booking Details</h2>

        <div className="bg-honey-pink rounded-lg p-4">
          <h3 className="mb-2 text-lg font-semibold">
            {photoShoot.nameOfShoot}
          </h3>
          {photoShoot.description && (
            <p className="mb-2 text-sm">{photoShoot.description}</p>
          )}
          <div className="mb-2 flex items-center text-sm">
            <FontAwesomeIcon icon={faLocationDot} className="mr-2 w-4" />
            <span>{photoShoot.location}</span>
          </div>
          <div className="mb-3 flex items-center text-sm">
            <FontAwesomeIcon icon={faCalendar} className="mr-2 w-4" />
            <span>
              {photoShoot.dateTimeUtc
                ? new Date(photoShoot.dateTimeUtc).toLocaleString()
                : ""}
            </span>
          </div>
          <div className="flex justify-between text-sm font-semibold">
            <span>Price: ${photoShoot.price}</span>
            <span>Deposit: ${photoShoot.deposit}</span>
          </div>
        </div>

        <div>
          <h3 className="mb-4 text-lg font-bold">Contact Details</h3>
          <div className="space-y-4">
            <HoneyInput
              label="Name"
              value={name}
              onChange={setName}
              required
              autoFocus
            />
            <HoneyInput
              label="Email"
              type="email"
              value={email}
              onChange={setEmail}
              required
              onKeyDown={(e) => {
                if (e.key === "Enter") {
                  handleSubmit();
                }
              }}
            />
          </div>
        </div>

        {errorMessage && (
          <div className="rounded-md border border-red-200 bg-red-50 p-4">
            <div className="flex">
              <div className="ml-3 flex-1">
                <h2 className="font-medium text-red-800">{errorMessage}</h2>
                {errorDetails && (
                  <div className="mt-2 text-sm text-red-700">
                    <p>{errorDetails}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </HoneyModal>
  );
}
