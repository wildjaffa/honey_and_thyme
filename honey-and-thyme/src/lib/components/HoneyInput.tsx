import { useId, isValidElement } from "react";
import HoneyLabel from "./HoneyLabel";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import type { IconProp } from "@fortawesome/fontawesome-svg-core";
import { getLocalDateTimeString } from "../utils/date";

interface HoneyInputProps {
  id?: string;
  label?: string;
  value: string;
  onChange?: (value: string) => void;
  type?: React.HTMLInputTypeAttribute;
  required?: boolean;
  placeholder?: string;
  autoFocus?: boolean;
  disabled?: boolean;
  readOnly?: boolean;
  onFocus?: () => void;
  onBlur?: () => void;
  onClick?: () => void;
  onKeyDown?: (e: React.KeyboardEvent<HTMLInputElement>) => void;
  startIcon?: IconProp | React.ReactNode;
  className?: string;
}

function HoneyInput({
  id,
  label,
  value,
  onChange,
  type = "text",
  required = false,
  placeholder = "",
  autoFocus,
  disabled,
  readOnly,
  onFocus,
  onBlur,
  onClick,
  onKeyDown,
  startIcon,
  className = "",
}: HoneyInputProps) {
  const autoId = useId();
  if (!id) id = autoId;
  return (
    <>
      {label && <HoneyLabel id={id} label={label} required={required} />}
      {type === "textarea" ? (
        <textarea
          id={id}
          value={value}
          onChange={(e) => onChange && onChange(e.target.value)}
          className={`border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-full rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none ${className}`}
          required={required}
          placeholder={placeholder}
          name={label}
          autoFocus={autoFocus}
          disabled={disabled}
          readOnly={readOnly}
          onFocus={onFocus}
          onBlur={onBlur}
          onClick={onClick}
        />
      ) : (
        <div className="flex w-full items-center">
          {startIcon &&
            (isValidElement(startIcon) ? (
              <span className="pr-3">{startIcon}</span>
            ) : (
              <FontAwesomeIcon icon={startIcon as IconProp} className="pr-3" />
            ))}
          <input
            id={id}
            type={type}
            value={
              type === "datetime-local" ? getLocalDateTimeString(value) : value
            }
            onChange={(e) => {
              if (onChange) {
                if (type === "datetime-local") {
                  const date = new Date(e.target.value);
                  if (!isNaN(date.getTime())) {
                    onChange(date.toISOString());
                  } else {
                    onChange("");
                  }
                } else {
                  onChange(e.target.value);
                }
              }
            }}
            className={`border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-fit flex-1 rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none ${className}`}
            required={required}
            placeholder={placeholder}
            name={label}
            autoFocus={autoFocus}
            disabled={disabled}
            readOnly={readOnly}
            onFocus={onFocus}
            onBlur={onBlur}
            onClick={onClick}
            onKeyDown={onKeyDown}
          />
        </div>
      )}
    </>
  );
}

export default HoneyInput;
