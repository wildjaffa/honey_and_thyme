import { useId } from "react";

interface HoneyCheckboxProps {
  id?: string;
  label?: string;
  checked: boolean;
  onChange?: (checked: boolean) => void;
  required?: boolean;
  autoFocus?: boolean;
  name?: string;
  disabled?: boolean;
}

function HoneyCheckbox({
  id,
  label,
  checked,
  onChange,
  required = false,
  autoFocus = false,
  name,
  disabled = false,
}: HoneyCheckboxProps) {
  const autoId = useId();
  if (!id) id = autoId;

  return (
    <div className="flex items-center gap-2">
      <input
        id={id}
        type="checkbox"
        checked={checked}
        onChange={(e) => onChange && onChange(e.target.checked)}
        className={`border-honey-sage accent-honey-gold focus:ring-honey-gold focus:border-honey-gold h-4 w-4 rounded border-2 bg-white ${disabled ? "opacity-50" : ""}`}
        required={required}
        autoFocus={autoFocus}
        name={name}
        disabled={disabled}
      />

      {label && (
        <label
          htmlFor={id}
          className="im-fell-english text-sm text-gray-700 select-none"
        >
          {label} {required && <span className="text-xs text-red-500">*</span>}
        </label>
      )}
    </div>
  );
}

export default HoneyCheckbox;
