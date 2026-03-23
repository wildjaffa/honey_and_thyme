import { useEffect, useState } from "react";

import type { ImageModel } from "../../types/api";
import useImageUrl from "../../hooks/useImageUrl";
import ImageSize from "../../enums/imageSize";
import useImageSize from "../../hooks/useImageSize";
import useAlbum from "../../hooks/useAlbum";
import { useWindowWidth } from "@react-hook/window-size";

const fileNames = [
  "IMG_1636.jpg",
  "PXL_20221218_174920383.PORTRAIT.jpg",
  "PXL_20231109_195510638.PORTRAIT.ORIGINAL.jpg",
  "PXL_20220620_001017270.PORTRAIT.jpg",
  "IMG_1832.jpg",
  "PXL_20231129_211208106.PORTRAIT.jpg",
];

function useController(durationSeconds = 5, upperBound = 5) {
  const [value, setValue] = useState(0);

  useEffect(() => {
    let raf = 0;
    const start = performance.now();

    function tick(now: number) {
      const t = Math.min(1, (now - start) / (durationSeconds * 1000));
      setValue(t * upperBound);
      if (t < 1) raf = requestAnimationFrame(tick);
    }

    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [durationSeconds, upperBound]);

  return value;
}

interface HomePageImageProps {
  image: ImageModel;
  controllerValue: number;
  delayInSeconds: number;
  width?: number;
  height?: number;
}

function HomePageImage({
  image,
  controllerValue,
  delayInSeconds,
  width,
  height,
}: HomePageImageProps) {
  const [loaded, setLoaded] = useState(false);
  const imageUrl = useImageUrl(image.imageId, ImageSize.medium);
  const size = useImageSize(image, width ?? null, height ?? null);

  // only render the img after controller value passes the delay (mimics Flutter animation controller)
  const show = controllerValue >= delayInSeconds;

  return (
    <div
      style={{ width: size.width, height: size.height }}
      className="relative"
    >
      <img
        src={imageUrl}
        alt={image.fileName ?? "photo"}
        onLoad={() => setLoaded(true)}
        style={{
          opacity: loaded && show ? 1 : 0,
          transition: "opacity 1s ease-in",
          objectFit: "cover",
          width: size.width,
          height: size.height,
        }}
      />
    </div>
  );
}

function Home() {
  const controllerValue = useController(5, 5);

  const width = useWindowWidth({ wait: 10 });
  const isMobile = width < 768;

  const { data, error, isLoading } = useAlbum("site-images");

  if (isLoading) {
    return (
      <div className="w-full">
        {isMobile ? (
          <div className="flex flex-col pt-20">
            <div className="px-2" style={{ height: 250 }} />
            <div className="p-2" style={{ height: 350 }} />
          </div>
        ) : (
          <div className="flex flex-col">
            <div
              className="px-2 pt-15"
              style={{ height: Math.min(450, width / 2) }}
            />
            <div className="p-2" style={{ height: Math.min(450, width / 2) }} />
          </div>
        )}
      </div>
    );
  }

  if (error)
    return (
      <div className="p-4">Sorry, there was an issue loading the images.</div>
    );

  const album = data;

  // Helper to find image by filename in album.images
  const findImage = (fileName?: string | null): ImageModel => {
    if (!fileName) return { fileName: "" };
    const list = (album?.images as ImageModel[]) ?? [];
    return list.find((i) => i.fileName === fileName) ?? { fileName };
  };

  return (
    <div className="w-full">
      {/* Mobile view */}
      {isMobile ? (
        <div className="flex flex-col pt-20">
          <div className="px-2" style={{ height: 250 }}>
            <div className="flex h-full items-end">
              <div className="flex-1" />
              <div className="pr-2">
                <HomePageImage
                  image={findImage(fileNames[0])}
                  width={150}
                  delayInSeconds={0}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="pr-2">
                <HomePageImage
                  image={findImage(fileNames[1])}
                  width={175}
                  delayInSeconds={2}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="flex-1" />
            </div>
          </div>

          <div className="p-2" style={{ height: 350 }}>
            <div className="flex h-full items-start">
              <div className="flex-1" />
              <div className="flex flex-col">
                <div className="pr-2">
                  <HomePageImage
                    image={findImage(fileNames[3])}
                    width={175}
                    delayInSeconds={3}
                    controllerValue={controllerValue}
                  />
                </div>
                <div className="pt-2 pr-2">
                  <HomePageImage
                    image={findImage(fileNames[2])}
                    width={175}
                    delayInSeconds={5}
                    controllerValue={controllerValue}
                  />
                </div>
              </div>

              <div className="flex flex-col">
                <div className="pr-2">
                  <HomePageImage
                    image={findImage(fileNames[4])}
                    width={165}
                    delayInSeconds={1}
                    controllerValue={controllerValue}
                  />
                </div>
                <div className="pt-2 pr-2">
                  <HomePageImage
                    image={findImage(fileNames[5])}
                    width={165}
                    delayInSeconds={4}
                    controllerValue={controllerValue}
                  />
                </div>
              </div>

              <div className="flex-1" />
            </div>
          </div>
        </div>
      ) : (
        /* Desktop view */
        <div className="flex flex-col">
          <div
            className="px-2 pt-15"
            style={{ height: Math.min(450, window.innerWidth / 2) }}
          >
            <div className="flex h-full items-end">
              <div className="flex-1" />
              <div className="pr-6">
                <HomePageImage
                  image={findImage(fileNames[0])}
                  width={183}
                  delayInSeconds={0}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="pr-6">
                <HomePageImage
                  image={findImage(fileNames[1])}
                  width={250}
                  delayInSeconds={2}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="pr-0">
                <HomePageImage
                  image={findImage(fileNames[2])}
                  width={250}
                  delayInSeconds={4}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="flex-1" />
            </div>
          </div>

          <div
            className="p-2"
            style={{ height: Math.min(450, window.innerWidth / 2) }}
          >
            <div className="flex h-full items-start">
              <div className="flex-1" />
              <div className="pr-2">
                <HomePageImage
                  image={findImage(fileNames[3])}
                  width={237.5}
                  delayInSeconds={3}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="pr-2">
                <HomePageImage
                  image={findImage(fileNames[4])}
                  width={233.75}
                  delayInSeconds={5}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="pr-0">
                <HomePageImage
                  image={findImage(fileNames[5])}
                  width={237.5}
                  delayInSeconds={1}
                  controllerValue={controllerValue}
                />
              </div>
              <div className="flex-1" />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Home;
