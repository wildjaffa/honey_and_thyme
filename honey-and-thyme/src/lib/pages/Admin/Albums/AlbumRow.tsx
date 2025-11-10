import { HoneyImage } from "../../../components";
import ImageSize from "../../../enums/imageSize";
import useImageUrl from "../../../hooks/useImageUrl";
import type { AlbumModel } from "../../../types/api";

interface AlbumRowProps {
  album: AlbumModel;
}

function AlbumRow({ album }: AlbumRowProps) {
  const albumCoverUrl = useImageUrl(
    album.coverImageId,
    ImageSize.small,
    album?.password,
  );
  function handleUnlock(album: AlbumModel) {
    console.log(album);
    throw new Error("Function not implemented.");
  }

  function handleShare(album: AlbumModel) {
    console.log(album);
    throw new Error("Function not implemented.");
  }

  return (
    <div
      key={album.albumId}
      className="flex cursor-pointer items-center gap-4 rounded border p-2 hover:shadow"
      onClick={() => {
        window.location.hash = `#/admin/albums/edit?albumId=${album.albumId}`;
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
        <div className="truncate text-sm font-medium">{album.name}</div>
        <div className="truncate text-xs text-gray-500">
          {album.description}
        </div>
      </div>

      <div className="flex items-center gap-2">
        <button
          title={album.isLocked ? "Unlock" : "Unlocked"}
          onClick={(e) => {
            e.stopPropagation();
            if (album.isLocked) handleUnlock(album);
          }}
          className={`rounded p-1 ${album.isLocked ? "bg-yellow-100" : "bg-green-100"}`}
        >
          {album.isLocked ? "🔒" : "🔓"}
        </button>
        <button
          title="Share"
          onClick={(e) => {
            e.stopPropagation();
            handleShare(album);
          }}
          className="rounded bg-gray-100 p-1"
        >
          📤
        </button>
      </div>
    </div>
  );
}
export default AlbumRow;
