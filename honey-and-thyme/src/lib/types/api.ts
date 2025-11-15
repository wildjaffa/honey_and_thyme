import type { components } from "../api/v1";

export type AlbumModel = components["schemas"]["AlbumModel"];
export type DownloadRequest = components["schemas"]["DownloadRequest"];
export type DownloadResponse = components["schemas"]["DownloadResponse"];
export type ImageModel = components["schemas"]["ImageModel"];
export type PaginatedAlbumModels =
  components["schemas"]["AlbumModelPaginationResultModel"];
export type ProductModel = components["schemas"]["ProductModel"];

export type { default as PaginationResult } from "./paginationResult";
