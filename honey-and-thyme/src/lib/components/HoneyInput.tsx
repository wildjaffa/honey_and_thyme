import { useId } from "react";
import HoneyLabel from "./HoneyLabel";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import type { IconProp } from "@fortawesome/fontawesome-svg-core";

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
  onFocus?: () => void;
  onBlur?: () => void;
  startIcon?: IconProp;
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
  onFocus,
  onBlur,
  startIcon,
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
          className="border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-full rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none"
          required={required}
          placeholder={placeholder}
          name={label}
          autoFocus={autoFocus}
          disabled={disabled}
          onFocus={onFocus}
          onBlur={onBlur}
        />
      ) : (
        <div className="flex w-full items-center">
          {startIcon && <FontAwesomeIcon icon={startIcon} className="pr-3" />}
          <input
            id={id}
            type={type}
            value={value}
            onChange={(e) => onChange && onChange(e.target.value)}
            className="border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-fit flex-1 rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none"
            required={required}
            placeholder={placeholder}
            name={label}
            autoFocus={autoFocus}
            disabled={disabled}
            onFocus={onFocus}
            onBlur={onBlur}
          />
        </div>
      )}
    </>
  );
}

export default HoneyInput;
