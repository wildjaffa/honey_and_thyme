interface Props {
  pageIndex: number; // 1-based page index
  totalPages: number;
  pageSize: number;
  pageSizeOptions?: number[];
  onPageChange: (newPage: number) => void;
  onPageSizeChange?: (newSize: number) => void;
  showPageCount?: number; // how many pages around current to show
}

function getPageItems(
  current: number,
  total: number,
  delta = 2,
): (number | "...")[] {
  const pages: (number | "...")[] = [];
  if (total <= 0) return pages;

  const left = Math.max(1, current - delta);
  const right = Math.min(total, current + delta);

  if (left > 1) pages.push(1);
  if (left > 2) pages.push("...");

  for (let i = left; i <= right; i++) pages.push(i);

  if (right < total - 1) pages.push("...");
  if (right < total) pages.push(total);

  return pages;
}

function HoneyPaginationControls({
  pageIndex,
  totalPages,
  pageSize,
  pageSizeOptions = [10, 25, 50, 100],
  onPageChange,
  onPageSizeChange,
  showPageCount = 2,
}: Props) {
  const pages = getPageItems(pageIndex, totalPages, showPageCount);

  const canPrev = pageIndex > 0;
  const canNext = pageIndex < totalPages - 1;

  return (
    <div className="flex items-center justify-between gap-4">
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => canPrev && onPageChange(pageIndex - 1)}
          disabled={!canPrev}
          className={`rounded border px-3 py-1 ${!canPrev ? "cursor-not-allowed opacity-50" : "hover:bg-gray-100"}`}
        >
          Prev
        </button>

        <nav aria-label="Pagination" className="flex items-center gap-1">
          {pages.map((p, idx) =>
            p === "..." ? (
              <span key={`ellipsis-${idx}`} className="px-2 text-gray-500">
                …
              </span>
            ) : (
              <button
                key={p}
                type="button"
                onClick={() => onPageChange(p - 1)}
                aria-current={p === pageIndex ? "page" : undefined}
                className={`rounded px-2 py-1 ${p - 1 === pageIndex ? "bg-blue-600 text-white" : "hover:bg-gray-100"}`}
              >
                {p}
              </button>
            ),
          )}
        </nav>

        <button
          type="button"
          onClick={() => canNext && onPageChange(pageIndex + 1)}
          disabled={!canNext}
          className={`rounded border px-3 py-1 ${!canNext ? "cursor-not-allowed opacity-50" : "hover:bg-gray-100"}`}
        >
          Next
        </button>
      </div>

      <div className="flex items-center gap-2">
        <label className="text-sm text-gray-600">Page size</label>
        <select
          value={pageSize}
          onChange={(e) =>
            onPageSizeChange && onPageSizeChange(Number(e.target.value))
          }
          className="rounded border px-2 py-1"
        >
          {pageSizeOptions.map((opt) => (
            <option key={opt} value={opt}>
              {opt}
            </option>
          ))}
        </select>
      </div>
    </div>
  );
}

export default HoneyPaginationControls;
