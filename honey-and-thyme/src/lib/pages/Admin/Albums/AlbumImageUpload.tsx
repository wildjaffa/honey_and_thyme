import { useRef, useState } from "react";
import { toast } from "react-toastify";
import HoneyButton from "../../../components/HoneyButton";
import HoneyPageLoader from "../../../components/HoneyPageLoader";
import apiClient from "../../../api/client";

interface AlbumImageUploadProps {
  albumId: string;
  onUploadComplete?: () => void;
}

export default function AlbumImageUpload({
  albumId,
  onUploadComplete,
}: AlbumImageUploadProps) {
  const inputRef = useRef<HTMLInputElement | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [progress, setProgress] = useState<number | undefined>(undefined);
  const upload = apiClient.useMutation("post", "/images/upload");

  const handleClick = () => {
    inputRef.current?.click();
  };

  const handleFiles = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    // Use the apiClient mutation to upload files one-at-a-time.
    // We don't have a byte-level progress hook from openapi-fetch, so
    // report progress as files completed / total.
    try {
      setIsUploading(true);
      setProgress(0);

      const filesArray = Array.from(files);
      const uploadMutate = (
        upload as unknown as {
          mutateAsync: (opts: unknown) => Promise<unknown>;
        }
      ).mutateAsync;

      for (let i = 0; i < filesArray.length; i++) {
        const f = filesArray[i];
        if (!f) continue;
        const form = new FormData();
        form.append("AlbumId", albumId);
        form.append("ImageFiles", f, f.name);

        // openapi-react-query/openapi-fetch should accept FormData as the body
        // for multipart endpoints. Cast to any to satisfy TypeScript if needed.
        await uploadMutate({ body: form });

        // update progress as number of files completed
        setProgress(Math.round(((i + 1) / filesArray.length) * 100));
      }

      toast.success("Images uploaded successfully");
      if (onUploadComplete) onUploadComplete();
    } catch (err) {
      console.error(err);
      toast.error(
        "There was a problem uploading the images. Please try again.",
      );
    } finally {
      setIsUploading(false);
      setTimeout(() => setProgress(undefined), 400);
      // clear input so same files can be chosen again if needed
      if (inputRef.current) inputRef.current.value = "";
    }
  };

  return (
    <>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        multiple
        onChange={handleFiles}
        className="hidden"
      />
      <HoneyButton onClick={handleClick} isLoading={isUploading}>
        Upload Images
      </HoneyButton>

      {isUploading && (
        <HoneyPageLoader message="Uploading images..." progress={progress} />
      )}
    </>
  );
}
