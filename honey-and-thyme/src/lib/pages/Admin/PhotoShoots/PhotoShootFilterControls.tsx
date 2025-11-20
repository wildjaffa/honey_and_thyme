import { faFilter } from "@fortawesome/free-solid-svg-icons";
import { HoneyIconButton } from "../../../components";
import type { PhotoShootFilters } from "../../../hooks/usePhotoShoots";
import { useState } from "react";

interface PhotoShootFilterControlsProps {
    filters: PhotoShootFilters;
    setFilters: (filters: PhotoShootFilters) => void;
}

function PhotoShootFilterControls({filters, setFilters}: PhotoShootFilterControlsProps) {
    const [isOpen, setIsOpen] = useState(false);
    return (<>
        <HoneyIconButton onClick={() => setIsOpen(!isOpen)} icon={faFilter} title="filters" />
        {isOpen &&
        <ul
          className="border-honey-gold absolute z-10 mt-2 w-max overflow-auto rounded-md border-2 bg-white shadow-sm"
          role="listbox"
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
        </ul>}
    </>);
}

export default PhotoShootFilterControls;