import ImageSize from "../enums/imageSize";
import { useState } from "react";
import HoneyModal from "./HoneyModal";

interface ImageQualityOption {
  value: number;
  label: string;
  description: string;
}

const QUALITY_OPTIONS: ImageQualityOption[] = [
  {
    value: ImageSize.extraLarge,
    label: "Original",
    description: "Full resolution, perfect for printing",
  },
  {
    value: ImageSize.large,
    label: "High",
    description: "Excellent quality for digital displays",
  },
  {
    value: ImageSize.medium,
    label: "Medium",
    description: "Good balance of quality and file size",
  },
  {
    value: ImageSize.small,
    label: "Low",
    description: "Smaller file size, suitable for web sharing",
  },
];

interface HoneyQualitySelectorProps {
  isOpen: boolean;
  onClose: () => void;
  onSelect: (quality: number) => void;
  selectedImagesCount?: number;
}

function HoneyQualitySelector({
  isOpen,
  onClose,
  onSelect,
  selectedImagesCount,
}: HoneyQualitySelectorProps) {
  const [selectedQuality, setSelectedQuality] = useState<number>(
    ImageSize.large,
  );
  if (!isOpen) return null;

  return (
    <HoneyModal onClose={onClose} onSubmit={() => onSelect(selectedQuality)}>
      <h2 className="mb-4 text-xl font-semibold">
        {selectedImagesCount
          ? `Download ${selectedImagesCount} Images`
          : "Download Album"}
      </h2>
      <p className="mb-6 text-gray-600">Select download quality:</p>
      <div className="space-y-4">
        {QUALITY_OPTIONS.map((option) => (
          <button
            key={option.value}
            className={`hover:border-honey-gold hover:bg-honey-gold/5 w-full cursor-pointer rounded-lg border border-gray-200 p-4 text-left ${selectedQuality === option.value ? "border-honey-gold bg-honey-gold/5" : ""}`}
            onClick={() => {
              setSelectedQuality(option.value);
            }}
          >
            <div className="font-medium">{option.label}</div>
            <div className="text-sm text-gray-600">{option.description}</div>
          </button>
        ))}
      </div>
    </HoneyModal>
  );
}

export default HoneyQualitySelector;
