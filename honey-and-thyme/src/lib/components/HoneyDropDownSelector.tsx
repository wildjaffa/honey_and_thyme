import { useState } from "react";
import HoneyInput from "./HoneyInput";

interface HoneyDropDownSelectorProps<T> {
  label?: string;
  placeholder?: string;
  items: T[];
  displayValue: (item: T) => string;
  keyExtractor: (item: T) => string | number;
  onSelect: (item: T | undefined) => void;
  disabled?: boolean;
}

function HoneyDropDownSelector<T>({
  label,
  placeholder,
  items,
  displayValue,
  keyExtractor,
  onSelect,
  disabled,
}: HoneyDropDownSelectorProps<T>) {
  const [displayString, setDisplayString] = useState("");
  const [focus, setFocus] = useState(false);

  return (
    <div className="honey-dropdown-selector relative">
      <HoneyInput
        type="text"
        label={label}
        value={displayString}
        placeholder={placeholder}
        disabled={disabled}
        readOnly={true}
        className="cursor-pointer caret-transparent"
        onFocus={() => setFocus(true)}
        onClick={() => setFocus(true)}
        onBlur={() => {
          // Delay hiding to allow click event on options to fire
          setTimeout(() => setFocus(false), 200);
        }}
      />
      {focus && (
        <ul
          className="border-honey-gold absolute z-10 mt-2 max-h-60 w-full overflow-auto rounded-md border-2 bg-white shadow-sm"
          role="listbox"
        >
          {items.length > 0 ? (
            items.map((item) => (
              <li
                key={keyExtractor(item)}
                className="cursor-pointer px-3 py-2 hover:bg-gray-50"
                role="option"
              >
                <button
                  type="button"
                  className="w-full cursor-pointer text-left"
                  onMouseDown={(e) => {
                    e.preventDefault(); // Prevent blur
                    onSelect(item);
                    setDisplayString(displayValue(item));
                    setFocus(false);
                  }}
                >
                  <span className="block text-sm text-gray-900">
                    {displayValue(item)}
                  </span>
                </button>
              </li>
            ))
          ) : (
            <li className="p-3 text-sm text-gray-600">No items</li>
          )}
        </ul>
      )}
    </div>
  );
}

export default HoneyDropDownSelector;
