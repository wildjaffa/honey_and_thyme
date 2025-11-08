import type { IconProp } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import HoneyCircularLoader from "./HoneyCircularLoader";
import "..//styles/HoneyIconButton.css";
import { useEffect, useRef, useState } from "react";

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
  size?: "small" | "medium" | "large";
  selectedColor?: string;
  nonSelectedColor?: string;
  opacityOnHover?: boolean;
  badge?: number;
  title: string;
}

function HoneyIconButton({
  icon,
  onClick,
  disabled,
  isSubmit,
  isLoading,
  ariaLabel,
  isSelected,
  size = "medium",
  selectedColor = "honey-gold",
  nonSelectedColor = "honey-pink",
  opacityOnHover = true,
  badge,
  title,
}: HoneyButtonProps) {
  const [prevIcon, setPrevIcon] = useState<IconProp | null>(null);
  const prevIconRef = useRef<IconProp | null>(null);

  useEffect(() => {
    // If there was a previous icon and it differs from the current one,
    // keep it around briefly so CSS animations can cross-fade.
    if (prevIconRef.current && prevIconRef.current !== icon) {
      setPrevIcon(prevIconRef.current);
      const id = window.setTimeout(() => setPrevIcon(null), 260);
      // update ref so next change uses the right previous value
      prevIconRef.current = icon;
      return () => window.clearTimeout(id);
    }
    prevIconRef.current = icon;
    return undefined;
  }, [icon]);
  const rippleEffect = (
    event: React.MouseEvent<HTMLButtonElement, MouseEvent>,
  ) => {
    const btn = event.currentTarget;
    const circle = document.createElement("span");
    const diameter = Math.max(btn.clientWidth, btn.clientHeight) / 2;

    circle.style.width = `${diameter}px`;
    circle.style.height = `${diameter}px`;
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
      title={title}
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
      className="group/icon relative cursor-pointer overflow-visible rounded-full p-1 hover:bg-white/30 focus:outline-none"
    >
      <div className="relative">
        <div
          className={`relative flex items-center justify-center ${
            size === "small"
              ? "size-6"
              : size === "large"
                ? "size-10"
                : "size-7"
          }`}
        >
          {isLoading && (
            <HoneyCircularLoader
              className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-white"
              size="small"
            />
          )}
          {!isLoading && (
            <div className="relative flex h-full w-full items-center justify-center">
              {prevIcon && (
                <FontAwesomeIcon
                  className={`icon-fade-out absolute ${
                    isSelected
                      ? `text-${selectedColor}`
                      : `text-${nonSelectedColor}`
                  } ${
                    size === "small"
                      ? "text-sm"
                      : size === "large"
                        ? "text-2xl"
                        : "text-xl"
                  } ${opacityOnHover ? "opacity-50 group-hover/icon:opacity-100" : ""}`}
                  icon={prevIcon}
                />
              )}

              <FontAwesomeIcon
                key={String(icon)}
                className={`${prevIcon ? "icon-fade-in" : ""} ${
                  isSelected
                    ? `text-${selectedColor} opacity-100`
                    : `text-${nonSelectedColor}`
                } ${
                  size === "small"
                    ? "text-sm"
                    : size === "large"
                      ? "text-2xl"
                      : "text-xl"
                } ${opacityOnHover ? "opacity-50 group-hover/icon:opacity-100" : ""}`}
                icon={icon}
              />
            </div>
          )}
        </div>
        {badge !== undefined && (
          <div className="bg-honey-gold absolute -top-1 -right-1 flex min-h-5 min-w-5 items-center justify-center overflow-visible rounded-full text-xs text-white">
            {badge}
          </div>
        )}
      </div>
    </button>
  );
}

export default HoneyIconButton;
