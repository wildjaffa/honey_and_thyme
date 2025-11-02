
interface HoneyButtonProps {
    /** Button label */
    label?: string;
    onClick?: () => void;
}

function HoneyButton({ label, onClick }: HoneyButtonProps) {
    return <button className="px-4 py-2 im-fell-english bg-honey-gold text-black shadow-sm hover:shadow-md hover:cursor-pointer transition-colors" onClick={onClick}>{label || "Honey Button"}</button>;
}

export default HoneyButton;