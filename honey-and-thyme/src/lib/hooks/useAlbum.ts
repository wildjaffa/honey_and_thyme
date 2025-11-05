import apiClient from "../api/client";

function useAlbum(albumName?: string, password?: string) {
  // if (password !== undefined)
  //   localStorage.setItem(`album-password-${albumName}`, password ?? "");
  // else password = localStorage.getItem(`album-password-${albumName}`) ?? "";

  return apiClient.useQuery("get", "/albums/{id}", {
    params: {
      path: { id: albumName ?? "" },
      query: { password: password !== "" ? password : undefined },
    },
  });
}

export default useAlbum;
