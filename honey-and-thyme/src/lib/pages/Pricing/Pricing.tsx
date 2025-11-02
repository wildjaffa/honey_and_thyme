import { useState } from 'react';
import useImageUrl from '../../hooks/useImageUrl';
import type { ImageModel } from '../../types/api';
import { useNavigate } from 'react-router';
import useImageSize from '../../hooks/useImageSize';
import useAlbum from '../../hooks/useAlbum';
import HoneyButton from '../../components/HoneyButton';

interface PricingEntryData {
    title: string;
    description: string;
    fileName: string;
    imageWidth: number;
}

const pricingEntries: PricingEntryData[] = [
    {
        title: 'The Mini - $85',
        description: '15 minutes with unlimited edited images back. Up to 5 people. Message for pricing for additional people',
        fileName: 'TheMini.jpg',
        imageWidth: 400,
    },
    {
        title: 'The Half - $115',
        description: '30 minutes with unlimited edited images back. Up to 5 people. Message for pricing for additional people',
        fileName: 'TheHalf.png',
        imageWidth: 200,
    },
    {
        title: 'The Full - $150',
        description: '60 minutes with unlimited edited images back. Up to 5 people. Message for pricing for additional people.',
        fileName: 'TheFull.png',
        imageWidth: 400,
    },
    {
        title: 'The Double - $250',
        description: '120 minutes with unlimited edited images back. Up to 5 people. Message for pricing for additional people.',
        fileName: 'TheDouble.png',
        imageWidth: 200,
    },
];

interface PricingEntryProps {
    pricingEntryData: PricingEntryData;
    width: number;
    image?: ImageModel;
    backgroundColor: string;
    multiplier: number;
}

function PricingEntry({ pricingEntryData, width, image, backgroundColor, multiplier }: PricingEntryProps) {
    const navigate = useNavigate();
    const [loaded, setLoaded] = useState(false);
    const imageUrl = useImageUrl(image?.imageId, 2); // 2 corresponds to large size
    const imageSize = useImageSize(image as ImageModel, pricingEntryData.imageWidth * multiplier);

    if (!image?.imageId) return null;

    return (
        <div
            className="flex justify-center items-center p-2"
            style={{
                minHeight: imageSize.height,
                maxWidth: width,
                backgroundColor,
            }}
        >
            <div className="pr-4 pl-2">
                <img
                    src={imageUrl}
                    alt={pricingEntryData.title}
                    width={imageSize.width}
                    height={imageSize.height}
                    onLoad={() => setLoaded(true)}
                    style={{
                        opacity: loaded ? 1 : 0,
                        transition: 'opacity 1s ease-in',
                    }}
                />
            </div>
            <div className="flex flex-col items-start">
                <h2 className="text-lg font-['IM_Fell_English_SC']  text-black">
                    {pricingEntryData.title}
                </h2>
                <p
                    className="text-sm font-thin font-['IM_Fell_English'] text-black"
                    style={{ width: width - (imageSize.width + 50) }}
                >
                    {pricingEntryData.description}
                </p>
                <HoneyButton
                    onClick={() => navigate('/booking')}
                    label="Book Now"
                />
            </div>
        </div>
    );
};

function Pricing() {
    const navigate = useNavigate();
    const { data: album, error, isLoading } = useAlbum('site-images');

    const isMobile = typeof window !== 'undefined' ? window.innerWidth < 600 : true;
    const screenWidth = Math.min(isMobile ? window.innerWidth : 600, 600);
    const multiplier = isMobile ? 0.5 : 1.0;

    if (isLoading) return <div className="flex justify-center"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" /></div>;
    if (error) return <div className="text-center">Error loading pricing page</div>;

    return (
        <div className="w-full flex justify-center">
            <div className="w-full max-w-[600px] pt-4">
                <div className="flex flex-col space-y-4">
                    {pricingEntries.map((entry, index) => (
                        <PricingEntry
                            key={entry.fileName}
                            pricingEntryData={entry}
                            width={screenWidth}
                            multiplier={multiplier}
                            image={album?.images?.find(img => img.fileName === entry.fileName)}
                            backgroundColor={index % 2 === 0 ? 'transparent' : 'var(--color-honey-sage)'}

                        />
                    ))}

                    <div className="text-center py-8 px-4">
                        <p className="text-lg font-['IM_Fell_English']">
                            Don't see what you need?{' '}
                            <button
                                onClick={() => navigate('/contact')}
                                className="text-honey-gold font-bold underline cursor-pointer hover:text-[#8B6508]"
                            >
                                CONTACT ME
                            </button>
                            . I'd love to create a custom package for you!
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Pricing;
