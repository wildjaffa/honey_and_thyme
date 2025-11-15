interface HoneyLabelProps {
  label: string;
  id: string;
  required: boolean;
}

function HoneyLabel({ label, id, required }: HoneyLabelProps) {
  return (
    <>
      <label
        htmlFor={id}
        className="im-fell-english mb-1 block text-sm font-medium text-gray-700"
      >
        {label} {required && <span className="text-xs text-red-500">*</span>}
      </label>
    </>
  );
}

export default HoneyLabel;
