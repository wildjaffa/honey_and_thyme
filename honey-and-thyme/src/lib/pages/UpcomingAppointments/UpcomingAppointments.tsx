import { useState, useMemo, useEffect } from "react";
import useUpcomingAppointments from "../../hooks/useUpcomingAppointments";
import {
  HoneyButton,
  HoneyPageLoader,
  HoneyIconButton,
} from "../../components";
import { useNavigate } from "react-router";
import { addDays, formatDate } from "../../utils/date";
import type { PhotoShootModel } from "../../types/api";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCalendar,
  faClock,
  faEnvelope,
  faExclamationTriangle,
  faPlus,
  faArrowLeft,
  faArrowRight,
} from "@fortawesome/free-solid-svg-icons";
import { HubConnectionBuilder } from "@microsoft/signalr";
import useAuth from "../../hooks/useAuth";
import AddAppointmentModal from "./AddAppointmentModal";
import ScheduleAppointmentForm from "./ScheduleAppointmentForm";
import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, A11y } from "swiper/modules";
import "../../styles/SwiperStyles.css";
import { PhotoShootStatusEnum } from "../../enums/photoShootStatus";

function UpcomingAppointments() {
  const navigate = useNavigate();
  const [startDate] = useState(new Date());
  const [endDate] = useState(addDays(new Date(), 30));
  const { user } = useAuth();
  const isSignedIn = !!user;
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [selectedPhotoShoot, setSelectedPhotoShoot] =
    useState<PhotoShootModel | null>(null);

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

  const sortedDates = Object.keys(photoShootsByDate).sort(
    (a, b) => new Date(a).getTime() - new Date(b).getTime(),
  );

  return (
    <div className="im-fell-english relative flex w-full flex-col items-center p-4">
      {!hasAppointments ? (
        <div className="flex flex-1 flex-col items-center justify-center p-8 text-center">
          <FontAwesomeIcon className="mb-4 text-6xl" icon={faCalendar} />
          <h2 className="mb-2 text-2xl font-bold">No upcoming appointments</h2>
          <p className="mb-6 max-w-md">
            There are currently no available appointment slots. Please check
            back soon or contact us to schedule an appointment.
          </p>
          <HoneyButton onClick={() => navigate("/booking")}>
            <FontAwesomeIcon className="mr-2" icon={faEnvelope} />
            Contact Us
          </HoneyButton>
        </div>
      ) : (
        <div className="w-full max-w-[90%] xl:w-2/3">
          <div
            id="contact-us"
            className="bg-honey-pink mx-auto mb-8 rounded-xl p-6 text-center md:w-1/2 xl:w-1/4"
          >
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
              <HoneyButton onClick={() => navigate("/booking")}>
                <FontAwesomeIcon className="mr-2" icon={faEnvelope} />
                Contact Us
              </HoneyButton>
            </div>
          </div>

          <div className="relative px-12">
            <div
              id="prev-button"
              className="absolute top-1/2 -left-2 z-10 -translate-y-1/2"
            >
              <HoneyIconButton
                background="gold"
                icon={faArrowLeft}
                title="Previous Days"
              />
            </div>

            <div
              id="next-button"
              className="absolute top-1/2 -right-2 z-10 -translate-y-1/2"
            >
              <HoneyIconButton
                background="gold"
                icon={faArrowRight}
                title="Next Days"
              />
            </div>

            <Swiper
              modules={[Navigation, A11y]}
              spaceBetween={24}
              slidesPerView={1}
              navigation={{
                prevEl: "#prev-button",
                nextEl: "#next-button",
                disabledClass:
                  "opacity-50 cursor-not-allowed pointer-events-none",
              }}
              breakpoints={{
                640: {
                  slidesPerView: 1,
                },
                768: {
                  slidesPerView: 2,
                },
                1024: {
                  slidesPerView: 3,
                },
                1280: {
                  slidesPerView: 4,
                },
              }}
            >
              {sortedDates.map((dateString) => {
                const shoots = photoShootsByDate[dateString];
                if (!shoots) return null;

                const date = new Date(dateString);
                const firstShoot = shoots[0];

                if (!firstShoot) return null;

                return (
                  <SwiperSlide key={dateString}>
                    <div className="text-center">
                      <h3 className="mb-2 text-xl">
                        {new Intl.DateTimeFormat("en-US", {
                          month: "numeric",
                          day: "numeric",
                        }).format(date)}
                      </h3>
                      <div className="text-s mb-1">
                        {firstShoot.nameOfShoot}
                      </div>
                      <div className="mb-4 text-sm text-gray-500">
                        {firstShoot.location}
                      </div>

                      <div className="flex flex-col space-y-4">
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
                              setSelectedPhotoShoot(shoot);
                            }}
                            disabled={
                              shoot.status !== PhotoShootStatusEnum.Unbooked
                            }
                          />
                        ))}
                      </div>
                    </div>
                  </SwiperSlide>
                );
              })}
            </Swiper>
          </div>
        </div>
      )}

      {isSignedIn && (
        <div className="fixed right-8 bottom-8 z-50">
          <HoneyIconButton
            icon={faPlus}
            onClick={() => setIsAddModalOpen(true)}
            title="Add Appointments"
            background="gold"
            size="large"
          />
        </div>
      )}

      <AddAppointmentModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onSuccess={() => {
          setIsAddModalOpen(false);
          refetch();
        }}
      />

      {selectedPhotoShoot && (
        <ScheduleAppointmentForm
          photoShoot={selectedPhotoShoot}
          isOpen={!!selectedPhotoShoot}
          onClose={() => setSelectedPhotoShoot(null)}
          onSuccess={() => {
            // Keep the modal open to show success message, or handle as needed
            // The form itself handles the success state UI
            refetch();
          }}
        />
      )}
    </div>
  );
}

export default UpcomingAppointments;
