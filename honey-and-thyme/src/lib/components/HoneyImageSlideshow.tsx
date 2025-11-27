import type { ImageModel } from "../types/api";
import {
  faArrowLeft,
  faArrowRight,
  faXmark,
} from "@fortawesome/free-solid-svg-icons";
import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, Keyboard, A11y, Virtual } from "swiper/modules";
import { Swiper as SwiperType } from "swiper";
import HoneyImage from "./HoneyImage";
import "../styles/SwiperStyles.css";
import { useRef } from "react";
import HoneyIconButton from "./HoneyIconButton";

export interface ImageSlideshowProps {
  isOpen: boolean;
  images: ImageModel[];
  currentIndex: number;
  onClose: () => void;
  password?: string | null;
}

export function HoneyImageSlideshow({
  isOpen,
  images,
  currentIndex,
  onClose,
  password,
}: ImageSlideshowProps) {
  const swiperRef = useRef<SwiperType>(null);
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 h-full w-full bg-black/80">
      <div className="absolute top-4 right-4 z-60">
        <HoneyIconButton
          title="Close Slideshow"
          icon={faXmark}
          onClick={onClose}
          opacityOnHover={false}
          isSelected
        />
      </div>

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
              <HoneyImage image={image} imageQuality={1} password={password} />
            </div>
          </SwiperSlide>
        ))}
      </Swiper>
      <div id="prev-button" className="absolute top-1/2 left-4 z-60">
        <HoneyIconButton
          title="Previous Slide"
          icon={faArrowLeft}
          ariaLabel="Previous Slide"
          isSelected
        />
      </div>
      <div id="next-button" className="absolute top-1/2 right-4 z-60">
        <HoneyIconButton
          title="Next Slide"
          icon={faArrowRight}
          ariaLabel="Next Slide"
          isSelected
        />
      </div>
    </div>
  );
}

export default HoneyImageSlideshow;
