import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import { QueryClient } from '@tanstack/query-core';
import { QueryClientProvider } from '@tanstack/react-query';
import Header from './lib/components/Header.tsx';
import Footer from './lib/components/Footer.tsx';
import Home from './lib/pages/Home/Home.tsx';
import Pricing from './lib/pages/Pricing/Pricing.tsx';
import { BrowserRouter, Routes, Route } from 'react-router';
import Gallery from './lib/pages/Gallery/Gallery.tsx';

const queryClient = new QueryClient();

const root = document.getElementById('root');
if (!root) throw new Error("Failed to find the root element");

createRoot(root).render(
  <QueryClientProvider client={queryClient}>
    <StrictMode>
      <BrowserRouter>
        <Header googleFontsLoaded={true} />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/pricing" element={<Pricing />} />
          <Route path="/gallery" element={<Gallery />} />
        </Routes>
        {/* <App /> */}
        <Footer />
      </BrowserRouter>
    </StrictMode>
  </QueryClientProvider>
)
