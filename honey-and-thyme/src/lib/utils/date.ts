export type DateInput = string | number | Date | null | undefined;

/**
 * Formats a date using Intl.DateTimeFormat.
 * @param date The date to format.
 * @param options Intl.DateTimeFormatOptions.
 * @returns Formatted date string or "N/A" if invalid.
 */
export function formatDate(
  date: DateInput,
  options: Intl.DateTimeFormatOptions = {
    year: "numeric",
    month: "short",
    day: "numeric",
  },
): string {
  const d = parseDate(date);
  if (!d) return "N/A";
  return new Intl.DateTimeFormat("en-US", options).format(d);
}

/**
 * Formats a date as a relative time string (e.g., "2 hours ago").
 * @param date The date to format.
 * @returns Relative time string.
 */
export function formatRelativeTime(date: DateInput): string {
  const d = parseDate(date);
  if (!d) return "N/A";

  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - d.getTime()) / 1000);
  const rtf = new Intl.RelativeTimeFormat("en", { numeric: "auto" });

  if (Math.abs(diffInSeconds) < 60) {
    return rtf.format(-diffInSeconds, "second");
  }

  const diffInMinutes = Math.floor(diffInSeconds / 60);
  if (Math.abs(diffInMinutes) < 60) {
    return rtf.format(-diffInMinutes, "minute");
  }

  const diffInHours = Math.floor(diffInMinutes / 60);
  if (Math.abs(diffInHours) < 24) {
    return rtf.format(-diffInHours, "hour");
  }

  const diffInDays = Math.floor(diffInHours / 24);
  if (Math.abs(diffInDays) < 30) {
    return rtf.format(-diffInDays, "day");
  }

  const diffInMonths = Math.floor(diffInDays / 30);
  if (Math.abs(diffInMonths) < 12) {
    return rtf.format(-diffInMonths, "month");
  }

  const diffInYears = Math.floor(diffInDays / 365);
  return rtf.format(-diffInYears, "year");
}

/**
 * Checks if a value is a valid date.
 * @param date The value to check.
 * @returns True if valid, false otherwise.
 */
export function isValidDate(date: any): boolean {
  const d = parseDate(date);
  return d !== null;
}

/**
 * Adds days to a date.
 * @param date The starting date.
 * @param days Number of days to add.
 * @returns New Date object.
 */
export function addDays(date: DateInput, days: number): Date {
  const d = parseDate(date) || new Date();
  const result = new Date(d);
  result.setDate(result.getDate() + days);
  return result;
}

/**
 * Returns the start of the day for a given date.
 * @param date The date.
 * @returns Date object set to 00:00:00.000.
 */
export function startOfDay(date: DateInput): Date {
  const d = parseDate(date) || new Date();
  const result = new Date(d);
  result.setHours(0, 0, 0, 0);
  return result;
}

/**
 * Returns the end of the day for a given date.
 * @param date The date.
 * @returns Date object set to 23:59:59.999.
 */
export function endOfDay(date: DateInput): Date {
  const d = parseDate(date) || new Date();
  const result = new Date(d);
  result.setHours(23, 59, 59, 999);
  return result;
}

/**
 * Parses a date input into a Date object.
 * @param date The input to parse.
 * @returns Date object or null if invalid.
 */
export function parseDate(date: DateInput): Date | null {
  if (date === null || date === undefined) return null;
  const d = new Date(date);
  return isNaN(d.getTime()) ? null : d;
}

/**
 * Returns a local date time string suitable for inputs or display.
 * Replaces the original getLocalDateTimeStringWithoutSeconds.
 * @param date The date input.
 * @returns ISO-like string in local time.
 */
export function getLocalDateTimeString(date: DateInput): string {
  const d = parseDate(date);
  if (!d) return "";
  
  const offset = d.getTimezoneOffset() * 60000;
  const localISOTime = new Date(d.getTime() - offset).toISOString().slice(0, -1);
  return localISOTime;
}
