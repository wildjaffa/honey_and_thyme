import { createContext, useState, type ReactNode } from "react";

interface HeaderContextType {
  setToolbarItems: (items: ReactNode) => void;
  toolbarItems: ReactNode | null;
}

const HeaderContext = createContext<HeaderContextType | undefined>(undefined);

export function HeaderProvider({ children }: { children: ReactNode }) {
  const [toolbarItems, setToolbarItems] = useState<ReactNode | null>(null);

  return (
    <HeaderContext.Provider value={{ toolbarItems, setToolbarItems }}>
      {children}
    </HeaderContext.Provider>
  );
}

export default HeaderContext;
