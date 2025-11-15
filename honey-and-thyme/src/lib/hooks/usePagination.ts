import { useCallback, useEffect, useRef, useState } from "react";
import type PaginationResult from "../types/paginationResult";

export type DataFetchCallback<T> = (
  page: number,
  pageSize: number,
) => Promise<T | null | undefined>;

interface UsePaginationOptions<T> {
  pageSize?: number;
  pageNumber?: number;
  fetchCallback?: DataFetchCallback<PaginationResult<T>>;
  // If true, automatically load when page or pageSize changes
  autoLoad?: boolean;
}

function usePagination<T>({
  pageNumber = 0,
  pageSize: initialPageSize = 10,
  fetchCallback,
  autoLoad = true,
}: UsePaginationOptions<T> = {}) {
  const [pageIndex, setPageIndex] = useState<number>(pageNumber);
  const [pageSize, setPageSize] = useState<number>(initialPageSize);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [data, setData] = useState<PaginationResult<T> | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Keep the latest fetch callback in a ref so callers can update it
  const fetchRef = useRef<DataFetchCallback<PaginationResult<T>> | undefined>(
    fetchCallback,
  );
  useEffect(() => {
    fetchRef.current = fetchCallback;
  }, [fetchCallback]);

  const hasMorePages = !!(
    data &&
    data.pageCount != null &&
    data.pageCount > pageIndex
  );
  const totalPages = data?.pageCount ?? 0;

  const queryParameters = {
    pageSize: pageSize.toString(),
    pageIndex: pageIndex.toString(),
  };

  const loadData = useCallback(
    async (page = pageIndex, size = pageSize) => {
      const cb = fetchRef.current;
      if (!cb) return null;
      setIsLoading(true);
      setError(null);
      try {
        const result = await cb(page, size);
        setData(result ?? null);
        return result ?? null;
      } catch (e: unknown) {
        setError(e instanceof Error ? e.message : String(e));
        return null;
      } finally {
        setIsLoading(false);
      }
    },
    // include pageIndex/pageSize to satisfy hooks lint. The function still
    // accepts explicit page/size args so callers can control what to load.
    [pageIndex, pageSize],
  );

  // Auto-load when pageIndex or pageSize changes (if allowed and callback exists)
  useEffect(() => {
    if (autoLoad && fetchRef.current) {
      // fire and forget
      void loadData(pageIndex, pageSize);
    }
  }, [pageIndex, pageSize, autoLoad, loadData]);

  // Navigation helpers
  const nextPage = useCallback(() => {
    if (isLoading) return;
    if (data?.pageCount != null && data.pageCount <= pageIndex) return;
    setPageIndex((p) => p + 1);
  }, [data, isLoading, pageIndex]);

  const previousPage = useCallback(() => {
    if (isLoading) return;
    setPageIndex((p) => Math.max(0, p - 1));
  }, [isLoading]);

  const goToPage = useCallback(
    (page: number) => {
      if (isLoading || page < 0) return;
      setPageIndex(page);
    },
    [isLoading],
  );

  const reset = useCallback(
    () => {
      setPageIndex(0);
      setIsLoading(false);
      setError(null);
      // loadData will run via the effect if fetchRef.current and autoLoad are set
    },
    [
      /* no deps */
    ],
  );

  const changePageSize = useCallback((newPageSize: number) => {
    setPageSize(newPageSize);
    setPageIndex(0);
  }, []);

  const setFetchCallback = useCallback(
    (cb: DataFetchCallback<PaginationResult<T>>) => {
      fetchRef.current = cb;
    },
    [],
  );

  const loadInitialData = useCallback(
    () => loadData(pageIndex, pageSize),
    [loadData, pageIndex, pageSize],
  );
  const refresh = useCallback(
    () => loadData(pageIndex, pageSize),
    [loadData, pageIndex, pageSize],
  );

  return {
    // state
    pageIndex,
    pageSize,
    isLoading,
    data,
    error,

    // meta
    hasMorePages,
    totalPages,
    queryParameters,

    // actions
    nextPage,
    previousPage,
    goToPage,
    reset,
    changePageSize,
    setFetchCallback,
    loadInitialData,
    refresh,
  } as const;
}

export default usePagination;
