const PhotoShootType = {
  customBooking: 0,
  calendarBooking: 1,
} as const;

export type PhotoShootType =
  (typeof PhotoShootType)[keyof typeof PhotoShootType];

export default PhotoShootType;
