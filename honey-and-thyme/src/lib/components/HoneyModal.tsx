import { faXmark } from "@fortawesome/free-solid-svg-icons";
import HoneyIconButton from "./HoneyIconButton";
import HoneyButton from "./HoneyButton";

interface HoneyModalProps {
  children?: React.ReactNode;
  onClose: () => void;
  onSubmit?: () => void;
  submitText?: string;
  isOpen: boolean;
  isLoading?: boolean;
}

function HoneyModal({
  children,
  onClose,
  onSubmit,
  submitText,
  isOpen,
  isLoading,
}: HoneyModalProps) {
  if (!isOpen) return null;
  return (
    <>
      <div
        onClick={onClose}
        className="no-doc-scroll fixed inset-0 z-50 flex items-center justify-center bg-black/50"
      >
        <dialog
          onClick={(e) => e.stopPropagation()}
          open
          className="bg-honey-gray im-fell-english relative w-full max-w-md rounded-lg p-6"
        >
          <div className="absolute top-4 right-4">
            <HoneyIconButton
              title="Close"
              icon={faXmark}
              onClick={onClose}
              nonSelectedColor="black"
            />
          </div>
          {children}
          {onSubmit && (
            <div className="mt-6 flex justify-center space-x-3">
              <HoneyButton onClick={onClose}> Cancel</HoneyButton>
              <HoneyButton
                onClick={() => {
                  onSubmit();
                }}
                isLoading={isLoading}
              >
                {submitText ? submitText : "Download"}
              </HoneyButton>
            </div>
          )}
        </dialog>
      </div>
    </>
  );
}

export default HoneyModal;
