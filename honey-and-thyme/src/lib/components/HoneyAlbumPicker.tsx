import { useState } from "react";
import useAlbums from "../hooks/useAlbums";
import type { AlbumModel } from "../types/api";
import useDebounce from "../hooks/useDebounce";
import HoneyInput from "./HoneyInput";

interface HoneyAlbumPickerProps {
  disabled?: boolean;
  onAlbumSelected: (albumId: string | undefined) => void;
}

function HoneyAlbumPicker({
  disabled,
  onAlbumSelected,
}: HoneyAlbumPickerProps) {
  const [searchString, setSearchString] = useState("");
  const debouncedSearch = useDebounce(searchString, 400);
  const [focus, setFocus] = useState(false);
  const albums = useAlbums(0, 10, debouncedSearch || undefined);

  const inputChanged = (value: string) => {
    setSearchString(value);
    if (value == "") onAlbumSelected(undefined);
  };

  const results: AlbumModel[] =
    (albums?.data?.results as AlbumModel[] | undefined) ?? [];

  return (
    <div className="honey-album-picker">
      <HoneyInput
        type="text"
        value={searchString}
        onChange={inputChanged}
        placeholder="Search albums..."
        disabled={disabled}
        onFocus={() => setFocus(true)}
        onBlur={() => setFocus(false)}
      />
      {focus && (
        <ul
          className="border-honey-gold absolute z-10 mt-2 w-max overflow-auto rounded-md border-2 bg-white shadow-sm"
          role="listbox"
          aria-disabled={disabled}
        >
          {albums?.isLoading ? (
            <li className="hap-loading p-3 text-sm text-gray-600">
              Loading...
            </li>
          ) : results.length > 0 ? (
            results.map((album) => {
              const id = album.albumId ?? "";
              return (
                <li key={id || album.name} className="hap-item" role="option">
                  <button
                    type="button"
                    className="hap-item-button } w-full cursor-pointer px-3 py-2 text-left hover:bg-gray-50"
                    onMouseDown={(e) => {
                      e.preventDefault();
                      if (id) onAlbumSelected(id);
                      if (album.name) setSearchString(album.name);
                    }}
                  >
                    <span className="block text-sm text-gray-900">
                      {album.name ?? "Untitled album"}
                    </span>
                  </button>
                </li>
              );
            })
          ) : (
            <li className="hap-empty p-3 text-sm text-gray-600">No results</li>
          )}
        </ul>
      )}
    </div>
  );
}

export default HoneyAlbumPicker;
