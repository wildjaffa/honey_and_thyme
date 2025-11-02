import { useEffect, useRef } from 'react';

interface UseKeyboardNavigationProps {
    onArrowUp?: () => void;
    onArrowDown?: () => void;
    onArrowLeft?: () => void;
    onArrowRight?: () => void;
    onEscape?: () => void;
    enabled?: boolean;
}

export default function useKeyboardNavigation({
    onArrowUp,
    onArrowDown,
    onArrowLeft,
    onArrowRight,
    onEscape,
    enabled = true
}: UseKeyboardNavigationProps) {
    const ignoreNextKey = useRef(false);

    useEffect(() => {
        if (!enabled) return;

        const handleKeyDown = (event: KeyboardEvent) => {
            if (ignoreNextKey.current) {
                ignoreNextKey.current = false;
                return;
            }

            ignoreNextKey.current = true;

            switch (event.key) {
                case 'ArrowUp':
                    onArrowUp?.();
                    break;
                case 'ArrowDown':
                    onArrowDown?.();
                    break;
                case 'ArrowLeft':
                    onArrowLeft?.();
                    break;
                case 'ArrowRight':
                    onArrowRight?.();
                    break;
                case 'Escape':
                    onEscape?.();
                    break;
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [enabled, onArrowUp, onArrowDown, onArrowLeft, onArrowRight, onEscape]);
}