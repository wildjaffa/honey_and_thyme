import React from "react";
import HoneyIconButton from "./HoneyIconButton";
import type { AlbumModel } from "../types/api";
import HoneyQualitySelector from "./HoneyQualitySelector";
import HoneyPageLoader from "./HoneyPageLoader";
import { faCircleDown, faImages } from "@fortawesome/free-solid-svg-icons";
import type { IconDefinition } from "@fortawesome/free-solid-svg-icons";

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
  const [isQualitySelectorOpen, setIsQualitySelectorOpen] =
    React.useState(false);
  const [downloadState, setDownloadState] = React.useState<{
    isLoading: boolean;
    progress: number;
    error?: string;
  }>({
    isLoading: false,
    progress: 0,
  });
  const [ws, setWs] = React.useState<WebSocket | null>(null);

  React.useEffect(() => {
    return () => {
      if (ws) {
        ws.close();
      }
    };
  }, [ws]);

  const initiateDownload = React.useCallback(
    (quality: number) => {
      setDownloadState({ isLoading: true, progress: 0 });

      // Create WebSocket connection
      const websocket = new WebSocket(
        `${import.meta.env.VITE_WS_URL}/api/downloads/progress`,
      );
      setWs(websocket);

      websocket.onmessage = (event) => {
        const message = JSON.parse(event.data);

        switch (message.type) {
          case "progress":
            if (message.progress !== undefined) {
              setDownloadState((prev) => ({
                ...prev,
                progress: message.progress,
              }));
            }
            break;
          case "complete":
            if (message.url) {
              setDownloadState({ isLoading: false, progress: 100 });
              window.location.href = message.url;
              websocket.close();
            }
            break;
          case "error":
            setDownloadState({
              isLoading: false,
              progress: 0,
              error: message.error,
            });
            websocket.close();
            break;
        }
      };

      websocket.onopen = () => {
        const payload = {
          albumId: album.albumId,
          password,
          quality,
          imageIds: selectedImages.length > 0 ? selectedImages : undefined,
        };
        websocket.send(JSON.stringify(payload));
      };

      websocket.onerror = () => {
        setDownloadState({
          isLoading: false,
          progress: 0,
          error: "Connection error occurred",
        });
      };
    },
    [album.albumId, password, selectedImages],
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
    </>
  );
}

export default HoneyDownloadButton;
