import { useParams } from "react-router";
import useAlbum from "../../../hooks/useAlbum";
import {
  HoneyButton,
  HoneyGallery,
  HoneyModal,
  HoneyPageLoader,
} from "../../../components";
import AlbumImageUpload from "./AlbumImageUpload";
import AlbumEdit from "./AlbumEdit";
import { useState } from "react";
import HoneyAlbumPicker from "../../../components/HoneyAlbumPicker";
import AlbumImagesDelete from "./AlbumImagesDelete";
import apiClient from "../../../api/client";
import { toast } from "react-toastify";
import CopyLinkAlbum from "./CopyLinkButton";

function AlbumImageManagement() {
  const params = useParams();
  const albumId = params.albumId;
  const { data, isLoading, refetch } = useAlbum(albumId);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [selectedImages, setSelectedImages] = useState<string[]>([]);
  const [selectedAlbum, setSelectedAlbum] = useState<string | undefined>(
    undefined,
  );
  const scanAlbumMutation = apiClient.useMutation("post", "/albums/QueueScan");
  const scanAlbum = async () => {
    if (!data) return;
    try {
      await scanAlbumMutation.mutateAsync({ body: album });
      toast.success("Album Queued for scanning successfully");
    } catch (e) {
      console.error(e);
      toast.error("Something went wrong scanning the album");
    }
  };

  const updateAlbumMutation = apiClient.useMutation("post", "/albums/update");
  const updateCoverPhoto = async () => {
    if (selectedImages.length == 0 || !album) return;
    try {
      album.coverImageId = selectedImages[0];
      await updateAlbumMutation.mutateAsync({ body: album });
      setSelectedImages([]);
      toast.success("Successfully updated cover photo");
      refetch();
    } catch (ex) {
      console.error(ex);
      toast.error("There was a problem updating the cover photo");
    }
  };

  const copyImagesMutation = apiClient.useMutation(
    "post",
    "/albums/AddExistingImages",
  );
  const copyImagesToOtherAlbum = async () => {
    if (selectedImages.length == 0 || !album || !selectedAlbum) return;
    try {
      await copyImagesMutation.mutateAsync({
        body: {
          albumId: selectedAlbum,
          imageIds: selectedImages,
        },
      });
      setSelectedImages([]);
      toast.success("Successfully copied the images to album");
    } catch (ex) {
      console.error(ex);
      toast.error("There was a problem copying the images to the album");
    }
  };

  const onAfterDelete = () => {
    setSelectedImages([]);
    refetch();
  };

  const onImageSelected = (imageId: string) => {
    setSelectedImages((prevSelectedImages: string[]) => {
      if (prevSelectedImages.includes(imageId)) {
        // Deselect image
        return prevSelectedImages.filter((id) => id !== imageId);
      } else {
        // Select image
        return [...prevSelectedImages, imageId];
      }
    });
  };
  const album = data;
  if (isLoading) {
    return <HoneyPageLoader />;
  }

  if (!album) {
    return <>OOPS!</>;
  }

  return (
    <>
      <div className="im-fell-english w-full text-center">
        <div>{album.name}</div>
        <div>{album.description}</div>
        <div>There are {album.images?.length ?? 0} pictures in this album</div>
      </div>
      <div className="grid grid-flow-row grid-cols-12 grid-rows-2 gap-4">
        <div className="col-span-1"></div>
        <div className="col-span-2 content-center">
          <HoneyButton onClick={() => setEditModalOpen(true)}>
            Edit Album
          </HoneyButton>
        </div>
        <div className="col-span-2 content-center">
          <AlbumImageUpload
            albumId={album.albumId ?? ""}
            onUploadComplete={refetch}
          />
        </div>
        <div className="col-span-2 content-center">
          <HoneyButton onClick={scanAlbum}>Scan Album</HoneyButton>
        </div>
        <div className="col-span-4 content-center">
          <HoneyAlbumPicker
            onAlbumSelected={(albumId) => setSelectedAlbum(albumId)}
          />
        </div>
        <div className="col-span-1"></div>
        <div className="col-span-6"></div>
        <div className="col-span-1 content-center">
          <AlbumImagesDelete
            onAfterDelete={onAfterDelete}
            imageIds={selectedImages}
          />
          <CopyLinkAlbum album={album} />
        </div>
        <div className="col-span-2 content-center">
          <HoneyButton
            onClick={updateCoverPhoto}
            disabled={selectedImages.length != 1}
          >
            Mark as Cover Photo
          </HoneyButton>
        </div>
        <div className="col-span-2 content-center">
          <HoneyButton
            onClick={copyImagesToOtherAlbum}
            disabled={!selectedAlbum || selectedImages.length == 0}
          >
            Add to Other Album
          </HoneyButton>
        </div>
      </div>
      <HoneyGallery
        album={album}
        password={album.password}
        selectedImages={selectedImages}
        onImageSelected={onImageSelected}
      />
      <HoneyModal
        isOpen={editModalOpen}
        onClose={() => setEditModalOpen(false)}
      >
        <AlbumEdit
          album={album}
          onAfterSave={() => {
            refetch();
            setEditModalOpen(false);
          }}
          onCancel={() => setEditModalOpen(false)}
        />
      </HoneyModal>
    </>
  );
}

export default AlbumImageManagement;
