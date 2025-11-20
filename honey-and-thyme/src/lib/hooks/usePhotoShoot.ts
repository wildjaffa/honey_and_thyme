import apiClient from "../api/client";

function usePhotoShoot(id?: string) {
  const queryResult = apiClient.useQuery("get", "/api/PhotoShoot/{id}", {
    params: {
      path: {
        id: id ?? "",
      },
    },
  });
  return queryResult;
}

export default usePhotoShoot;
