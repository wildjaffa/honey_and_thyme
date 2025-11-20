import { HoneyPaginatedTable } from "../../../components";
import usePhotoShoots from "../../../hooks/usePhotoShoots";
import type { PhotoShootFilters } from "../../../hooks/usePhotoShoots";
import type { PhotoShootModel } from "../../../types/api";
import PhotoShootRow from "./PhotoShootRow";

function PhotoShootsIndex() {
  return (
    <>
      <HoneyPaginatedTable<PhotoShootModel, PhotoShootFilters>
        usePaginatedQuery={usePhotoShoots}
        hasSearch
        createAddForm={(newAlbum, onAfterSave, onCancel) => <></>}
        searchHint="Search Albums"
        renderRow={(photoShoot) => <PhotoShootRow photoShoot={photoShoot} />}
        addInitial={() => ({})}
      />
    </>
  );
}

export default PhotoShootsIndex;
