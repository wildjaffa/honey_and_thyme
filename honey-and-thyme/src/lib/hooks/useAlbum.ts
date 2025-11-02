import apiClient from "../api/client";

function useAlbum(albumName: string, password?: string) {
    return apiClient.useQuery('get', '/albums/{id}', {
        params: { path: { id: albumName }, query: { password } }
    });
}

export default useAlbum;