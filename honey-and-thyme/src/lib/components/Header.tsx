import { useCallback, useEffect, useRef, useState } from 'react';
import '../../assets/fonts/March-Rough.ttf';

type ScreenKey = 'pricing' | 'gallery' | 'contact' | string;

interface HeaderProps {
    currentScreen: ScreenKey;
    /** When true the Google fonts (or other fonts) have finished loading and nav may be shown */
    googleFontsLoaded: boolean;
};

/**
 * Header component translated from Flutter `CustomAppBar` (app_bar.dart).
 * Uses Tailwind CSS for layout and styling.
 */
function Header({ currentScreen, googleFontsLoaded }: HeaderProps) {
    const [isWide, setIsWide] = useState<boolean>(() => window.innerWidth >= 500);

    useEffect(() => {
        const onResize = () => setIsWide(window.innerWidth >= 500);
        window.addEventListener('resize', onResize);
        return () => window.removeEventListener('resize', onResize);
    }, []);

    // Long-press handling for admin navigation (press/hold on the title).
    const longPressTimer = useRef<number | null>(null);
    const startLongPress = useCallback(() => {
        // 600ms threshold for a long press
        longPressTimer.current = window.setTimeout(() => {
            window.location.assign('/admin');
        }, 600);
    }, []);
    const clearLongPress = useCallback(() => {
        if (longPressTimer.current) {
            clearTimeout(longPressTimer.current);
            longPressTimer.current = null;
        }
    }, []);

    const navigate = useCallback((to: string) => {
        window.location.assign(to);
    }, []);

    const fontSizeClass = isWide ? 'text-[60px]' : 'text-[40px]';

    return (
        <div className="flex flex-col bg-honey-gray">
            <div className="w-full bg-gray bg-opacity-90 shadow-md" style={{ boxShadow: '0 0 10px rgba(128,128,128,0.6)' }}>
                <div className="h-[150px] flex flex-col">
                    <div className="h-[100px] flex items-center justify-center">
                        <div
                            role="button"
                            tabIndex={0}
                            onClick={() => navigate('/')}
                            onPointerDown={startLongPress}
                            onPointerUp={() => { clearLongPress(); }}
                            onPointerLeave={() => { clearLongPress(); }}
                            onKeyDown={(e) => { if (e.key === 'Enter') navigate('/'); }}
                            className="cursor-pointer"
                        >
                            <span
                                className={`${fontSizeClass} font-extrabold text-black select-none march-rough`}
                                style={{ textShadow: '0px 0px 7px rgba(0, 0, 0, 0.35)' }}
                            >
                                Honey+Thyme
                            </span>
                        </div>
                    </div>

                    {/* separator */}
                    <div className="w-full h-1 bg-honey-gold" />

                    {/* Nav (wait until fonts loaded) */}
                    <div className="flex justify-center h-9">
                        <div className="w-full flex items-center justify-center">
                            <div className="w-full transition-opacity duration-200">
                                {googleFontsLoaded ? (
                                    <div className="flex items-center justify-center w-full">
                                        <div className="flex-1" />
                                        <NavItem
                                            title="Pricing"
                                            route="/pricing"
                                            isSelected={currentScreen === 'pricing'}
                                            fontSizeMultiplier={isWide ? 1 : 0.75}
                                        />
                                        <div className="flex-1" />
                                        <NavItem
                                            title="Gallery"
                                            route="/gallery"
                                            isSelected={currentScreen === 'gallery'}
                                            fontSizeMultiplier={isWide ? 1 : 0.75}
                                        />
                                        <div className="flex-1" />
                                        <NavItem
                                            title="Contact"
                                            route="/contact"
                                            isSelected={currentScreen === 'contact'}
                                            fontSizeMultiplier={isWide ? 1 : 0.75}
                                        />
                                        <div className="flex-1" />
                                    </div>
                                ) : (
                                    <div style={{ minHeight: 24 * (isWide ? 1 : 0.75) }}>&nbsp;</div>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* separator */}
                    <div className="w-full h-1 bg-honey-gold" />
                </div>
            </div>
        </div>
    );
}

function NavItem({
    title,
    route,
    isSelected,
    fontSizeMultiplier,
}: {
    title: string;
    route: string;
    isSelected: boolean;
    fontSizeMultiplier: number;
}) {
    const [hovering, setHovering] = useState(false);
    const fontSize = `${24 * fontSizeMultiplier}px`;
    const textColor = isSelected || hovering ? 'text-honey-gold' : 'text-black';

    return (
        <div
            className="flex items-center cursor-pointer select-none im-fell-english-sc-regular gap-1.5"
            onMouseEnter={() => setHovering(true)}
            onMouseLeave={() => setHovering(false)}
            onClick={() => window.location.assign(route)}
        >
            <span
                className={`${hovering ? 'text-honey-gold' : 'text-black'}`}
                style={{ fontSize }}
            >
                •
            </span>
            <span
                className={textColor}
                style={{
                    fontSize,
                }}
            >
                {title}
            </span>
            <span
                className={`${hovering ? 'text-honey-gold' : 'text-black'}`}
                style={{ fontSize }}
            >
                •
            </span>
        </div>
    );
}

export default Header;

