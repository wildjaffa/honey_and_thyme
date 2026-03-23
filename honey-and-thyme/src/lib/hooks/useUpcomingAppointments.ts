import apiClient from "../api/client";

function useUpcomingAppointments(startDate: Date, endDate: Date) {
  const queryResult = apiClient.useQuery(
    "get",
    "/api/PhotoShoot/upcoming-appointments",
    {
      queryParams: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
      },
    },
  );
  return queryResult;
}

export default useUpcomingAppointments;
