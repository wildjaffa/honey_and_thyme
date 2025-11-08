import HoneyCircularLoader from "./HoneyCircularLoader";

interface HoneyPageLoaderProps {
  message?: string;
  progress?: number;
}

function HoneyPageLoader({ message, progress }: HoneyPageLoaderProps) {
  return (
    <>
      {/* Dimmed backdrop covering the page */}
      <div
        className="fixed inset-0 z-50 bg-black/50 no-doc-scroll"
        aria-hidden="true"
      />

      {/* Centered card with content. pointer-events-none on outer wrapper lets backdrop block background clicks while allowing the card to be interactive if needed. */}
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 pointer-events-none">
        <div
          role="status"
          aria-live="polite"
          className="pointer-events-auto max-w-md w-full bg-white/95 dark:bg-gray-900/90 rounded-2xl shadow-2xl px-6 py-4 flex flex-col items-center"
        >
          <div className="flex items-center w-full gap-4">
            <div className="shrink-0">
              {progress === undefined ? (
                <HoneyCircularLoader size="large" />
              ) : (
                <div className="w-44">
                  <div className="h-3 w-full overflow-hidden rounded-full bg-gray-200">
                    <div
                      className="bg-honey-gold h-full transition-all duration-500"
                      style={{ width: `${Math.max(0, Math.min(100, progress))}%` }}
                    />
                  </div>
                </div>
              )}
            </div>

            <div className="flex-1 text-left">
              <div className="text-black dark:text-white text-lg font-semibold">
                {message || "Loading..."}
              </div>
              {progress !== undefined && (
                <div className="text-sm text-gray-600 dark:text-gray-300 mt-1">
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
