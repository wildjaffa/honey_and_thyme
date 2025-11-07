import useImageUrl from "../hooks/useImageUrl";
import type { ImageModel } from "../types/api";

interface HoneyImageProps {
  image: ImageModel;
  imageQuality: number;
  password?: string;
}

function HoneyImage({ image, imageQuality, password }: HoneyImageProps) {
  const imageUrl = useImageUrl(image.imageId, imageQuality, password);
  return (
    <img
      className="max-h-screen object-contain"
      src={imageUrl}
      alt={image.fileName ?? "Photo"}
    />
  );
}

export default HoneyImage;
