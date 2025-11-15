import React, { useState, type ReactElement } from "react";
import usePagination from "../hooks/usePagination";
import useDebounce from "../hooks/useDebounce";
import type { UseQueryResult } from "@tanstack/react-query";
import type PaginationResult from "../types/paginationResult";
import HoneyInput from "./HoneyInput";
import HoneyIconButton from "./HoneyIconButton";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import HoneyCircularLoader from "./HoneyCircularLoader";
import HoneyPaginationControls from "./HoneyPaginationControls";
import HoneyModal from "./HoneyModal";

interface HoneyPaginatedTableProps<T> {
  hasSearch?: boolean;
  searchHint?: string;
  /** A React element used as the "add" form. It will be cloned and injected with props: `item`, `onAfterSave`, `onCancel` */
  addForm?: ReactElement;
  /** Optional initial item to pass when opening the add form. Can be a value or factory. */
  addInitial?: T | (() => T);
  usePaginatedQuery: (
    pageIndex: number,
    pageSize: number,
    searchString?: string,
  ) => UseQueryResult<PaginationResult<T>>;
  /** renderRow receives the item and an optional onUpdated callback that should be called when the row updates data and the parent should refetch. */
  renderRow: (data: T, onUpdated?: () => void) => ReactElement;
}

function HoneyPaginatedTable<T>({
  hasSearch,
  searchHint,
  addForm,
  addInitial,
  usePaginatedQuery,
  renderRow,
}: HoneyPaginatedTableProps<T>) {
  const [search, setSearch] = useState("");

  const debouncedSearch = useDebounce(search.trim(), 400);

  const [newItem, setNewItem] = useState<T | undefined>(undefined);

  // Use pagination as state-only controller. We won't use its built-in
  // auto-load; instead we pass `pageIndex`/`pageSize` to `useAlbums` which
  // returns a react-query result. This keeps caching and retries in react-query
  // while `usePagination` manages UI state and navigation.
  const pagination = usePagination({
    pageNumber: 0,
    pageSize: 10,
    autoLoad: false,
  });
  const { pageIndex, pageSize, changePageSize, goToPage } = pagination;

  const dataQuery = usePaginatedQuery(pageIndex, pageSize, debouncedSearch);
  const { data: albumsData, isLoading, refetch, isError } = dataQuery;

  const results = albumsData?.results ?? [];
  const totalPages = albumsData?.pageCount ?? 1;

  return (
    <div className="mx-auto max-w-3xl p-4">
      <div className="w-full rounded p-4 shadow">
        <div className="mb-4 flex items-center gap-3">
          <div className="w-11/12">
            {hasSearch && (
              <HoneyInput
                value={search}
                onChange={setSearch}
                placeholder={searchHint}
              />
            )}
          </div>
          {addForm && (
            <HoneyIconButton
              icon={faPlus}
              onClick={() =>
                setNewItem(
                  typeof addInitial === "function"
                    ? (addInitial as () => T)()
                    : ((addInitial as T) ?? ({} as T)),
                )
              }
              title="Add Item"
              isSelected
              background="honey-gold"
              selectedColor="black"
            />
          )}
        </div>

        <div>
          {isLoading ? (
            <div className="py-10 text-center">
              <HoneyCircularLoader />
            </div>
          ) : isError ? (
            <div className="text-red-600">Error:</div>
          ) : results.length === 0 ? (
            <div className="py-10 text-center">No albums found</div>
          ) : (
            <div className="space-y-2">
              {results.map((item) => renderRow(item, refetch))}

              <HoneyPaginationControls
                pageIndex={pageIndex}
                totalPages={totalPages}
                pageSize={pageSize}
                onPageChange={goToPage}
                onPageSizeChange={changePageSize}
              />
            </div>
          )}
        </div>
        <HoneyModal
          isOpen={newItem != null}
          onClose={() => setNewItem(undefined)}
        >
          {addForm &&
            newItem &&
            (React.isValidElement(addForm)
              ? React.cloneElement(
                  addForm as ReactElement<Record<string, unknown>>,
                  {
                    // common prop names used by existing forms in the app
                    item: newItem,
                    onAfterSave: refetch,
                    onCancel: () => setNewItem(undefined),
                  },
                )
              : addForm)}
        </HoneyModal>
      </div>
    </div>
  );
}

export default HoneyPaginatedTable;
