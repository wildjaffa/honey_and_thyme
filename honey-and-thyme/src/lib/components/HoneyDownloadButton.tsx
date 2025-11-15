import React, { useState } from "react";
import * as signalR from "@microsoft/signalr";
import HoneyIconButton from "./HoneyIconButton";
import type {
  AlbumModel,
  DownloadRequest,
  DownloadResponse,
} from "../types/api";
import HoneyQualitySelector from "./HoneyQualitySelector";
import HoneyPageLoader from "./HoneyPageLoader";
import { faCircleDown, faImages } from "@fortawesome/free-solid-svg-icons";
import type { IconDefinition } from "@fortawesome/free-solid-svg-icons";
import { toast } from "react-toastify";
import HoneyModal from "./HoneyModal";

interface DownloadProgressData {
  percentComplete: number;
  url?: string;
}

interface HoneyDownloadButtonProps {
  album: AlbumModel;
  selectedImages: string[];
  password?: string;
}

function HoneyDownloadButton({
  album,
  selectedImages,
  password,
}: HoneyDownloadButtonProps) {
  const apiUrl = import.meta.env.VITE_BASE_URL;
  const [isQualitySelectorOpen, setIsQualitySelectorOpen] =
    React.useState(false);
  const [downloadState, setDownloadState] = React.useState<{
    isLoading: boolean;
    progress: number;
  }>({
    isLoading: false,
    progress: 0,
  });
  const [downloadUrl, setDownloadUrl] = useState<string | undefined>(undefined);
  const [connection, setConnection] =
    React.useState<signalR.HubConnection | null>(null);

  React.useEffect(() => {
    return () => {
      if (connection) {
        connection.stop();
      }
    };
  }, [connection]);

  const openDownloadInNewTab = (url: string) => {
    window.open(url, "_blank");
  };

  const initiateDownload = React.useCallback(
    async (quality: number) => {
      setIsQualitySelectorOpen(false);
      setDownloadState({ isLoading: true, progress: 0 });

      // Create SignalR connection
      const newConnection = new signalR.HubConnectionBuilder()
        .withUrl(`${apiUrl}/imageDownloadHub`, {
          withCredentials: true,
        })
        .build();

      try {
        await newConnection.start();
        setConnection(newConnection);

        const connectionId = newConnection.connectionId;
        if (!connectionId) {
          setDownloadState({
            isLoading: false,
            progress: 0,
          });
          return;
        }

        // Set up progress handler
        newConnection.on(
          "ReceiveImageDownloadProgress",
          (data: DownloadProgressData) => {
            const { percentComplete, url } = data;

            setDownloadState((prev) => ({
              ...prev,
              progress: percentComplete,
            }));

            if (percentComplete === 100 && url) {
              setDownloadState({ isLoading: false, progress: 100 });
              setDownloadUrl(url);
              openDownloadInNewTab(url);
              newConnection.stop();
            }
          },
        );
        const imageIds =
          selectedImages.length > 0
            ? selectedImages
            : album.images
                ?.filter((img) => img.imageId != undefined)
                .map((img) => img.imageId ?? "");
        // Start the download
        const size = quality as 0 | 1 | 2 | 3 | 4;
        const downloadRequest: DownloadRequest = {
          imageIds: imageIds ?? [],
          config: {
            size,
            exportConfigId: 0,
            keepFolders: false,
            name: "Download",
            watermarkText: null,
            type: 0,
          },
          password,
          connectionId,
        };
        const startedSuccessfully = (await fetch(
          `${apiUrl}/api/download/images`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(downloadRequest),
          },
        ).then((res) => res.json())) as DownloadResponse;

        if (!startedSuccessfully || !startedSuccessfully.startedSuccessfully) {
          throw new Error("Failed to start download");
        }
      } catch (error) {
        console.error("Download initiation error:", error);
        newConnection.stop();
        setDownloadState({
          isLoading: false,
          progress: 0,
        });
        toast.error(
          "There was an error starting the download. Please try again later.",
        );
      }
    },
    [password, selectedImages, album, apiUrl],
  );

  const openQualitySelector = React.useCallback(() => {
    setIsQualitySelectorOpen(true);
  }, []);

  let icon: IconDefinition = faCircleDown;
  if (selectedImages.length > 0) {
    icon = faImages;
  }

  return (
    <>
      <HoneyIconButton
        title={`Download ${selectedImages.length > 0 ? `${selectedImages} images` : "album"}`}
        icon={icon}
        nonSelectedColor="black"
        opacityOnHover={false}
        onClick={openQualitySelector}
        badge={selectedImages.length > 0 ? selectedImages.length : undefined}
      />
      <HoneyQualitySelector
        isOpen={isQualitySelectorOpen}
        onClose={() => setIsQualitySelectorOpen(false)}
        onSelect={initiateDownload}
        selectedImagesCount={selectedImages.length || undefined}
      />
      {downloadState.isLoading && (
        <HoneyPageLoader
          message={`Preparing download${
            selectedImages.length
              ? ` (${selectedImages.length} images)`
              : " (full album)"
          }...`}
          progress={downloadState.progress}
        />
      )}

      <HoneyModal
        isOpen={downloadUrl != undefined}
        submitText="Download"
        onClose={() => {
          setDownloadUrl(undefined);
        }}
        onSubmit={() => downloadUrl && openDownloadInNewTab(downloadUrl)}
      >
        <div className="im-fell-english">
          Your download should start automatically, if it does not, please tap
          the button below to start the download.
        </div>
      </HoneyModal>
    </>
  );
}

export default HoneyDownloadButton;
