import { useParams } from "react-router";
import { useEffect, useState } from "react";
import {
  HoneyButton,
  HoneyFadeInImage,
  HoneyGallery,
  HoneyInput,
  HoneyPageLoader,
} from "../../components";
import useAlbum from "../../hooks/useAlbum";
import { useHeader } from "../../hooks/useHeader";
import { faArrowDown } from "@fortawesome/free-solid-svg-icons";
import ImageSize from "../../enums/imageSize";
import { useWindowWidth } from "@react-hook/window-size";
import "../../styles/albumGallery.css";
import HoneyIconButton from "../../components/HoneyIconButton";
import HoneyDownloadButton from "../../components/HoneyDownloadButton";

function AlbumGallery() {
  const { setToolbarItems, setHideUntilScroll } = useHeader();
  const [coverLoaded, setCoverLoaded] = useState(false);
  const [selectedImages, setSelectedImages] = useState<string[]>([]);

  const params = useParams();
  const albumId = params.albumId;
  const [passwordField, setPasswordField] = useState("");
  const [submittedPassword, setSubmittedPassword] = useState<
    string | undefined
  >(undefined);
  const {
    password,
    data: album,
    isLoading,
    isError,
    error,
  } = useAlbum(albumId, submittedPassword);
  const windowWidth = useWindowWidth();

  useEffect(() => {
    setPasswordField(password);
  }, [password]);

  useEffect(() => {
    if (!album) return;
    setHideUntilScroll(true);
    setToolbarItems(
      <HoneyDownloadButton
        album={album}
        selectedImages={selectedImages}
        password={password}
      />,
    );
    return () => {
      setToolbarItems(null);
      setHideUntilScroll(false);
    };
  }, [setToolbarItems, setHideUntilScroll, album, selectedImages, password]);

  const onImageSelected = (imageId: string) => {
    setSelectedImages((prevSelectedImages: string[]) => {
      if (prevSelectedImages.includes(imageId)) {
        // Deselect image
        return prevSelectedImages.filter((id) => id !== imageId);
      } else {
        // Select image
        return [...prevSelectedImages, imageId];
      }
    });
  };

  const scrollPastCoverImage = () => {
    const header = document.querySelector("header");
    let position = window.innerHeight;
    if (header) {
      position -= header.clientHeight;
    }
    window.scrollTo({ top: position, behavior: "smooth" });
  };

  if (isError && error) {
    console.error("Error loading album:", error);
    return (
      <form
        className="flex h-full flex-col items-center justify-center gap-4 pt-50"
        onSubmit={() => {
          setSubmittedPassword(passwordField);
        }}
      >
        <HoneyInput
          id="password-input"
          label="Password"
          onChange={(value) => setPasswordField(value)}
          value={passwordField}
          placeholder="Enter album password"
        />
        <HoneyButton isSubmit label="Submit" />
      </form>
    );
  }

  if (isLoading) {
    return <HoneyPageLoader fullCoverage />;
  }
  if (!album || !album.images) {
    return (
      <div className="flex h-screen items-center justify-center">
        <p>No album found</p>
      </div>
    );
  }

  let coverImage = album.images.find(
    (img) => img.imageId === album.coverImageId,
  );
  if (!coverImage) {
    coverImage = album.images[0];
  }

  return (
    <>
      {!coverLoaded && <HoneyPageLoader fullCoverage />}
      <div className="relative min-h-screen">
        {/* Cover should fill the viewport initially but be in normal flow so it scrolls away. */}
        <div className="h-screen w-full">
          <div className="relative h-full w-full">
            {coverImage && (
              <HoneyFadeInImage
                image={coverImage}
                imageQuality={ImageSize.extraLarge}
                pixelWidth={windowWidth}
                className="h-full w-full"
                password={album.password}
                fitToRatio={false}
                onLoad={() => setCoverLoaded(true)}
              />
            )}
            <div className="absolute bottom-8 left-8">
              <h1 className="march-rough text-4xl text-white">{album.name}</h1>
            </div>
            <div className="absolute right-8 bottom-8 animate-bounce rounded-full p-1">
              <HoneyIconButton
                title="Scroll to album"
                icon={faArrowDown}
                onClick={scrollPastCoverImage}
                size="large"
                nonSelectedColor="white"
                opacityOnHover={false}
              />
            </div>
          </div>
        </div>
        <div className="min-h-screen pt-2">
          <HoneyGallery
            album={album}
            selectedImages={selectedImages}
            onImageSelected={onImageSelected}
            password={album.password}
          />
        </div>
      </div>
    </>
  );
}

export default AlbumGallery;
