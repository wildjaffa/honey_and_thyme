import type { components } from "../api/v1";

export type ImageModel = components["schemas"]["ImageModel"];
export type AlbumModel = components["schemas"]["AlbumModel"];
export type PaginatedAlbumModels =
  components["schemas"]["AlbumModelPaginationResultModel"];
export type DownloadRequest = components["schemas"]["DownloadRequest"];
export type DownloadResponse = components["schemas"]["DownloadResponse"];
