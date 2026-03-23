import Masonry, { ResponsiveMasonry } from "react-responsive-masonry";
import { useWindowWidth } from "@react-hook/window-size";
import { useState } from "react";
import { HoneyImageSlideshow, HoneyFadeInImage } from ".";
import type { AlbumModel } from "../types/api";
import ImageSize from "../enums/imageSize";

interface HoneyGalleryProps {
  album: AlbumModel;
  selectedImages?: string[]; // array of image IDs to display only these images
  onImageSelected?: (imageId: string) => void; // callback when an image is selected
  password?: string | null;
}

function HoneyGallery({
  album,
  selectedImages,
  onImageSelected,
  password,
}: HoneyGalleryProps) {
  const [slideShowIsOpen, setSlideShowIsOpen] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const width = useWindowWidth();
  let pictureWidth = 200;
  let imageQuality: (typeof ImageSize)[keyof typeof ImageSize] =
    ImageSize.medium;
  if (width >= 1200) {
    pictureWidth = Math.floor(width / 5) - 5;
    imageQuality = ImageSize.large;
  } else if (width >= 900) {
    pictureWidth = Math.floor(width / 4) - 5;
    imageQuality = ImageSize.large;
  } else if (width >= 750) {
    imageQuality = ImageSize.large;
    pictureWidth = Math.floor(width / 3) - 5;
  } else if (width >= 350) {
    pictureWidth = Math.floor(width / 2) - 5;
    imageQuality = ImageSize.medium;
  }

  if (!album?.images?.length) {
    return (
      <div className="flex h-screen items-center justify-center">
        <p>No images found</p>
      </div>
    );
  }

  return (
    <div>
      <ResponsiveMasonry
        columnsCountBreakPoints={{ 350: 2, 750: 3, 900: 4, 1200: 5 }}
      >
        <Masonry
          style={{ gap: "5px" }}
          itemStyle={{ gap: "5px" }}
          sequential={true}
        >
          {album.images.map((image, index) => (
            <div key={image.imageId ?? index}>
              <HoneyFadeInImage
                pixelWidth={pictureWidth}
                image={image}
                onTapped={() => {
                  setSlideShowIsOpen(true);
                  setCurrentImageIndex(index);
                }}
                imageQuality={imageQuality}
                isSelected={
                  image.imageId !== undefined &&
                  selectedImages &&
                  selectedImages.includes(image.imageId)
                }
                onSelected={onImageSelected}
                password={password}
              />
            </div>
          ))}
        </Masonry>
      </ResponsiveMasonry>

      {/* Slideshow */}
      <HoneyImageSlideshow
        isOpen={slideShowIsOpen}
        images={album.images}
        currentIndex={currentImageIndex}
        onClose={() => setSlideShowIsOpen(false)}
        password={password}
      />
    </div>
  );
}

export default HoneyGallery;
