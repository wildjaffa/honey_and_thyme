import { useState } from "react";
import apiClient from "../api/client";

export interface ContactFormFields {
  email: string;
  message: string;
}

export type ContactStatus = "notSent" | "sending" | "sent" | "failed";

export default function useContactForm(initial?: Partial<ContactFormFields>) {
  const [fields, setFields] = useState<ContactFormFields>({
    email: initial?.email ?? "",
    message: initial?.message ?? "",
  });
  const [status, setStatus] = useState<ContactStatus>("notSent");
  const [error, setError] = useState<string | null>(null);

  function setField<K extends keyof ContactFormFields>(
    key: K,
    value: ContactFormFields[K],
  ) {
    setFields((f) => ({ ...f, [key]: value }));
  }

  async function submit(): Promise<boolean> {
    setStatus("sending");
    setError(null);
    const mutation = apiClient.useMutation("post", "/api/contact");
    try {
      // openapi-react-query expects the request body under `requestBody`
      await mutation.mutateAsync({
        body: { email: fields.email, message: fields.message },
      });
      setStatus("sent");
      return true;
    } catch (rawErr: unknown) {
      let msg = "Unknown error";
      if (rawErr && typeof rawErr === "object" && "message" in rawErr) {
        const rec = rawErr as Record<string, unknown>;
        const m = rec.message;
        if (typeof m === "string") msg = m;
      } else {
        msg = String(rawErr);
      }
      setError(msg ?? "Unknown error");
      setStatus("failed");
      return false;
    }
  }

  return {
    fields,
    setField,
    submit,
    status,
    error,
  } as const;
}
