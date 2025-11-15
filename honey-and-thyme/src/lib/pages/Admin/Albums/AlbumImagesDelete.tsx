import { useState } from "react";
import { HoneyIconButton, HoneyPageLoader } from "../../../components";
import { faTrash } from "@fortawesome/free-solid-svg-icons";
import apiClient from "../../../api/client";
import { toast } from "react-toastify";

interface AlbumImagesDeleteProps {
  imageIds: string[];
  onAfterDelete: () => void;
}

function AlbumImagesDelete({
  imageIds,
  onAfterDelete,
}: AlbumImagesDeleteProps) {
  const [progress, setProgress] = useState<number | undefined>(undefined);

  const deleteSelectedImagesMutation = apiClient.useMutation(
    "delete",
    "/images/{id}",
  );

  const deleteSelectedImages = async () => {
    let failedCount = 0;
    setProgress(0);
    for (let i = 0; i < imageIds.length; i++) {
      const imageId = imageIds[i];
      if (!imageId) continue;
      const result = await deleteSelectedImagesMutation.mutateAsync({
        params: { path: { id: imageId } },
      });
      if (!result.result) failedCount++;
      setProgress(Math.round(((i + 1) / imageIds.length) * 100));
    }
    if (failedCount) {
      toast.error(`${failedCount} pictures couldn't be deleted`);
    } else {
      toast.success(`${imageIds.length} pictures deleted`);
    }
    setProgress(undefined);
    if (onAfterDelete) onAfterDelete();
  };

  return (
    <>
      <HoneyIconButton
        icon={faTrash}
        title="delete"
        isSelected={imageIds.length > 0}
        disabled={imageIds.length == 0}
        nonSelectedColor="honey-sage"
        opacityOnHover={imageIds.length > 0}
        onClick={deleteSelectedImages}
      />
      {progress && (
        <HoneyPageLoader message="Deleting images..." progress={progress} />
      )}
    </>
  );
}

export default AlbumImagesDelete;
