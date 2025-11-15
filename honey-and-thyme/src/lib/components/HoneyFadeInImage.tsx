import { useState } from "react";
import useImageUrl from "../hooks/useImageUrl";
import type { ImageModel } from "../types/api";
import { faCircleCheck } from "@fortawesome/free-solid-svg-icons";
import HoneyIconButton from "./HoneyIconButton";

interface HoneyImageProps {
  image: ImageModel;
  pixelWidth: number;
  alt?: string;
  className?: string;
  onTapped?: () => void;
  onSelected?: (imageId: string) => void;
  isSelected?: boolean;
  imageQuality: number;
  password?: string | null;
  fitToRatio?: boolean;
  onLoad?: () => void;
}

/**
 * HoneyImage
 * - shows a shimmer placeholder while loading
 * - fades the image in when loaded
 * - adds a gradient overlay on hover
 * - optional selectable check icon in the top-right
 *
 * Uses Tailwind classes for layout and transitions.
 */
function HoneyFadeInImage({
  image,
  pixelWidth,
  imageQuality,
  isSelected,
  onSelected,
  onTapped,
  className = "",
  alt = "",
  password,
  fitToRatio = true,
  onLoad,
}: HoneyImageProps) {
  const [loaded, setLoaded] = useState(false);

  const url = useImageUrl(image.imageId, imageQuality, password);
  const height = fitToRatio
    ? `${pixelWidth / (image.metaData?.aspectRatio || 1)}px`
    : "";
  const containerStyle: React.CSSProperties = {
    width: `${pixelWidth}px`,
    height: height,
  };

  return (
    <div
      className={`group relative ${className}`}
      style={containerStyle}
      onClick={onTapped}
      role={onTapped ? "button" : undefined}
      aria-pressed={isSelected}
    >
      {/* Shimmer placeholder - use Tailwind animate-pulse */}
      {!loaded && <div className="shimmer absolute inset-0" aria-hidden />}

      {/* Actual image - fades in */}
      <img
        loading="lazy"
        src={url}
        alt={alt ?? ""}
        onLoad={() => {
          setLoaded(true);
          if (onLoad) onLoad();
        }}
        className={`h-full w-full object-cover transition-opacity duration-1000 ease-out ${
          loaded ? "opacity-100" : "opacity-0"
        } ${onTapped ? "cursor-pointer" : ""}`}
        style={{ display: "block" }}
      />

      {/* Gradient overlay that appears on hover */}
      {onTapped && (
        <div className="pointer-events-none absolute inset-0 bg-linear-to-t from-black/30 to-transparent opacity-0 transition-opacity duration-200 group-hover:opacity-100" />
      )}

      {/* Selector icon (top-right) */}
      {typeof isSelected !== "undefined" && (
        <div className="absolute top-2 right-2">
          <HoneyIconButton
            title={isSelected ? "Deselect image" : "Select image"}
            icon={faCircleCheck}
            onClick={() => {
              if (onSelected && image.imageId) {
                onSelected(image.imageId);
              }
            }}
            isSelected={isSelected}
            ariaLabel={isSelected ? "Deselect image" : "Select image"}
            opacityOnHover
          />
        </div>
      )}
    </div>
  );
}

export default HoneyFadeInImage;
