import {
  formatDate,
  formatRelativeTime,
  isValidDate,
  addDays,
  startOfDay,
  endOfDay,
  parseDate,
  getLocalDateTimeString,
} from "./date";

console.log("Running date utility verification...");

const now = new Date();
const yesterday = new Date(now);
yesterday.setDate(now.getDate() - 1);

// Test formatDate
console.log("formatDate(now):", formatDate(now));
console.log("formatDate(null):", formatDate(null));

// Test formatRelativeTime
console.log("formatRelativeTime(yesterday):", formatRelativeTime(yesterday));

// Test isValidDate
console.log("isValidDate(now):", isValidDate(now));
console.log("isValidDate('invalid'):", isValidDate("invalid"));

// Test addDays
const tomorrow = addDays(now, 1);
console.log("addDays(now, 1):", tomorrow.toISOString());

// Test startOfDay
console.log("startOfDay(now):", startOfDay(now).toISOString());

// Test endOfDay
console.log("endOfDay(now):", endOfDay(now).toISOString());

// Test parseDate
console.log("parseDate('2023-01-01'):", parseDate("2023-01-01")?.toISOString());

// Test getLocalDateTimeString
console.log("getLocalDateTimeString(now):", getLocalDateTimeString(now));

console.log("Verification complete.");
