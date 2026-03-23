import { getEnv } from "../utils/env";

function useImageUrl(
  imageId: string | undefined | null,
  size: number,
  password: string | undefined | null = undefined,
): string {
  if (!imageId) return "";
  const baseUrl = getEnv("BASE_URL");
  return `${baseUrl}/thumb/${size}/${imageId}?${password ? `password=${encodeURIComponent(password)}` : ""}`;
}

export default useImageUrl;
