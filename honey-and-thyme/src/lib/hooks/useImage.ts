import apiClient from "../api/client";

function useAlbum(albumName?: string, password?: string) {
  if (password !== undefined)
    localStorage.setItem(`album-password-${albumName}`, password ?? "");
  else password = localStorage.getItem(`album-password-${albumName}`) ?? "";

  const queryResult = apiClient.useQuery(
    "get",
    "/api/image/{imageId}",
    {
      params: {
        path: { imageId: albumName ?? "" },
      },
    },
    { retry: false },
  );
  return { ...queryResult, password };
}

export default useAlbum;
