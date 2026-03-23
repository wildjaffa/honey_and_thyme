import { HoneyGallery } from "../../components";
import useAlbum from "../../hooks/useAlbum";

function Gallery() {
  const albumId = "gallery"; // params.albumId;
  const password = "";
  const {
    data: album,
    isLoading,
    isError,
    error,
  } = useAlbum(albumId, password);
  if (isError) {
    console.error("Error loading album:", error);
    return (
      <div className="flex h-screen items-center justify-center">
        <p className="text-red-500">Error loading album</p>
      </div>
    );
  }
  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-gray-900" />
      </div>
    );
  }
  if (!album) {
    return (
      <div className="flex h-screen items-center justify-center">
        <p>No album found</p>
      </div>
    );
  }
  return <HoneyGallery album={album} />;
}

export default Gallery;
