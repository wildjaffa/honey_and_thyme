import { useNavigate } from "react-router";
import { HoneyPaginatedTable } from "../../../components";
import usePhotoShoots from "../../../hooks/usePhotoShoots";
import type { PhotoShootFilters } from "../../../hooks/usePhotoShoots";
import type { PhotoShootModel } from "../../../types/api";
import PhotoShootRow from "./PhotoShootRow";
import PhotoShootFilterControls from "./PhotoShootFilterControls";

const DEFAULT_FILTERS: PhotoShootFilters = {
  statuses: [3, 2, 4], // Confirmed, Booked, Paid
  startDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 days ago
};

function PhotoShootsIndex() {
  const navigate = useNavigate();

  return (
    <>
      <HoneyPaginatedTable<PhotoShootModel, PhotoShootFilters>
        usePaginatedQuery={usePhotoShoots}
        hasSearch
        onAddClick={() => navigate("new")}
        searchHint="Search Albums"
        renderRow={(photoShoot) => <PhotoShootRow photoShoot={photoShoot} />}
        addInitial={() => ({})}
        initialFilters={DEFAULT_FILTERS}
        renderFilterControls={(filters, setFilters) => (
          <PhotoShootFilterControls filters={filters} setFilters={setFilters} />
        )}
      />
    </>
  );
}

export default PhotoShootsIndex;
