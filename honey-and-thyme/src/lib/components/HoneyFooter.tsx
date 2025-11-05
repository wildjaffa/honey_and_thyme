import logo from "../../assets/images/logo.png";

export const footerHeight = 300;

function HoneyFooter() {
  return (
    <footer className="py-12">
      <div className="flex justify-center">
        <img
          src={logo}
          alt="Honey & Thyme logo"
          width={footerHeight}
          height={footerHeight}
          className="object-contain"
          style={{ filter: "none" }}
        />
      </div>
    </footer>
  );
}

export default HoneyFooter;
