import type { ImageModel } from '../types/api';
// import useKeyboardNavigation from '../hooks/useKeyboardNavigation';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowLeft, faArrowRight, faXmark } from '@fortawesome/free-solid-svg-icons';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Navigation, Keyboard, A11y, Virtual } from 'swiper/modules';
import { Swiper as SwiperType } from 'swiper';
import HoneyImage from './HoneImage';
import './ImageSlideshow.css';
import { useRef } from 'react';


export interface ImageSlideshowProps {
    isOpen: boolean;
    images: ImageModel[];
    currentIndex: number;
    onClose: () => void;

}


export function ImageSlideshow({
    isOpen, images, currentIndex, onClose
}: ImageSlideshowProps) {

    const swiperRef = useRef<SwiperType>(null);
    if (!isOpen) return null;

    return (
        <div className="w-full h-full fixed inset-0 bg-black/80 z-50">
            <button
                aria-label='Close slideshow'
                onClick={onClose}
                className="absolute cursor-pointer top-4 right-4 text-white text-2xl z-60"
            >
                <FontAwesomeIcon className='text-honey-gold' icon={faXmark} />
            </button>
            <Swiper
                initialSlide={currentIndex}
                modules={[Navigation, Keyboard, A11y, Virtual]}
                onBeforeInit={(swiper) => {
                    swiperRef.current = swiper;
                }}
                centeredSlides={true}
                slidesPerView={1}
                navigation={{ nextEl: '#next-button', prevEl: '#prev-button' }}
                keyboard={{ enabled: true }}
                virtual
            >
                {images.map((image, index) => (
                    <SwiperSlide key={image.imageId} virtualIndex={index}>
                        <div className='flex justify-center items-center h-screen align-middle object-contain'>
                            <HoneyImage image={image} imageQuality={1} />
                        </div>
                    </SwiperSlide>
                ))}
            </Swiper>
            <button
                id='prev-button'
                aria-label='Previous Slide'
                className="absolute cursor-pointer left-4 top-1/2 text-white text-4xl disabled:opacity-50 z-60"
            >
                <FontAwesomeIcon className='text-honey-gold text-2xl' icon={faArrowLeft} />
            </button>
            <button
                id='next-button'
                aria-label='Next Slide'
                className="absolute cursor-pointer right-4 top-1/2 text-white text-4xl disabled:opacity-50 z-60"
            >
                <FontAwesomeIcon className='text-honey-gold text-2xl' icon={faArrowRight} />
            </button>
        </div>
    );
}
