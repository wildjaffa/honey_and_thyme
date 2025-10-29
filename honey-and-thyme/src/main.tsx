import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import { QueryClient } from '@tanstack/query-core';
import { QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from "react-router";
import App from './App.tsx'
import Header from './lib/components/Header.tsx';

const queryClient = new QueryClient();

const root = document.getElementById('root');
if (!root) throw new Error("Failed to find the root element");

createRoot(root).render(
  <QueryClientProvider client={queryClient}>
    <StrictMode>
      <BrowserRouter>
        <Header currentScreen="gallery" googleFontsLoaded={true} />
        <App />
      </BrowserRouter>
    </StrictMode>
  </QueryClientProvider>
)
