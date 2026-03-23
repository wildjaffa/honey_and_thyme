import useAlbums from "../../../hooks/useAlbums";
import AlbumRow from "./AlbumRow";
import { HoneyPaginatedTable } from "../../../components";
import AlbumEdit from "./AlbumEdit";
import type { AlbumModel } from "../../../types/api";

function AlbumIndex() {
  const generatePassword = () => {
    let password = "";
    for (let i = 0; i < 6; i++) {
      password += Math.floor(Math.random() * 10);
    }
    console.log(`generated password ${password}`);
    return password;
  };

  return (
    <HoneyPaginatedTable<AlbumModel>
      usePaginatedQuery={useAlbums}
      hasSearch
      createAddForm={(newAlbum, onAfterSave, onCancel) => (
        <AlbumEdit
          album={newAlbum}
          onAfterSave={onAfterSave}
          onCancel={onCancel}
        />
      )}
      searchHint="Search Albums"
      renderRow={(album, refetch) => (
        <AlbumRow
          key={`album-row-${album.albumId}`}
          album={album}
          onUpdated={() => refetch && refetch()}
        />
      )}
      addInitial={() => ({ isPublic: false, password: generatePassword() })}
    />
  );
}

export default AlbumIndex;
