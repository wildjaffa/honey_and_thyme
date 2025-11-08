import { useId } from "react";

interface HoneyInputProps {
  id?: string;
  label: string;
  value: string;
  onChange?: (value: string) => void;
  type?: string;
  required?: boolean;
  placeholder?: string;
}

function HoneyInput({
  id,
  label,
  value,
  onChange,
  type = "text",
  required = false,
  placeholder = "",
}: HoneyInputProps) {
  const autoId = useId();
  if(!id) id = autoId;
  return (
    <div className="mb-4">
      <label htmlFor={id} className="im-fell-english mb-1 block text-sm font-medium text-gray-700">
        {label} {required && <span className="text-xs text-red-500">*</span>}
      </label>
      {type === "textarea" ? (
        <textarea
          id={id}
          value={value}
          onChange={(e) => onChange && onChange(e.target.value)}
          className="border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-full rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none"
          required={required}
          placeholder={placeholder}
          name={label}
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
        />
      )}
    </div>
  );
}

export default HoneyInput;
