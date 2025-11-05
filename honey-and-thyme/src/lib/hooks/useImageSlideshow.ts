import { useEffect, useState } from "react";
import type { ImageModel } from "../types/api";
import useImageUrl from "./useImageUrl";
import ImageSize from "../enums/imageSize";

interface UseImageSlideshowProps {
  images: ImageModel[];
  initialIndex?: number;
  onClose?: () => void;
}

export default function useImageSlideshow({
  images,
  initialIndex = 0,
  onClose,
}: UseImageSlideshowProps) {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [isOpen, setIsOpen] = useState(false);

  const currentImage = images[currentIndex];
  const imageUrl = useImageUrl(currentImage?.imageId, ImageSize.large); // Large size

  const showNext = () => {
    if (currentIndex < images.length - 1) {
      setCurrentIndex((prev) => prev + 1);
    } else {
      setCurrentIndex(0);
    }
  };

  const showPrevious = () => {
    if (currentIndex > 0) {
      setCurrentIndex((prev) => prev - 1);
    } else {
      setCurrentIndex(images.length - 1);
    }
  };

  const close = () => {
    setIsOpen(false);
    onClose?.();
  };

  const open = (index: number) => {
    setCurrentIndex(index);
    setIsOpen(true);
  };

  useEffect(() => {
    setCurrentIndex(initialIndex);
  }, [initialIndex]);

  return {
    isOpen,
    currentIndex,
    currentImage,
    imageUrl,
    showNext,
    showPrevious,
    close,
    open,
  };
}
