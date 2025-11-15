import HoneyCircularLoader from "./HoneyCircularLoader";

interface HoneyButtonProps {
  /** Button label */
  label?: string;
  onClick?: () => void;
  disabled?: boolean;
  isSubmit?: boolean;
  isLoading?: boolean;
  children?: React.ReactNode;
}

function HoneyButton({
  label,
  onClick,
  disabled,
  isSubmit,
  isLoading,
  children,
}: HoneyButtonProps) {
  return (
    <button
      type={isSubmit ? "submit" : "button"}
      className={`im-fell-english relative flex min-w-20 items-center justify-center px-4 py-1 text-black shadow-sm transition-colors ${disabled ? "bg-honey-gold/40" : "bg-honey-gold/90 hover:bg-honey-gold cursor-pointer hover:shadow-md"}`}
      onClick={onClick}
      disabled={isLoading || disabled}
    >
      {/* keep the label/children in the flow to preserve button width; hide visually when loading */}
      <span className={isLoading ? "invisible" : "visible"}>
        {children || label || "Honey Button"}
      </span>

      {/* absolute-centered loader so it doesn't affect layout */}
      {isLoading && (
        <HoneyCircularLoader
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-white"
          size="small"
        />
      )}
    </button>
  );
}

export default HoneyButton;
