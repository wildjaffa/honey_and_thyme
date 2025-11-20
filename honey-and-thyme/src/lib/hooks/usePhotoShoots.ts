import apiClient from "../api/client";

export interface PhotoShootFilters {
  endDate?: Date;
  startDate?: Date;
  photoShootType?: 0 | 1;
  statuses?: (0 | 1 | 2 | 3 | 4 | 5 | 6)[];
}

function usePhotoShoots(
  pageIndex: number,
  pageSize: number,
  searchString?: string,
  filters?: PhotoShootFilters,
) {
  const { endDate, startDate, photoShootType, statuses } = filters ?? {};

  const queryResult = apiClient.useQuery("post", "/api/PhotoShoot/paginated", {
    body: {
      pageIndex,
      pageSize,
      searchString,
      endDate: endDate?.toISOString(),
      startDate: startDate?.toISOString(),
      statuses,
      photoShootType,
    },
  });
  return queryResult;
}

export default usePhotoShoots;
