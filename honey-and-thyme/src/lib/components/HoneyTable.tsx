import { useId, useState, type ReactElement } from "react";
import useDebounce from "../hooks/useDebounce";
import type { UseQueryResult } from "@tanstack/react-query";
import HoneyInput from "./HoneyInput";
import HoneyIconButton from "./HoneyIconButton";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import HoneyCircularLoader from "./HoneyCircularLoader";
import HoneyModal from "./HoneyModal";

interface HoneyTableProps<T> {
  hasSearch?: boolean;
  searchHint?: string;
  createAddForm?: (
    newItem: T,
    onAfterSave: () => void,
    onCancel: () => void,
  ) => ReactElement;
  /** Optional initial item to pass when opening the add form. Can be a value or factory. */
  addInitial?: T | (() => T);
  useQuery: (searchString?: string) => UseQueryResult<T[]>;
  /** renderRow receives the item and an optional onUpdated callback that should be called when the row updates data and the parent should refetch. */
  renderRow: (data: T, onUpdated?: () => void) => ReactElement;
}

function HoneyTable<T>({
  hasSearch,
  searchHint,
  createAddForm,
  addInitial,
  useQuery,
  renderRow,
}: HoneyTableProps<T>) {
  const [search, setSearch] = useState("");

  const debouncedSearch = useDebounce(search.trim(), 400);

  const [newItem, setNewItem] = useState<T | undefined>(undefined);

  const dataQuery = useQuery(debouncedSearch);
  const { data: results = [], isLoading, refetch, isError } = dataQuery;
  const id = useId();

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
          {createAddForm && (
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
            </div>
          )}
        </div>
        <HoneyModal
          isOpen={newItem != null}
          onClose={() => setNewItem(undefined)}
        >
          {createAddForm &&
            newItem &&
            createAddForm(newItem, refetch, () => setNewItem(undefined))}
        </HoneyModal>
      </div>
    </div>
  );
}

export default HoneyTable;
