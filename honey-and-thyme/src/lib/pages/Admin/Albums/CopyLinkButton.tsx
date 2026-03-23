import { faShare } from "@fortawesome/free-solid-svg-icons";
import { HoneyIconButton } from "../../../components";
import { toast } from "react-toastify";
import type { AlbumModel } from "../../../types/api";

interface CopyLinkAlbumProps {
  album: AlbumModel;
}

function CopyLinkAlbum({ album }: CopyLinkAlbumProps) {
  const handleShare = () => {
    const url = `${window.origin}/albums/${album.urlName}`;
    let text = `Check out your album at ${url}`;
    if (album.password) {
      text += ` and use password ${album.password}`;
    }
    try {
      navigator.clipboard.writeText(text);
      toast.success("Album linked saved to clipboard");
    } catch (ex) {
      console.error(ex);
      toast.error("Sorry, there was a problem copying to the clipboard");
    }
  };

  return (
    <HoneyIconButton
      icon={faShare}
      onClick={handleShare}
      title="Copy Share link"
      opacityOnHover={true}
      isSelected
    />
  );
}

export default CopyLinkAlbum;
