/**
 * Get environment variable value
 *
 * In production (Docker container), reads from window.ENV which is injected at runtime.
 * In development, falls back to import.meta.env from Vite.
 *
 * @param key - Environment variable name (without VITE_ prefix)
 * @returns The environment variable value, or undefined if not found
 */

declare global {
  interface Window {
    ENV?: Record<string, string>;
  }
}

export function getEnv(key: string): string | undefined {
  // Try window.ENV first (runtime config from Docker)
  if (typeof window !== "undefined" && window.ENV && key in window.ENV) {
    return window.ENV[key];
  }

  // Fall back to Vite's import.meta.env (development)
  const viteKey = `VITE_${key}`;
  return import.meta.env[viteKey];
}
