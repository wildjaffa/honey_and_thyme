import useImageUrl from "../hooks/useImageUrl";
import type { ImageModel } from "../types/api";

interface HoneyImageProps {
  image?: ImageModel;
  imageQuality?: number;
  password?: string | null;
  src?: string;
}

function HoneyImage({ image, imageQuality, password, src }: HoneyImageProps) {
  const imageUrl = useImageUrl(image?.imageId, imageQuality ?? 3, password);
  return (
    <img
      className="max-h-screen object-contain"
      src={src ?? imageUrl}
      alt={image?.fileName ?? "Photo"}
    />
  );
}

export default HoneyImage;
