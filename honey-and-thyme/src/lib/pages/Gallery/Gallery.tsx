import useAlbum from '../../hooks/useAlbum';
import { ImageSlideshow } from '../../components/ImageSlideshow';
import Masonry, { ResponsiveMasonry } from 'react-responsive-masonry'
import HoneyFadeInImage from '../../components/HoneyFadeInImage';
import { useWindowWidth } from '@react-hook/window-size';
import { useState } from 'react';



function Gallery() {
    const [slideShowIsOpen, setSlideShowIsOpen] = useState(false);
    const [currentImageIndex, setCurrentImageIndex] = useState(0);
    const { data: album, error, isLoading } = useAlbum('gallery');

    const width = useWindowWidth();
    let pictureWidth = 200;
    if (width >= 1200) {
        pictureWidth = Math.floor(width / 5) - 5;
    } else if (width >= 900) {
        pictureWidth = Math.floor(width / 4) - 5;
    } else if (width >= 750) {
        pictureWidth = Math.floor(width / 3) - 5;
    } else if (width >= 350) {
        pictureWidth = Math.floor(width / 2) - 5;
    }


    if (isLoading) {
        return (
            <div className="flex justify-center items-center h-screen">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" />
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex justify-center items-center h-screen">
                <p className="text-red-500">Error loading gallery</p>
            </div>
        );
    }

    if (!album?.images?.length) {
        return (
            <div className="flex justify-center items-center h-screen">
                <p>No images found</p>
            </div>
        );
    }

    return (
        <div>
            <ResponsiveMasonry columnsCountBreakPoints={{ 350: 2, 750: 3, 900: 4, 1200: 5 }}>
                <Masonry style={{ gap: '5px' }} itemStyle={{ gap: '5px' }} sequential={true}>
                    {album.images.map((image, index) => (
                        <div
                            key={image.imageId ?? index}
                            className="cursor-pointer"
                            onClick={() => {
                                setSlideShowIsOpen(true);
                                setCurrentImageIndex(index);
                            }}
                        >
                            <HoneyFadeInImage pixelWidth={pictureWidth} image={image} imageQuality={2} />
                        </div>
                    ))}
                </Masonry>
            </ResponsiveMasonry>

            {/* Slideshow */}
            <ImageSlideshow
                isOpen={slideShowIsOpen}
                images={album.images}
                currentIndex={currentImageIndex}
                onClose={() => setSlideShowIsOpen(false)}
            />
        </div>
    );
}

export default Gallery;
