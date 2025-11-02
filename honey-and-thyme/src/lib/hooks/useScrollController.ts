import { useEffect, useRef } from 'react';

interface UseScrollControllerProps {
    scrollAmount?: number;
    duration?: number;
}

export default function useScrollController({
    scrollAmount = 100,
    duration = 100
}: UseScrollControllerProps = {}) {
    const scrollRef = useRef<HTMLDivElement>(null);

    const scrollBy = (amount: number) => {
        if (!scrollRef.current) return;

        scrollRef.current.scrollTo({
            top: scrollRef.current.scrollTop + amount,
            behavior: 'smooth'
        });
    };

    const scrollUp = () => scrollBy(-scrollAmount);
    const scrollDown = () => scrollBy(scrollAmount);

    return {
        scrollRef,
        scrollUp,
        scrollDown
    };
}