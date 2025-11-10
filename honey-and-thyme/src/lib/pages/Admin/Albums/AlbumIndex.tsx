import React, { useEffect, useState } from "react";
import useAlbums from "../../../hooks/useAlbums";
import usePagination from "../../../hooks/usePagination";
import AlbumRow from "./AlbumRow";
import HoneyPaginationControls from "../../../components/HoneyPaginationControls";

function AlbumIndex() {
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [adding, setAdding] = useState(false);
  const [creating, setCreating] = useState(false);

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

  // debounce search input
  useEffect(() => {
    const t = setTimeout(() => setDebouncedSearch(search.trim()), 400);
    return () => clearTimeout(t);
  }, [search]);

  const albumsQuery = useAlbums(pageIndex, pageSize, debouncedSearch);
  const { data: albumsData, isLoading, refetch, isError } = albumsQuery;

  const results = albumsData?.results ?? [];
  const totalPages = albumsData?.pageCount ?? 1;

  async function handleCreate(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const formData = new FormData(form);
    const name = String(formData.get("name") ?? "").trim();
    const description = String(formData.get("description") ?? "").trim();
    const password = String(formData.get("password") ?? "").trim() || undefined;
    if (!name) {
      alert("Name is required");
      return;
    }
    setCreating(true);
    try {
      const res = await fetch("/albums", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, description, password }),
      });
      if (!res.ok) throw new Error(`Create failed: ${res.status}`);
      setAdding(false);
      // trigger react-query refetch of albums
      void refetch();
    } catch (err) {
      console.error(err);
    } finally {
      setCreating(false);
    }
  }

  return (
    <div className="mx-auto max-w-3xl p-4">
      <div className="w-full rounded bg-white p-4 shadow">
        <div className="mb-4 flex items-center gap-3">
          <input
            className="flex-1 rounded border px-3 py-2 focus:ring focus:outline-none"
            placeholder="Search Albums"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            autoFocus
          />
          <button
            className="rounded bg-blue-600 px-3 py-2 text-white hover:bg-blue-700"
            onClick={() => setAdding((s) => !s)}
          >
            {adding ? "Cancel" : "Create New Album"}
          </button>
        </div>

        {adding ? (
          <form onSubmit={handleCreate} className="space-y-3">
            <div>
              <label className="block text-sm font-medium">Name</label>
              <input name="name" className="w-full rounded border px-2 py-1" />
            </div>
            <div>
              <label className="block text-sm font-medium">Description</label>
              <input
                name="description"
                className="w-full rounded border px-2 py-1"
              />
            </div>
            <div>
              <label className="block text-sm font-medium">
                Password (optional)
              </label>
              <input
                name="password"
                className="w-full rounded border px-2 py-1"
              />
            </div>
            <div className="flex gap-2">
              <button
                type="submit"
                disabled={creating}
                className="rounded bg-green-600 px-3 py-1 text-white hover:bg-green-700"
              >
                {creating ? "Creating..." : "Create"}
              </button>
              <button
                type="button"
                onClick={() => setAdding(false)}
                className="rounded border px-3 py-1"
              >
                Cancel
              </button>
            </div>
          </form>
        ) : (
          <div>
            {isLoading ? (
              <div className="py-10 text-center">Loading…</div>
            ) : isError ? (
              <div className="text-red-600">Error:</div>
            ) : results.length === 0 ? (
              <div className="py-10 text-center">No albums found</div>
            ) : (
              <div className="space-y-2">
                {results.map((album) => (
                  <AlbumRow album={album} />
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
        )}
      </div>
    </div>
  );
}

export default AlbumIndex;
