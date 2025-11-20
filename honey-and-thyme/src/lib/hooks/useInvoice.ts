import apiClient from "../api/client";

function useInvoice(reservationCode?: string) {
  const queryResult = apiClient.useQuery(
    "get",
    "/api/PhotoShoot/by-reservation-code/{reservationCode}",
    {
      params: {
        path: {
          reservationCode: reservationCode ?? "",
        },
      },
      enabled: !!reservationCode,
    },
  );
  return queryResult;
}

export default useInvoice;
