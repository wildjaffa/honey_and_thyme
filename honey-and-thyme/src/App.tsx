import { StrictMode } from "react";
import { QueryClientProvider } from "@tanstack/react-query";
import HoneyHeader from "./lib/components/HoneyHeader.tsx";
import HoneyFooter from "./lib/components/HoneyFooter.tsx";
import { HeaderProvider } from "./lib/context/HeaderContext";
import Home from "./lib/pages/Home/Home.tsx";
import Pricing from "./lib/pages/Pricing/Pricing.tsx";
import { BrowserRouter, Routes, Route } from "react-router";
import Gallery from "./lib/pages/Gallery/Gallery.tsx";
import Contact from "./lib/pages/Contact/Contact.tsx";
import AlbumGallery from "./lib/pages/AlbumGallery/AlbumGallery.tsx";
import { QueryClient } from "@tanstack/query-core";
import { ToastContainer } from "react-toastify";
import UpcomingAppointments from "./lib/pages/UpcomingAppointments/UpcomingAppointments.tsx";
import Admin from "./lib/pages/Admin/Admin.tsx";
import "./lib/firebase";
import Invoice from "./lib/pages/Invoice/Invoice.tsx";
import Booking from "./lib/pages/Booking/Booking.tsx";

const queryClient = new QueryClient();

function App() {
  return (
    <>
      <QueryClientProvider client={queryClient}>
        <StrictMode>
          <BrowserRouter>
            <HeaderProvider>
              <HoneyHeader />
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="admin/*" element={<Admin />} />
                <Route path="/albums/:albumId" element={<AlbumGallery />} />
                <Route
                  path="/available-appointments"
                  element={<UpcomingAppointments />}
                />
                <Route path="/booking" element={<Booking />} />
                <Route path="/contact" element={<Contact />} />
                <Route path="/gallery" element={<Gallery />} />
                <Route path="/invoice/:reservationCode" element={<Invoice />} />
                <Route path="/pricing" element={<Pricing />} />
              </Routes>
              {/* <App /> */}
              <HoneyFooter />
            </HeaderProvider>
            <ToastContainer className={"z-100"} />
          </BrowserRouter>
        </StrictMode>
      </QueryClientProvider>
    </>
  );
}
export default App;
