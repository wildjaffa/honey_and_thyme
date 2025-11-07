interface HoneyPageLoaderProps {
  message?: string;
  progress?: number;
}

function HoneyPageLoader({ message, progress }: HoneyPageLoaderProps) {
  return (
    <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-white">
      <div className="text-honey-gold mb-4 text-lg font-medium">
        {message || "Loading..."}
      </div>
      {progress !== undefined && (
        <div className="h-4 w-64 overflow-hidden rounded-full bg-gray-200">
          <div
            className="bg-honey-gold h-full transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
      )}
    </div>
  );
}

export default HoneyPageLoader;
