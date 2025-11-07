import { useCallback, useEffect, useRef, useState } from "react";
import "../../assets/fonts/March-Rough.ttf";
import { NavLink, useNavigate } from "react-router";
import { useHeader } from "../hooks/useHeader";

function HoneyHeader() {
  const [isWide, setIsWide] = useState<boolean>(() => window.innerWidth >= 500);
  const navigate = useNavigate();
  const { toolbarItems, hideUntilScroll } = useHeader();
  const [scrolled, setScrolled] = useState(false);
  const [hideHeaderClasses, setHideHeaderClasses] = useState("sticky left-0");

  useEffect(() => {
    const onResize = () => setIsWide(window.innerWidth >= 500);
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 100);
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    if (!hideUntilScroll) {
      setHideHeaderClasses("sticky");
      return;
    }
    let classes = "fixed ";
    if (scrolled) {
      classes += "opacity-100 pointer-events-auto";
    } else {
      classes += "opacity-0 pointer-events-none";
    }
    setHideHeaderClasses(classes);
  }, [scrolled, hideUntilScroll]);
  // Long-press handling for admin navigation (press/hold on the title).
  const longPressTimer = useRef<number | null>(null);
  const startLongPress = useCallback(() => {
    // 600ms threshold for a long press
    longPressTimer.current = window.setTimeout(() => {
      navigate("/admin");
    }, 600);
  }, [navigate]);
  const clearLongPress = useCallback(() => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
      longPressTimer.current = null;
    }
  }, []);

  const fontSizeClass = isWide ? "text-[60px]" : "text-[40px]";

  return (
    // Make header fixed so it doesn't take vertical space and can overlay the cover image.
    <header
      className={`bg-honey-gray top-0 left-0 z-10 flex w-full flex-col transition-opacity duration-300 ${hideHeaderClasses}`}
    >
      <div
        className="bg-gray bg-opacity-90 w-full"
        style={{ boxShadow: "0 0 10px rgba(128,128,128,0.6)" }}
      >
        <div className="flex h-[150px] flex-col shadow-md">
          <div className="flex h-[100px] items-center justify-center">
            <div
              role="button"
              tabIndex={0}
              onClick={() => navigate("/")}
              onPointerDown={startLongPress}
              onPointerUp={() => {
                clearLongPress();
              }}
              onPointerLeave={() => {
                clearLongPress();
              }}
              onKeyDown={(e) => {
                if (e.key === "Enter") navigate("/");
              }}
              className="cursor-pointer"
            >
              <span
                className={`${fontSizeClass} march-rough font-extralight text-black select-none`}
                style={{ textShadow: "0px 0px 7px rgba(0, 0, 0, 0.35)" }}
              >
                Honey+Thyme
              </span>
            </div>
          </div>

          {/* separator */}
          <div className="bg-honey-gold h-1 w-full" />

          <div className="flex h-9 justify-center">
            <div className="flex w-full items-center justify-center">
              <div className="w-full transition-opacity duration-200">
                <div className="flex w-full items-center justify-center">
                  <div className="flex-1" />
                  <NavItem
                    title="Pricing"
                    route="/pricing"
                    fontSizeMultiplier={isWide ? 1 : 0.75}
                  />
                  <div className="flex-1" />
                  <NavItem
                    title="Gallery"
                    route="/gallery"
                    fontSizeMultiplier={isWide ? 1 : 0.75}
                  />
                  <div className="flex-1" />
                  <NavItem
                    title="Contact"
                    route="/contact"
                    fontSizeMultiplier={isWide ? 1 : 0.75}
                  />
                  <div className="flex-1" />
                </div>
              </div>
            </div>
          </div>

          {/* separator */}
          <div className="bg-honey-gold h-1 w-full" />
        </div>
        {toolbarItems && (
          <div className="flex w-full items-center justify-end px-4 py-2">
            {toolbarItems}
          </div>
        )}
      </div>
    </header>
  );
}

function NavItem({
  title,
  route,
  fontSizeMultiplier,
}: {
  title: string;
  route: string;
  fontSizeMultiplier: number;
}) {
  const fontSize = `${24 * fontSizeMultiplier}px`;

  return (
    <NavLink
      to={route}
      className={({ isActive }: { isActive: boolean }) =>
        `group im-fell-english-sc-regular flex cursor-pointer items-center gap-1.5 select-none ${isActive ? "text-honey-gold" : "text-black"}`
      }
    >
      {/* bullets and title inherit color from the parent */}
      <span
        className="group-hover:text-honey-gold text-black"
        style={{ fontSize }}
      >
        •
      </span>
      <span style={{ fontSize }}>{title}</span>
      <span
        className="group-hover:text-honey-gold text-black"
        style={{ fontSize }}
      >
        •
      </span>
    </NavLink>
  );
}

export default HoneyHeader;
