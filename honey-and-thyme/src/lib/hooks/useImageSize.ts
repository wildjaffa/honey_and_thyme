import type { ImageModel } from "../types/api";

interface ImageSize {
    width: number;
    height: number;
}

function useImageSize(image?: ImageModel, imageWidth?: number | null, imageHeight?: number | null): ImageSize {
    const aspectRatio = image?.metaData?.aspectRatio;
    if (!aspectRatio) {
        return { width: imageWidth ?? imageHeight ?? 100, height: imageHeight ?? imageWidth ?? 100 };
    }
    if (imageWidth && !imageHeight) {
        return { width: imageWidth, height: Math.round(imageWidth / aspectRatio) };
    }
    if (!imageWidth && imageHeight) {
        return { width: Math.round(imageHeight * aspectRatio), height: imageHeight };
    }
    if (imageWidth && imageHeight) return { width: imageWidth, height: imageHeight };
    // fallback to width 150
    return { width: 150, height: Math.round(150 / aspectRatio) };
}
export default useImageSize;