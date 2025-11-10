import apiClient from "../api/client";

function useAlbums(
  pageIndex: number,
  pageSize: number,
  search: string | undefined,
) {
  const queryResult = apiClient.useQuery("get", "/albums/paginated", {
    params: {
      query: { PageIndex: pageIndex, PageSize: pageSize, Search: search },
    },
  });
  return queryResult;
}

export default useAlbums;
