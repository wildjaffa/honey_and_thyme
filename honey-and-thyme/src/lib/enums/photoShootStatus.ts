const PhotoShootStatusMap: Record<0 | 1 | 2 | 3 | 4 | 5 | 6, string> = {
  0: "Unbooked",
  1: "Scheduled",
  2: "Booked",
  3: "Confirmed",
  4: "Paid",
  5: "Delivered",
  6: "Deleted",
};

const PhotoShootStatusEnum = {
  Unbooked: 0,
  Scheduled: 1,
  Booked: 2,
  Confirmed: 3,
  Paid: 4,
  Delivered: 5,
  Deleted: 6,
} as const;

export type PhotoShootStatus =
  (typeof PhotoShootStatusEnum)[keyof typeof PhotoShootStatusEnum];

export default PhotoShootStatusMap;
export { PhotoShootStatusEnum };
