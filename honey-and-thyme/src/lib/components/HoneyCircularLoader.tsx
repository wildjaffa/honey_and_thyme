interface HoneyCircularLoaderProps {
  size?: "small" | "medium" | "large";
  color?: string;
  className?: string;
}

function HoneyCircularLoader({
  size = "medium",
  className = "text-honey-gold", // Default to an amber color to match honey theme
}: HoneyCircularLoaderProps) {
  const sizeClasses = {
    small: "w-4 h-4 border-2",
    medium: "w-10 h-10 border-3",
    large: "w-16 h-16 border-4",
  };

  return (
    <div className="inline-flex items-center justify-center">
      <div
        className={` ${sizeClasses[size]} ${className} animate-spin rounded-full border-solid border-t-transparent`}
        role="status"
        aria-label="Loading"
      />
    </div>
  );
}

export default HoneyCircularLoader;
