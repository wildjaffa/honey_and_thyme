interface HoneyInputProps {
  label: string;
  value: string;
  onChange: (value: string) => void;
  type?: string;
  required?: boolean;
}

function HoneyInput({
  label,
  value,
  onChange,
  type = "text",
  required = false,
}: HoneyInputProps) {
  return (
    <div className="mb-4">
      <label className="im-fell-english mb-1 block text-sm font-medium text-gray-700">
        {label} {required && <span className="text-xs text-red-500">*</span>}
      </label>
      {type === "textarea" ? (
        <textarea
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-full rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none"
        />
      ) : (
        <input
          type={type}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="border-honey-sage focus:ring-honey-gold focus:border-honey-gold w-full rounded-md border-2 bg-white px-3 py-2 shadow-sm focus:outline-none"
          required={required}
        />
      )}
    </div>
  );
}

export default HoneyInput;
