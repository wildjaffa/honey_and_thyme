function useImageUrl(
  imageId: string | undefined | null,
  size: number,
  password: string | undefined = undefined,
): string {
  if (!imageId) return "";
  const baseUrl = import.meta.env.VITE_BASE_URL;
  return `${baseUrl}/thumb/${size}/${imageId}?${password ? `password=${encodeURIComponent(password)}` : ""}`;
}

export default useImageUrl;
