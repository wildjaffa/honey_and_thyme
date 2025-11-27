import { useState } from "react";
import {
  HoneyInput,
  HoneyButton,
  HoneyDropDownSelector,
} from "../../components";
import apiClient from "../../api/client";

interface BookingRequest {
  name?: string;
  email?: string;
  numberOfPeople?: number;
  sessionLength?: string;
  occasion?: string;
  location?: string;
  questions?: string;
}

const ContactState = {
  NotSent: "notSent",
  Sending: "sending",
  Sent: "sent",
  Failed: "failed",
} as const;

type ContactState = (typeof ContactState)[keyof typeof ContactState];

const SESSION_LENGTHS = ["Mini", "Half", "Full", "Double", "Other"];

function Booking() {
  const [contactState, setContactState] = useState<ContactState>(
    ContactState.NotSent,
  );
  const [bookingRequest, setBookingRequest] = useState<BookingRequest>({});
  const [errors, setErrors] = useState<
    Partial<Record<keyof BookingRequest, string>>
  >({});

  const bookingMutation = apiClient.useMutation("post", "/api/booking");

  const validateForm = (): boolean => {
    const newErrors: Partial<Record<keyof BookingRequest, string>> = {};

    if (!bookingRequest.name?.trim()) {
      newErrors.name = "Name is required";
    }

    if (!bookingRequest.email?.trim()) {
      newErrors.email = "Email is required";
    } else if (!bookingRequest.email.includes("@")) {
      newErrors.email = "Please enter a valid email address";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    const stopWatch = Date.now();
    setContactState(ContactState.Sending);

    try {
      const response = await bookingMutation.mutateAsync({
        body: bookingRequest,
      });

      // Ensure minimum 500ms loading time for better UX
      const elapsed = Date.now() - stopWatch;
      if (elapsed < 500) {
        await new Promise((resolve) => setTimeout(resolve, 500 - elapsed));
      }

      if (response.result) {
        setContactState(ContactState.Sent);
      } else {
        setContactState(ContactState.Failed);
      }
    } catch (error) {
      console.error("Booking error:", error);
      setContactState(ContactState.Failed);
    }
  };

  const updateField = <K extends keyof BookingRequest>(
    field: K,
    value: BookingRequest[K],
  ) => {
    setBookingRequest((prev) => ({ ...prev, [field]: value }));
    // Clear error for this field when user starts typing
    if (errors[field]) {
      setErrors(
        (prev) =>
          Object.fromEntries(
            Object.entries(prev).filter(([key]) => key !== field),
          ) as Partial<Record<keyof BookingRequest, string>>,
      );
    }
  };

  const isDisabled = contactState === ContactState.Sending;

  return (
    <div className="im-fell-english flex w-full flex-col items-center p-4">
      <div className="w-full max-w-2xl">
        {contactState === ContactState.Sent ? (
          <div className="rounded-lg bg-green-50 p-8 text-center">
            <h2 className="mb-4 text-2xl font-bold text-green-800">
              Booking Request Sent
            </h2>
            <p className="text-lg text-green-700">
              Your booking request has been sent. We will get back to you as
              soon as possible. Thank you!
            </p>
          </div>
        ) : (
          <>
            {contactState === ContactState.Failed && (
              <div className="mb-6 rounded-lg bg-red-50 p-4 text-center">
                <p className="text-lg text-red-700">
                  Sorry, there was an issue trying to submit your message.
                  Please try again later.
                </p>
              </div>
            )}

            <div className="mb-6">
              <h1 className="mb-2 text-2xl font-bold">Book a Session</h1>
              <p className="text-lg">
                Please enter the details of your booking request below.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <HoneyInput
                  label="Name"
                  value={bookingRequest.name || ""}
                  onChange={(value) => updateField("name", value)}
                  disabled={isDisabled}
                  required
                />
                {errors.name && (
                  <p className="mt-1 text-sm text-red-600">{errors.name}</p>
                )}
              </div>

              <div>
                <HoneyInput
                  label="Email"
                  type="email"
                  value={bookingRequest.email || ""}
                  onChange={(value) => updateField("email", value)}
                  disabled={isDisabled}
                  required
                />
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                )}
              </div>

              <div>
                <HoneyInput
                  label="Number of Guests"
                  type="number"
                  value={bookingRequest.numberOfPeople?.toString() || ""}
                  onChange={(value) =>
                    updateField("numberOfPeople", parseInt(value) || undefined)
                  }
                  disabled={isDisabled}
                />
              </div>

              <div>
                <HoneyDropDownSelector
                  label="Session Length"
                  placeholder="Select session length"
                  items={SESSION_LENGTHS}
                  displayValue={(item) => item}
                  keyExtractor={(item) => item}
                  onSelect={(item) => updateField("sessionLength", item)}
                  disabled={isDisabled}
                />
              </div>

              <div>
                <HoneyInput
                  label="Occasion"
                  value={bookingRequest.occasion || ""}
                  onChange={(value) => updateField("occasion", value)}
                  placeholder="e.g. Birthday, Anniversary, couples/family etc."
                  disabled={isDisabled}
                />
              </div>

              <div>
                <HoneyInput
                  label="Location Preferences"
                  value={bookingRequest.location || ""}
                  onChange={(value) => updateField("location", value)}
                  placeholder="e.g. Indoor, Outdoor, Specific Location, Aesthetic etc"
                  disabled={isDisabled}
                />
              </div>

              <div>
                <HoneyInput
                  label="Other Info Or Questions"
                  type="textarea"
                  value={bookingRequest.questions || ""}
                  onChange={(value) => updateField("questions", value)}
                  disabled={isDisabled}
                />
              </div>

              <div className="flex justify-end">
                <HoneyButton
                  isSubmit
                  label={isDisabled ? "Sending..." : "Send"}
                  disabled={isDisabled}
                />
              </div>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

export default Booking;
