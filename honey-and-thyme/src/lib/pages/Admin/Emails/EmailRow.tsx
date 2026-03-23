import { faPaperPlane } from "@fortawesome/free-solid-svg-icons";
import { HoneyIconButton } from "../../../components";
import type { EmailRecordModel } from "../../../types/api";
import MessageStatus from "../../../enums/messageStatus";
import { toast } from "react-toastify";
import apiClient from "../../../api/client";
import { formatDateTime } from "../../../utils/date";

interface EmailRowProps {
  email: EmailRecordModel;
  onUpdated: () => void;
}

function EmailRow({ email, onUpdated }: EmailRowProps) {
  const resendEmailMutation = apiClient.useMutation(
    "post",
    "/api/EmailRecords/resend",
  );
  const resendEmail = async () => {
    try {
      await resendEmailMutation.mutateAsync({
        body: { emailRecordId: email.emailRecordId },
      });
      toast.success("Email resent succesfully");
      onUpdated();
    } catch (ex) {
      console.error(ex);
      toast.error("Error resending email");
    }
  };

  const openEmail = () => {
    const newWindow = window.open("about:blank", "", "_blank");
    if (!newWindow || !email.htmlMessage) {
      toast.error("There was a problem opening the email");
      return;
    }
    const body = newWindow.window.document.body;
    body.innerHTML = email.htmlMessage;
    window.open();
  };

  return (
    <div
      className="im-fell-english flex cursor-pointer"
      onClick={() => console.log("clicked")}
      key={`email-row-${email.emailRecordId}`}
    >
      <HoneyIconButton
        background="sage"
        onClick={resendEmail}
        icon={faPaperPlane}
        title={"Resend"}
        isSelected
        opacityOnHover
        selectedColor={
          email.status == MessageStatus.sent ? "honey-gold" : "honey-pink"
        }
      />
      <div className="min-w-0 flex-1 pl-2" onClick={openEmail}>
        <div className="truncate text-sm font-medium">{email.subject}</div>
        <div className="truncate text-xs text-gray-500">{email.email}</div>
      </div>

      <div className="flex items-center gap-2">
        {formatDateTime(email.dateSent)}
      </div>
    </div>
  );
}
export default EmailRow;
