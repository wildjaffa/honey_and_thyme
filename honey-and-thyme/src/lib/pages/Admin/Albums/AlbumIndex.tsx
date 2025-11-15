import { useState } from "react";
import useAlbums from "../../../hooks/useAlbums";
import usePagination from "../../../hooks/usePagination";
import AlbumRow from "./AlbumRow";
import {
  HoneyCircularLoader,
  HoneyIconButton,
  HoneyInput,
  HoneyModal,
  HoneyPaginationControls,
} from "../../../components";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import AlbumEdit from "./AlbumEdit";
import type { AlbumModel } from "../../../types/api";
import useDebounce from "../../../hooks/useDebounce";

function AlbumIndex() {
  const [search, setSearch] = useState("");

  const debouncedSearch = useDebounce(search.trim(), 400);

  const [album, setAlbum] = useState<AlbumModel | undefined>(undefined);

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

  const albumsQuery = useAlbums(pageIndex, pageSize, debouncedSearch);
  const { data: albumsData, isLoading, refetch, isError } = albumsQuery;

  const results = albumsData?.results ?? [];
  const totalPages = albumsData?.pageCount ?? 1;

  const generatePassword = () => {
    let password = "";
    for (let i = 0; i < 6; i++) {
      password += Math.floor(Math.random() * 10);
    }
    return password;
  };

  return (
    <div className="mx-auto max-w-3xl p-4">
      <div className="w-full rounded p-4 shadow">
        <div className="mb-4 flex items-center gap-3">
          <div className="w-11/12">
            <HoneyInput
              value={search}
              onChange={setSearch}
              placeholder="Search Albums"
            />
          </div>

          <HoneyIconButton
            icon={faPlus}
            onClick={() =>
              setAlbum({ isPublic: false, password: generatePassword() })
            }
            title="Add Album"
            isSelected
            background="honey-gold"
            selectedColor="black"
          />
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
              {results.map((album) => (
                <AlbumRow album={album} onUpdated={refetch} />
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
        <HoneyModal isOpen={album != null} onClose={() => setAlbum(undefined)}>
          {album && (
            <AlbumEdit
              album={album}
              onAfterSave={refetch}
              onCancel={() => setAlbum(undefined)}
            />
          )}
        </HoneyModal>
      </div>
    </div>
  );
}

export default AlbumIndex;
