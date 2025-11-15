import { useId } from "react";
import HoneyLabel from "./HoneyLabel";

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
        <input
          id={id}
          type={type}
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
      )}
    </>
  );
}

export default HoneyInput;
