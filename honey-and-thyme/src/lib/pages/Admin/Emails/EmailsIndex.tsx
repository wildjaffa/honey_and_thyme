import { HoneyPaginatedTable } from "../../../components";
import useEmails from "../../../hooks/useEmails";
import type { EmailRecordModel } from "../../../types/api";
import EmailRow from "./EmailRow";

function EmailIndex() {
  return (
    <HoneyPaginatedTable<EmailRecordModel>
      usePaginatedQuery={useEmails}
      searchHint="Search Emails"
      renderRow={(email, onUpdated) => <EmailRow email={email} onUpdated={() => onUpdated && onUpdated()} />}
    />
  );
}

export default EmailIndex;
