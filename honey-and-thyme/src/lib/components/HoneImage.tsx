import useImageUrl from "../hooks/useImageUrl";
import type { ImageModel } from "../types/api";

interface HoneyImageProps {
    image: ImageModel;
    imageQuality: number;
}

function HoneyImage({ image, imageQuality }: HoneyImageProps) {
    const imageUrl = useImageUrl(image.imageId, imageQuality);
    return <img className="object-contain max-h-screen" src={imageUrl} alt={image.fileName ?? "Photo"} />;
}

export default HoneyImage;