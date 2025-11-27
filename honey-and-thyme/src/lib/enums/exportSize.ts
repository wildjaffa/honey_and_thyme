const ExportSize = {
  FullRes: 0,
  Large: 1,
  Medium: 2,
  Small: 3,
  ExtraLarge: 4,
} as const;

export type ExportSize = (typeof ExportSize)[keyof typeof ExportSize];

export default ExportSize;
