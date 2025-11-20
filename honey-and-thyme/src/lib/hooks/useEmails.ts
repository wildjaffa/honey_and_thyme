import apiClient from "../api/client";

function useEmails(
  pageIndex: number,
  pageSize: number,
  search: string | undefined,
) {
  const queryResult = apiClient.useQuery(
    "get",
    "/api/EmailRecords/getRecords",
    {
      params: {
        query: { page: pageIndex, PageSize: pageSize, Search: search },
      },
    },
  );
  return queryResult;
}

export default useEmails;
