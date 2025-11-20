import { faCircleCheck } from "@fortawesome/free-solid-svg-icons";
import { HoneyIconButton } from "../../../components";
import type { PhotoShootModel } from "../../../types/api";
import { useNavigate } from "react-router";
import { getLocalDateTimeString } from "../../../utils/date";

interface PhotoShootRowProps {
  photoShoot: PhotoShootModel;
}

function PhotoShootRow({ photoShoot }: PhotoShootRowProps) {
  const navigate = useNavigate();

  const paidInFull = (photoShoot.paymentRemaining ?? 0) <= 0;

  return (
    <div
      key={photoShoot.photoShootId}
      className="im-fell-english flex cursor-pointer"
      onClick={() => {
        navigate(`${photoShoot.photoShootId}`);
      }}
    >
      <HoneyIconButton
        icon={faCircleCheck}
        title={paidInFull ? "Paid in full" : "Pending payment"}
        isSelected
        selectedColor={paidInFull ? "honey-sage" : "honey-pink"}
      />
      <div className="min-w-0 flex-1 pl-2">
        <div className="truncate text-sm font-medium">
          {photoShoot.nameOfShoot}
        </div>
        <div className="truncate text-xs text-gray-500">
          {getLocalDateTimeString(photoShoot.dateTimeUtc)}
        </div>
      </div>

      <div className="flex items-center gap-2"></div>
    </div>
  );
}
export default PhotoShootRow;
