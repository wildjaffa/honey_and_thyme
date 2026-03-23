import apiClient from "../api/client";

function useAlbum(albumName?: string, password?: string) {
  if (password !== undefined)
    localStorage.setItem(`album-password-${albumName}`, password ?? "");
  else password = localStorage.getItem(`album-password-${albumName}`) ?? "";

  const queryResult = apiClient.useQuery(
    "get",
    "/albums/{id}",
    {
      params: {
        path: { id: albumName ?? "" },
        query: { password: password !== "" ? password : undefined },
      },
    },
    { retry: false },
  );
  return { ...queryResult, password };
}

export default useAlbum;
