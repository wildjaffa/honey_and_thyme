import { useState, useMemo, useEffect } from "react";
import useUpcomingAppointments from "../../hooks/useUpcomingAppointments";
import { HoneyButton, HoneyPageLoader } from "../../components";
import { useNavigate } from "react-router";
import { addDays, formatDate } from "../../utils/date";
import type { PhotoShootModel } from "../../types/api";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCalendar,
  faClock,
  faEnvelope,
  faExclamationTriangle,
} from "@fortawesome/free-solid-svg-icons";
import { HubConnectionBuilder } from "@microsoft/signalr";

function UpcomingAppointments() {
  const navigate = useNavigate();
  const [startDate] = useState(new Date());
  const [endDate] = useState(addDays(new Date(), 30));

  const {
    data: photoShoots,
    isLoading,
    error,
    refetch,
  } = useUpcomingAppointments(startDate, endDate);

  useEffect(() => {
    const connection = new HubConnectionBuilder()
      .withUrl(`${import.meta.env.VITE_BASE_URL}/bookingHub`)
      .withAutomaticReconnect()
      .build();

    const startConnection = async () => {
      try {
        await connection.start();
        console.log("SignalR Connected");

        connection.on("PhotoShootScheduled", () => {
          refetch();
        });

        connection.on("PhotoShootUnscheduled", () => {
          refetch();
        });
      } catch (err) {
        console.error("SignalR Connection Error: ", err);
      }
    };

    startConnection();

    return () => {
      connection.stop();
    };
  }, [refetch]);

  const photoShootsByDate = useMemo(() => {
    if (!photoShoots) return {};
    const grouped: Record<string, PhotoShootModel[]> = {};
    photoShoots.forEach((shoot: PhotoShootModel) => {
      if (!shoot.dateTimeUtc) return;
      const date = new Date(shoot.dateTimeUtc);
      const dateKey = formatDate(date);
      if (!grouped[dateKey]) {
        grouped[dateKey] = [];
      }
      grouped[dateKey].push(shoot);
    });
    return grouped;
  }, [photoShoots]);

  if (isLoading) {
    return <HoneyPageLoader />;
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center p-8 text-center">
        <FontAwesomeIcon
          className="mb-4 text-4xl text-red-600"
          icon={faExclamationTriangle}
        />
        <h2 className="mb-2 text-xl font-bold">Oops! Something went wrong.</h2>
        <p className="mb-4">
          We couldn't load the upcoming appointments. Please try again later.
        </p>
        <HoneyButton
          onClick={() => (refetch as unknown as () => void)()}
          label="Try Again"
        />
      </div>
    );
  }

  const hasAppointments = Object.keys(photoShootsByDate).length > 0;

  if (!hasAppointments) {
    return (
      <div className="im-fell-english flex min-h-[50vh] flex-col items-center justify-center p-8 text-center">
        <FontAwesomeIcon className="mb-4 text-6xl" icon={faCalendar} />
        <h2 className="mb-2 text-2xl font-bold">No upcoming appointments</h2>
        <p className="mb-6 max-w-md">
          There are currently no available appointment slots. Please check back
          soon or contact us to schedule an appointment.
        </p>
        <HoneyButton onClick={() => navigate("/contact")}>
          <FontAwesomeIcon className="mr-2" icon={faEnvelope} />
          Contact Us
        </HoneyButton>
      </div>
    );
  }

  return (
    <div className="im-fell-english flex w-full flex-col items-center p-4">
      <div className="w-1/2 max-w-6xl">
        <div className="bg-honey-pink center mb-8 rounded-xl p-6 text-center">
          <FontAwesomeIcon
            className="text-honey-gold mb-3 text-4xl"
            icon={faClock}
          />
          <h2 className="mb-2 text-xl font-semibold">
            Can't find a time that works for you?
          </h2>
          <p className="text-honey-gold mb-4">
            Contact us to schedule an appointment.
          </p>
          <div className="flex justify-center">
            <HoneyButton onClick={() => navigate("/contact")}>
              <FontAwesomeIcon className="mr-2" icon={faEnvelope} />
              Contact Us
            </HoneyButton>
          </div>
        </div>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          {Object.entries(photoShootsByDate).map(([dateString, shoots]) => {
            const date = new Date(dateString);
            const firstShoot = shoots[0];

            if (!firstShoot) return null;

            return (
              <div key={dateString} className="text-center">
                <h3 className="mb-2 text-xl">
                  {new Intl.DateTimeFormat("en-US", {
                    month: "numeric",
                    day: "numeric",
                  }).format(date)}
                </h3>
                <div className="text-s mb-1">{firstShoot.nameOfShoot}</div>
                <div className="mb-4 text-sm text-gray-500">
                  {firstShoot.location}
                </div>

                <div className="flex w-full flex-col space-y-4">
                  {shoots.map((shoot: PhotoShootModel) => (
                    <HoneyButton
                      key={shoot.photoShootId}
                      label={
                        shoot.dateTimeUtc
                          ? new Intl.DateTimeFormat("en-US", {
                              hour: "numeric",
                              minute: "2-digit",
                              hour12: true,
                            }).format(new Date(shoot.dateTimeUtc))
                          : ""
                      }
                      onClick={() => {
                        // Handle booking logic here
                        console.log("Book shoot:", shoot.photoShootId);
                      }}
                      disabled={shoot.status !== 0} // Assuming 0 is unbooked
                    />
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default UpcomingAppointments;
