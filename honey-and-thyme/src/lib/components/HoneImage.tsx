import useImageUrl from "../hooks/useImageUrl";
import type { ImageModel } from "../types/api";

interface HoneyImageProps {
  image: ImageModel;
  imageQuality: number;
}

function HoneyImage({ image, imageQuality }: HoneyImageProps) {
  const imageUrl = useImageUrl(image.imageId, imageQuality);
  return (
    <img
      className="max-h-screen object-contain"
      src={imageUrl}
      alt={image.fileName ?? "Photo"}
    />
  );
}

export default HoneyImage;
