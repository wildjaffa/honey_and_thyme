import { useParams } from "react-router";
import { useEffect, useState } from "react";
import { HoneyGallery } from "../../components";
import useAlbum from "../../hooks/useAlbum";
import { useHeader } from "../../hooks/useHeader";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCircleDown } from "@fortawesome/free-solid-svg-icons";

//Check out your album at https://honeyandthymephotography.com/#/albums/pumpkin-patch and use password 592818

function AlbumGallery() {
  const { setToolbarItems } = useHeader();
  const [selectedImages, setSelectedImages] = useState<string[]>([]);
  const params = useParams();
  const albumId = params.albumId;
  const password = "";
  const {
    data: album,
    isLoading,
    isError,
    error,
  } = useAlbum(albumId, password);

  function onImageSelected(imageId: string) {
    setSelectedImages((prevSelectedImages: string[]) => {
      if (prevSelectedImages.includes(imageId)) {
        // Deselect image
        return prevSelectedImages.filter((id) => id !== imageId);
      } else {
        // Select image
        return [...prevSelectedImages, imageId];
      }
    });
  }

  useEffect(() => {
    setToolbarItems(
      <div className="flex gap-2">
        <button onClick={() => console.log("Download All")}>
          <FontAwesomeIcon className="text-2xl" icon={faCircleDown} />
        </button>
      </div>,
    );
    return () => setToolbarItems(null); // Cleanup when component unmounts
  }, [setToolbarItems]);
  if (isError && error) {
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
  return (
    <HoneyGallery
      album={album}
      isLoading={isLoading}
      selectedImages={selectedImages}
      onImageSelected={onImageSelected}
    />
  );
}

export default AlbumGallery;
