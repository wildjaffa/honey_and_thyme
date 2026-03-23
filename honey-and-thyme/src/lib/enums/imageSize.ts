const ImageSize = {
  extraLarge: 0,
  large: 1,
  big: 2,
  medium: 3,
  preview: 4,
  small: 5,
} as const;

export type ImageSize = (typeof ImageSize)[keyof typeof ImageSize];

export default ImageSize;
