import { faLock, faUnlock } from "@fortawesome/free-solid-svg-icons";
import { HoneyIconButton, HoneyImage } from "../../../components";
import ImageSize from "../../../enums/imageSize";
import useImageUrl from "../../../hooks/useImageUrl";
import type { AlbumModel } from "../../../types/api";
import { useNavigate } from "react-router";
import apiClient from "../../../api/client";
import { toast } from "react-toastify";
import CopyLinkAlbum from "./CopyLinkButton";

interface AlbumRowProps {
  album: AlbumModel;
  onUpdated: () => void;
}

function AlbumRow({ album, onUpdated }: AlbumRowProps) {
  const navigate = useNavigate();
  const albumCoverUrl = useImageUrl(
    album.coverImageId,
    ImageSize.small,
    album?.password,
  );
  const unlockMutation = apiClient.useMutation("post", "/albums/unlock");

  const handleUnlock = async () => {
    try {
      await unlockMutation.mutateAsync({ body: album });
      toast.success("Album unlocked");
      onUpdated();
    } catch (ex) {
      console.error(ex);
      toast.error("There was a problem unlocking the album");
    }
  };

  return (
    <div
      key={album.albumId}
      className="flex cursor-pointer items-center gap-4 rounded border p-2 hover:shadow"
      onClick={() => {
        navigate(`${album.albumId}`);
      }}
    >
      <div className="flex h-12 w-12 items-center justify-center overflow-hidden rounded bg-gray-100">
        {album.coverImageId ? (
          <HoneyImage src={albumCoverUrl} />
        ) : (
          <div className="text-gray-400">No image</div>
        )}
      </div>

      <div className="min-w-0 flex-1">
        <div className="im-fell-english truncate text-sm font-medium">
          {album.name}
        </div>
        <div className="im-fell-english truncate text-xs text-gray-500">
          {album.description}
        </div>
      </div>

      <div className="flex items-center gap-2">
        <HoneyIconButton
          icon={album.isLocked ? faLock : faUnlock}
          onClick={handleUnlock}
          title="Lock/Unlock"
          disabled={!album.isLocked}
          opacityOnHover={false}
          isSelected
        />
        <CopyLinkAlbum album={album} />
      </div>
    </div>
  );
}
export default AlbumRow;
