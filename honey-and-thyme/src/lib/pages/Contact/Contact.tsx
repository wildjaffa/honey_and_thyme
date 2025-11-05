import React, { useState } from "react";
import { useWindowWidth } from "@react-hook/window-size";
import instagram from "../../../assets/images/Instagram_Glyph_Gradient.png";
import facebook from "../../../assets/images/Facebook_Logo_Primary.png";
import useContactForm from "../../hooks/useContactForm";
import { HoneyButton, HoneyInput } from "../../components/";

function ExternalLinkIcon({
  linkUrl,
  assetPath,
}: {
  linkUrl: string;
  assetPath: string;
}) {
  return (
    <div
      className="cursor-pointer"
      onClick={() => window.open(linkUrl, "_blank")}
    >
      <img
        src={assetPath}
        alt="external link"
        width={50}
        height={50}
        className="object-contain"
      />
    </div>
  );
}

function ContactForm() {
  const { fields, setField, submit, status, error } = useContactForm();
  const [touched, setTouched] = useState(false);

  const isSending = status === "sending";
  const isSent = status === "sent";

  const valid =
    fields.email.trim().length > 3 && fields.message.trim().length > 0;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setTouched(true);
    if (!valid) return;
    await submit();
  }

  return (
    <form onSubmit={handleSubmit} className="w-full p-4">
      <div className="flex flex-col space-y-3">
        <div className="im-fell-english font-bold">Contact</div>
        <HoneyInput
          label="Email"
          value={fields.email}
          onChange={(value) => setField("email", value)}
          required
          type="email"
        />
        <HoneyInput
          label="Message"
          value={fields.message}
          onChange={(value) => setField("message", value)}
          required
          type="textarea"
        />

        <div className="flex items-center justify-end space-x-4">
          <HoneyButton
            isLoading={isSending}
            label={isSent ? "Sent" : "Send"}
            onClick={() => submit()}
            isSubmit
          />

          {status === "failed" && (
            <p className="text-red-600">
              Failed to send{error ? `: ${error}` : ""}
            </p>
          )}

          {isSent && (
            <p className="text-green-700">
              Thanks — I'll get back to you soon.
            </p>
          )}
        </div>

        {touched && !valid && (
          <p className="text-red-600">
            Please provide a valid email and a message.
          </p>
        )}
      </div>
    </form>
  );
}

function Contact() {
  const width = useWindowWidth({ wait: 50 });
  const formWidth =
    width < 450
      ? Math.max(220, width - 80)
      : Math.min(500, Math.floor(width / 3));

  return (
    <div className="flex w-full justify-center">
      <div className="w-full max-w-[900px] pt-8">
        <div className="flex flex-col items-center">
          <div className="max-w-[600px] p-4 text-center">
            <p className="font-['IM_Fell_English'] text-lg text-black">
              Follow me on Facebook and Instagram to see all my upcoming events
              and deals.
            </p>
          </div>

          <div className="flex items-center space-x-30 py-2">
            <ExternalLinkIcon
              linkUrl={
                "https://www.instagram.com/honeyandthymephotography?igsh=ZDd4cTk2M3cwYzU5"
              }
              assetPath={instagram}
            />
            <ExternalLinkIcon
              linkUrl={
                "https://www.facebook.com/profile.php?id=100088143396234"
              }
              assetPath={facebook}
            />
          </div>

          <div style={{ width: formWidth }} className="w-full">
            <ContactForm />
          </div>
        </div>
      </div>
    </div>
  );
}

export default Contact;
