/**
 * Utility functions for HoneyIconButton className and style generation
 * Static Tailwind classes are literal strings.
 * Dynamic colors are handled via inline styles to avoid bundler issues.
 */

type ButtonSize = "small" | "medium" | "large";
type ButtonBackground = "gold" | "sage" | "white";

// Color palette mapping - use actual CSS color values instead of Tailwind classes
const colorPalette: Record<string, string> = {
  "honey-gold": "var(--color-honey-gold)",
  "honey-pink": "var(--color-honey-pink)",
  "honey-sage": "var(--color-honey-sage)",
};

/**
 * Generates base button classes based on background and size
 * Returns only Tailwind classes (structural styles)
 */
export const getButtonClasses = (background?: ButtonBackground): string => {
  const baseClasses =
    "group/icon relative cursor-pointer overflow-visible rounded-full p-1 focus:outline-none";

  const backgroundClasses: Record<ButtonBackground, string> = {
    gold: "bg-honey-gold hover:bg-honey-gold/60",
    sage: "bg-honey-sage hover:bg-honey-sage/60",
    white: "bg-white hover:bg-gray-100",
  };

  return [baseClasses, background ? backgroundClasses[background] : ""]
    .filter(Boolean)
    .join(" ");
};

/**
 * Generates icon wrapper size classes
 */
export const getIconWrapperClasses = (size: ButtonSize = "medium"): string => {
  const sizeClasses: Record<ButtonSize, string> = {
    small: "size-6",
    medium: "size-7",
    large: "size-10",
  };

  return `relative flex items-center justify-center ${sizeClasses[size]}`;
};

/**
 * Generates icon color classes - structural only
 * Color values should be applied via inline styles
 */
export const getIconClasses = (
  size: ButtonSize = "medium",
  opacityOnHover?: boolean,
): string => {
  const sizeClasses: Record<ButtonSize, string> = {
    small: "text-sm",
    medium: "text-xl",
    large: "text-2xl",
  };

  const opacityClass = opacityOnHover
    ? "opacity-50 group-hover/icon:opacity-100"
    : "";

  return [sizeClasses[size], opacityClass].filter(Boolean).join(" ");
};

/**
 * Returns inline style object for icon color
 * This bypasses Tailwind's dynamic class limitation
 */
export const getIconColorStyle = (
  isSelected: boolean | undefined,
  selectedColor: string,
  nonSelectedColor: string,
): Record<string, string> => {
  const colorValue = isSelected
    ? colorPalette[selectedColor] || selectedColor
    : colorPalette[nonSelectedColor] || nonSelectedColor;

  return {
    color: colorValue,
  };
};
