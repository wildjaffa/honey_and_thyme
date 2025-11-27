import HoneyCircularLoader from "./HoneyCircularLoader";
import hexagons from "../../assets/images/hexagons.png";
import logoNoHexagons from "../../assets/images/logo-no-hexagons.png";
import "../styles/HoneyPageLoader.css";

interface HoneyPageLoaderProps {
  message?: string;
  progress?: number;
  fullCoverage?: boolean;
}

function HoneyPageLoader({
  message,
  progress,
  fullCoverage = false,
}: HoneyPageLoaderProps) {
  const onLogoLoad = () => {
    const logo = document.getElementById("logo");
    if (!logo) return;
    logo.style.opacity = "1";
  };

  if (fullCoverage) {
    return (
      <>
        <div
          className="no-doc-scroll bg-honey-gray fixed inset-0 z-99"
          aria-hidden="true"
        ></div>
        <div className="z-100" id="full-page-loader-parent">
          <img
            className="hexagons full-page-loader"
            alt="Loading..."
            id="hexagons"
            src={hexagons}
          />
          <img
            onLoad={onLogoLoad}
            className="full-page-loader"
            id="logo"
            src={logoNoHexagons}
          />
        </div>
      </>
    );
  }

  return (
    <>
      {/* Dimmed backdrop covering the page */}
      <div
        className="no-doc-scroll fixed inset-0 z-50 bg-black/50"
        aria-hidden="true"
      />

      {/* Centered card with content. pointer-events-none on outer wrapper lets backdrop block background clicks while allowing the card to be interactive if needed. */}
      <div className="pointer-events-none fixed inset-0 z-50 flex items-center justify-center p-4">
        <div
          role="status"
          aria-live="polite"
          className="pointer-events-auto flex w-full max-w-md flex-col items-center rounded-2xl bg-white/95 px-6 py-4 shadow-2xl dark:bg-gray-900/90"
        >
          <div className="flex w-full items-center gap-4">
            <div className="shrink-0">
              {progress === undefined ? (
                <HoneyCircularLoader size="large" />
              ) : (
                <div className="w-44">
                  <div className="h-3 w-full overflow-hidden rounded-full bg-gray-200">
                    <div
                      className="bg-honey-gold h-full transition-all duration-500"
                      style={{
                        width: `${Math.max(0, Math.min(100, progress))}%`,
                      }}
                    />
                  </div>
                </div>
              )}
            </div>

            <div className="flex-1 text-left">
              <div className="text-lg font-semibold text-black dark:text-white">
                {message || "Loading..."}
              </div>
              {progress !== undefined && (
                <div className="mt-1 text-sm text-gray-600 dark:text-gray-300">
                  {Math.round(Math.max(0, Math.min(100, progress)))}% complete
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default HoneyPageLoader;
