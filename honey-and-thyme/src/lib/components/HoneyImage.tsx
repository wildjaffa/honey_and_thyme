import { useState } from "react";
import useImageUrl from "../hooks/useImageUrl";
import type { ImageModel } from "../types/api";

interface HoneyImageProps {
  image: ImageModel;
  pixelWidth: number;
  alt?: string;
  className?: string;
  onTapped?: () => void;
  onSelected?: () => void;
  isSelected?: boolean;
  imageQuality: number;
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
}: HoneyImageProps) {
  const [loaded, setLoaded] = useState(false);
  const [hoveringSelector, setHoveringSelector] = useState(false);

  const url = useImageUrl(image.imageId, imageQuality);

  const containerStyle: React.CSSProperties = {
    width: `${pixelWidth}px`,
    height: `${pixelWidth / (image.metaData?.aspectRatio || 1)}px`,
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
        onLoad={() => setLoaded(true)}
        className={`h-full w-full object-cover transition-opacity duration-1000 ease-out ${
          loaded ? "opacity-100" : "opacity-0"
        }`}
        style={{ display: "block" }}
      />

      {/* Gradient overlay that appears on hover */}
      <div className="pointer-events-none absolute inset-0 bg-linear-to-t from-black/30 to-transparent opacity-0 transition-opacity duration-200 group-hover:opacity-100" />

      {/* Selector icon (top-right) */}
      {typeof isSelected !== "undefined" && (
        <div className="absolute top-2 right-2">
          <button
            onClick={(e) => {
              e.stopPropagation();
              onSelected?.();
            }}
            onMouseEnter={() => setHoveringSelector(true)}
            onMouseLeave={() => setHoveringSelector(false)}
            aria-label={isSelected ? "Deselect image" : "Select image"}
            className="rounded-full p-1 focus:outline-none"
            style={{
              // Make the button background slightly visible so icon is clickable on any image
              background: "rgba(0,0,0,0.0)",
            }}
          >
            {/* Inline SVG check-circle; color changes when selected or hover */}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              width="26"
              height="26"
              fill={
                isSelected
                  ? "#D4AF37" // gold-ish
                  : hoveringSelector
                    ? "#ec4899" // pink-500
                    : "rgba(236,72,153,0.5)"
              }
            >
              <path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm-1 14.2-4.2-4.2 1.4-1.4L11 13.4l5.8-5.8 1.4 1.4L11 16.2z" />
            </svg>
          </button>
        </div>
      )}
    </div>
  );
}

export default HoneyFadeInImage;
