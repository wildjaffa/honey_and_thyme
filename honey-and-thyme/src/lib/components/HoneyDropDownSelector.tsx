import { useState, useRef, useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faChevronDown } from "@fortawesome/free-solid-svg-icons";
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
  const [highlightedIndex, setHighlightedIndex] = useState<number>(-1);
  const listRef = useRef<HTMLUListElement>(null);
  const itemRefs = useRef<Map<number, HTMLLIElement>>(new Map());

  // Reset highlighted index when dropdown opens
  useEffect(() => {
    if (focus) {
      setHighlightedIndex(-1);
    }
  }, [focus]);

  // Scroll highlighted item into view
  useEffect(() => {
    if (highlightedIndex >= 0 && highlightedIndex < items.length) {
      const itemElement = itemRefs.current.get(highlightedIndex);
      if (itemElement && listRef.current) {
        const listRect = listRef.current.getBoundingClientRect();
        const itemRect = itemElement.getBoundingClientRect();

        if (itemRect.bottom > listRect.bottom) {
          itemElement.scrollIntoView({ block: "nearest", behavior: "smooth" });
        } else if (itemRect.top < listRect.top) {
          itemElement.scrollIntoView({ block: "nearest", behavior: "smooth" });
        }
      }
    }
  }, [highlightedIndex, items.length]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (disabled) return;

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        if (!focus) {
          setFocus(true);
          setHighlightedIndex(0);
        } else {
          setHighlightedIndex((prev) =>
            prev < items.length - 1 ? prev + 1 : prev,
          );
        }
        break;

      case "ArrowUp":
        e.preventDefault();
        if (!focus) {
          setFocus(true);
          setHighlightedIndex(items.length - 1);
        } else {
          setHighlightedIndex((prev) => (prev > 0 ? prev - 1 : prev));
        }
        break;

      case "Enter":
        e.preventDefault();
        if (focus && highlightedIndex >= 0 && highlightedIndex < items.length) {
          const selectedItem = items[highlightedIndex];
          if (selectedItem) {
            onSelect(selectedItem);
            setDisplayString(displayValue(selectedItem));
            setFocus(false);
          }
        } else if (!focus) {
          setFocus(true);
        }
        break;

      case "Escape":
        e.preventDefault();
        setFocus(false);
        setHighlightedIndex(-1);
        break;

      case "Home":
        e.preventDefault();
        if (focus && items.length > 0) {
          setHighlightedIndex(0);
        }
        break;

      case "End":
        e.preventDefault();
        if (focus && items.length > 0) {
          setHighlightedIndex(items.length - 1);
        }
        break;

      case "Tab":
        // Allow default tab behavior but close dropdown
        setFocus(false);
        setHighlightedIndex(-1);
        break;
    }
  };

  const handleItemClick = (item: T) => {
    onSelect(item);
    setDisplayString(displayValue(item));
    setFocus(false);
    setHighlightedIndex(-1);
  };

  return (
    <div className="honey-dropdown-selector relative">
      <div className="relative">
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
          onKeyDown={handleKeyDown}
          onBlur={() => {
            // Delay hiding to allow click event on options to fire
            setTimeout(() => {
              setFocus(false);
              setHighlightedIndex(-1);
            }, 200);
          }}
        />
        <FontAwesomeIcon
          icon={faChevronDown}
          className={`text-honey-sage pointer-events-none absolute top-1/2 right-3 -translate-y-1/2 transition-transform duration-200 ${
            focus ? "rotate-180" : ""
          }`}
          style={{ marginTop: label ? "0.75rem" : "0" }}
        />
      </div>
      {focus && (
        <ul
          ref={listRef}
          className="border-honey-gold absolute z-10 mt-2 max-h-60 w-full overflow-auto rounded-md border-2 bg-white shadow-sm"
          role="listbox"
          aria-activedescendant={
            highlightedIndex >= 0 && highlightedIndex < items.length
              ? (() => {
                  const item = items[highlightedIndex];
                  return item
                    ? `dropdown-option-${keyExtractor(item)}`
                    : undefined;
                })()
              : undefined
          }
        >
          {items.length > 0 ? (
            items.map((item, index) => (
              <li
                key={keyExtractor(item)}
                id={`dropdown-option-${keyExtractor(item)}`}
                ref={(el) => {
                  if (el) {
                    itemRefs.current.set(index, el);
                  } else {
                    itemRefs.current.delete(index);
                  }
                }}
                className={`cursor-pointer px-3 py-2 ${
                  highlightedIndex === index
                    ? "bg-honey-gold/20"
                    : "hover:bg-gray-50"
                }`}
                role="option"
                aria-selected={highlightedIndex === index}
              >
                <button
                  type="button"
                  className="w-full cursor-pointer text-left"
                  onMouseDown={(e) => {
                    e.preventDefault(); // Prevent blur
                    handleItemClick(item);
                  }}
                  onMouseEnter={() => setHighlightedIndex(index)}
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
