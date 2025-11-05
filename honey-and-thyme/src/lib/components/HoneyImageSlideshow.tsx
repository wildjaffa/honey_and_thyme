import type { ImageModel } from "../types/api";
// import useKeyboardNavigation from '../hooks/useKeyboardNavigation';
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowLeft,
  faArrowRight,
  faXmark,
} from "@fortawesome/free-solid-svg-icons";
import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, Keyboard, A11y, Virtual } from "swiper/modules";
import { Swiper as SwiperType } from "swiper";
import HoneyImage from "./HoneImage";
import "./ImageSlideshow.css";
import { useRef } from "react";

export interface ImageSlideshowProps {
  isOpen: boolean;
  images: ImageModel[];
  currentIndex: number;
  onClose: () => void;
}

export function HoneyImageSlideshow({
  isOpen,
  images,
  currentIndex,
  onClose,
}: ImageSlideshowProps) {
  const swiperRef = useRef<SwiperType>(null);
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 h-full w-full bg-black/80">
      <button
        aria-label="Close slideshow"
        onClick={onClose}
        className="absolute top-4 right-4 z-60 cursor-pointer text-2xl text-white"
      >
        <FontAwesomeIcon className="text-honey-gold" icon={faXmark} />
      </button>
      <Swiper
        initialSlide={currentIndex}
        modules={[Navigation, Keyboard, A11y, Virtual]}
        onBeforeInit={(swiper) => {
          swiperRef.current = swiper;
        }}
        centeredSlides={true}
        slidesPerView={1}
        navigation={{ nextEl: "#next-button", prevEl: "#prev-button" }}
        keyboard={{ enabled: true }}
        virtual
      >
        {images.map((image, index) => (
          <SwiperSlide key={image.imageId} virtualIndex={index}>
            <div className="flex h-screen items-center justify-center object-contain align-middle">
              <HoneyImage image={image} imageQuality={1} />
            </div>
          </SwiperSlide>
        ))}
      </Swiper>
      <button
        id="prev-button"
        aria-label="Previous Slide"
        className="absolute top-1/2 left-4 z-60 cursor-pointer text-4xl text-white disabled:opacity-50"
      >
        <FontAwesomeIcon
          className="text-honey-gold text-2xl"
          icon={faArrowLeft}
        />
      </button>
      <button
        id="next-button"
        aria-label="Next Slide"
        className="absolute top-1/2 right-4 z-60 cursor-pointer text-4xl text-white disabled:opacity-50"
      >
        <FontAwesomeIcon
          className="text-honey-gold text-2xl"
          icon={faArrowRight}
        />
      </button>
    </div>
  );
}

export default HoneyImageSlideshow;
