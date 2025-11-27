import { createRoot } from "react-dom/client";
import "./index.css";

import App from "./App.tsx";

const root = document.getElementById("root");
if (!root) throw new Error("Failed to find the root element");

// Hide the loader once React is ready
const loaderParent = document.getElementById("loader-parent");
if (loaderParent) {
  // Wait for the next frame to ensure React has rendered
  requestAnimationFrame(() => {
    loaderParent.style.display = "none";
  });
}

createRoot(root).render(<App />);
