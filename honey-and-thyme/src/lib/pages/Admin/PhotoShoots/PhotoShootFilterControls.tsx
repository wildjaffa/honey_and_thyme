// Mapping based on Flutter PhotoShootStatus enum

import { faFilter } from "@fortawesome/free-solid-svg-icons";
import {
  HoneyCheckbox,
  HoneyIconButton,
  HoneyInput,
} from "../../../components";
import { useState } from "react";
import type { PhotoShootFilters } from "../../../hooks/usePhotoShoots";

// 0=Unbooked, 1=Scheduled, 2=Booked, 3=Confirmed, 4=Paid, 5=Delivered, 6=Deleted
const PhotoShootStatusMap: Record<number, string> = {
  0: "Unbooked",
  1: "Scheduled",
  2: "Booked",
  3: "Confirmed",
  4: "Paid",
  5: "Delivered",
  6: "Deleted",
};

const ALL_STATUSES = [0, 1, 2, 3, 4, 5, 6] as const;

interface PhotoShootFilterControlsProps {
  filters: PhotoShootFilters | undefined;
  setFilters: (filters: PhotoShootFilters | undefined) => void;
}

function PhotoShootFilterControls({
  filters,
  setFilters,
}: PhotoShootFilterControlsProps) {
  const [isOpen, setIsOpen] = useState(false);

  // Initialize filters if undefined
  const currentFilters = filters || {
    statuses: [3, 2, 4], // Default: Confirmed, Booked, Paid (matching Flutter)
    startDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Default: 7 days ago
  };

  const handleStatusChange = (status: number, checked: boolean) => {
    const currentStatuses = (currentFilters.statuses || []) as (
      | 0
      | 1
      | 2
      | 3
      | 4
      | 5
      | 6
    )[];
    let newStatuses: (0 | 1 | 2 | 3 | 4 | 5 | 6)[];
    if (checked) {
      newStatuses = [...currentStatuses, status as 0 | 1 | 2 | 3 | 4 | 5 | 6];
    } else {
      newStatuses = currentStatuses.filter((s) => s !== status);
    }
    setFilters({ ...currentFilters, statuses: newStatuses });
  };

  const handleDateChange = (field: "startDate" | "endDate", value: string) => {
    const date = value ? new Date(value) : undefined;
    setFilters({ ...currentFilters, [field]: date });
  };

  const clearFilters = () => {
    setFilters({
      statuses: [3, 2, 4],
      startDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      endDate: undefined,
    });
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <HoneyIconButton
        icon={faFilter}
        onClick={() => setIsOpen(!isOpen)}
        title="Filters"
        isSelected={isOpen}
        background="gold"
        selectedColor="black"
      />
      {isOpen && (
        <>
          <div
            className="fixed inset-0 z-10"
            onClick={() => setIsOpen(false)}
          />
          <div className="border-honey-gold absolute right-0 z-20 mt-2 w-80 rounded-md border-2 bg-white p-4 shadow-lg">
            <div className="mb-4 flex items-center justify-between">
              <h3 className="text-lg font-bold">Filters</h3>
              <div className="flex gap-2">
                <button
                  onClick={clearFilters}
                  className="text-sm text-gray-600 hover:text-gray-900"
                >
                  Clear
                </button>
                <button
                  onClick={() => setIsOpen(false)}
                  className="text-honey-gold text-sm font-bold hover:text-yellow-600"
                >
                  Done
                </button>
              </div>
            </div>

            <div className="space-y-4">
              <div className="grid grid-rows-2 gap-4">
                <div>
                  <HoneyInput
                    label="Start Date"
                    type="date"
                    value={
                      currentFilters.startDate?.toISOString().split("T")[0] ??
                      ""
                    }
                    onChange={(val) => handleDateChange("startDate", val)}
                  />
                </div>
                <div>
                  <HoneyInput
                    label="End Date"
                    type="date"
                    value={
                      currentFilters.endDate?.toISOString().split("T")[0] ?? ""
                    }
                    onChange={(val) => handleDateChange("endDate", val)}
                  />
                </div>
              </div>

              <div>
                <label className="mb-2 block text-sm font-medium text-gray-700">
                  Status
                </label>
                <div className="grid grid-cols-2 gap-2">
                  {ALL_STATUSES.map((status) => (
                    <HoneyCheckbox
                      key={status}
                      label={PhotoShootStatusMap[status]}
                      checked={
                        currentFilters.statuses?.includes(status) ?? false
                      }
                      onChange={(checked) =>
                        handleStatusChange(status, checked)
                      }
                    />
                  ))}
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default PhotoShootFilterControls;
