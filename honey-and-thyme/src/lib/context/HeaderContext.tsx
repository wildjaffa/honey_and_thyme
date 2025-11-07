import { createContext, useState, type ReactNode } from "react";

interface HeaderContextType {
  setToolbarItems: (items: ReactNode) => void;
  toolbarItems: ReactNode | null;
  hideUntilScroll: boolean;
  setHideUntilScroll: (hide: boolean) => void;
}

const HeaderContext = createContext<HeaderContextType | undefined>(undefined);

export function HeaderProvider({ children }: { children: ReactNode }) {
  const [toolbarItems, setToolbarItems] = useState<ReactNode | null>(null);
  const [hideUntilScroll, setHideUntilScroll] = useState<boolean>(false);

  return (
    <HeaderContext.Provider
      value={{
        toolbarItems,
        setToolbarItems,
        hideUntilScroll,
        setHideUntilScroll,
      }}
    >
      {children}
    </HeaderContext.Provider>
  );
}

export default HeaderContext;
