import { useEffect, useState } from "react";

// interface UseDebounceProps {
//   value: unknown;
//   delay: number;
// }

function useDebounce<T>(value: T, delay: number) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);
  return debouncedValue;
}

export default useDebounce;
