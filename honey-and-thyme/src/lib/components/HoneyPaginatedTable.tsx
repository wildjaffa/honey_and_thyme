import { useId, useState, type ReactElement } from "react";
import usePagination from "../hooks/usePagination";
import useDebounce from "../hooks/useDebounce";
import type { UseQueryResult } from "@tanstack/react-query";
import type PaginationResult from "../types/paginationResult";
import HoneyInput from "./HoneyInput";
import HoneyIconButton from "./HoneyIconButton";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import HoneyPaginationControls from "./HoneyPaginationControls";
import HoneyModal from "./HoneyModal";
import HoneyPageLoader from "./HoneyPageLoader";

interface HoneyPaginatedTableProps<T, F = unknown> {
  hasSearch?: boolean;
  searchHint?: string;
  createAddForm?: (
    newItem: T,
    onAfterSave: () => void,
    onCancel: () => void,
  ) => ReactElement;
  /** Optional initial item to pass when opening the add form. Can be a value or factory. */
  addInitial?: T | (() => T);
  /**
   * usePaginatedQuery now receives optional search string and optional filters object.
   * The second generic F is the shape of the filters the page uses.
   */
  usePaginatedQuery: (
    pageIndex: number,
    pageSize: number,
    searchString?: string,
    filters?: F,
  ) => UseQueryResult<PaginationResult<T>>;
  /** renderRow receives the item and an optional onUpdated callback that should be called when the row updates data and the parent should refetch. */
  renderRow: (data: T, onUpdated?: () => void) => ReactElement;
  /** Optional render function to render filter controls; receives current filters and a setter. */
  renderFilterControls?: (
    filters: F | undefined,
    setFilters: (f: F | undefined) => void,
  ) => ReactElement | null;
  /** Optional initial filters to use when the component mounts. */
  initialFilters?: F;
  onAddClick?: () => void;
}

function HoneyPaginatedTable<T, F = unknown>({
  hasSearch,
  searchHint,
  createAddForm,
  addInitial,
  usePaginatedQuery,
  renderRow,
  renderFilterControls,
  initialFilters,
  onAddClick,
}: HoneyPaginatedTableProps<T, F>) {
  const [search, setSearch] = useState("");

  const debouncedSearch = useDebounce(search.trim(), 400);

  // Local filters state (generic). Pages can render filter UI via
  // renderFilterControls and update these filters. They will be passed to
  // usePaginatedQuery so the hook can include them in the API request.
  const [filters, setFilters] = useState<F | undefined>(initialFilters);

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

  const dataQuery = usePaginatedQuery(
    pageIndex,
    pageSize,
    debouncedSearch,
    filters,
  );
  const { data: albumsData, isLoading, refetch, isError } = dataQuery;

  const results = albumsData?.results ?? [];
  const totalPages = albumsData?.pageCount ?? 1;
  const id = useId();

  return (
    <div className="mx-auto max-w-3xl p-4">
      <div className="w-full rounded p-4 shadow">
        <div className="mb-4 flex items-center gap-3">
          <div className="flex-1">
            <div className="flex items-center gap-3">
              <div className="flex-1">
                {hasSearch && (
                  <HoneyInput
                    value={search}
                    onChange={setSearch}
                    placeholder={searchHint}
                  />
                )}
              </div>
              {/* render any filter controls provided by the page */}
              {renderFilterControls &&
                renderFilterControls(filters, setFilters)}
            </div>
          </div>

          {(createAddForm || onAddClick) && (
            <HoneyIconButton
              icon={faPlus}
              onClick={() => {
                if (onAddClick) {
                  onAddClick();
                } else {
                  setNewItem(
                    typeof addInitial === "function"
                      ? (addInitial as () => T)()
                      : ((addInitial as T) ?? ({} as T)),
                  );
                }
              }}
              title="Add Item"
              isSelected
              background="gold"
              selectedColor="black"
            />
          )}
        </div>

        <div>
          {isLoading ? (
            <div className="py-10 text-center">
              <HoneyPageLoader />
            </div>
          ) : isError ? (
            <div className="text-red-600">Error:</div>
          ) : results.length === 0 ? (
            <div className="py-10 text-center">No items found</div>
          ) : (
            <div className="space-y-2">
              {results.map((item, index) => (
                <div
                  className="items-center gap-4 rounded border p-2 hover:shadow"
                  key={`${id}-${index}`}
                >
                  {renderRow(item, refetch)}
                </div>
              ))}

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
          isOpen={newItem != null && newItem !== undefined}
          onClose={() => setNewItem(undefined)}
        >
          {createAddForm &&
            newItem &&
            createAddForm(
              newItem,
              () => {
                refetch();
                setNewItem(undefined);
              },
              () => setNewItem(undefined),
            )}
        </HoneyModal>
      </div>
    </div>
  );
}

export default HoneyPaginatedTable;
