import type { IconProp } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import HoneyCircularLoader from "./HoneyCircularLoader";
import "./HoneyIconButton.css";
// import { useState } from "react";

interface HoneyButtonProps {
  /** Button label */
  icon: IconProp;
  onClick?: () => void;
  disabled?: boolean;
  isSubmit?: boolean;
  isLoading?: boolean;
  children?: React.ReactNode;
  ariaLabel?: string;
  isSelected?: boolean;
}

function HoneyIconButton({
  icon,
  onClick,
  disabled,
  isSubmit,
  isLoading,
  ariaLabel,
  isSelected,
}: HoneyButtonProps) {
  const rippleEffect = (
    event: React.MouseEvent<HTMLButtonElement, MouseEvent>,
  ) => {
    const btn = event.currentTarget;
    const circle = document.createElement("span");
    const diameter = Math.max(btn.clientWidth, btn.clientHeight);

    circle.style.width = circle.style.height = `${diameter}px`;
    circle.style.left = `50%`;
    circle.style.top = `50%`;
    circle.classList.add("ripple");

    const ripple = btn.getElementsByClassName("ripple")[0];

    if (ripple) {
      ripple.remove();
    }
    btn.appendChild(circle);
  };

  return (
    <button
      disabled={disabled || isLoading}
      type={isSubmit ? "submit" : "button"}
      onClick={(e) => {
        rippleEffect(e);
        e.stopPropagation();
        if (onClick) {
          onClick();
        }
      }}
      aria-label={ariaLabel}
      className="group/icon relative cursor-pointer overflow-hidden rounded-full p-1 hover:bg-white/30 focus:outline-none"
    >
      <div className="relative z-10 flex h-5 w-5 items-center justify-center">
        {isLoading && (
          <HoneyCircularLoader
            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-white"
            size="small"
          />
        )}
        {!isLoading && (
          <FontAwesomeIcon
            className={`${isSelected ? "text-honey-gold opacity-100" : "text-honey-pink"} opacity-50 group-hover/icon:opacity-100`}
            icon={icon}
          />
        )}
      </div>
    </button>
  );
}

export default HoneyIconButton;
