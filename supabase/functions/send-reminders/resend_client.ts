import type { EmailMessage, EmailSender, EmailSendResult } from "./types.ts";

export interface ResendEmailSenderOptions {
  apiKey: string;
  fromEmail: string;
  endpoint?: string;
  fetchImpl?: typeof fetch;
}

/**
 * Minimal transactional email sender targeting the Resend REST API using the
 * API key supplied via Supabase Edge Function secrets (`RESEND_API_KEY`).
 */
export class ResendEmailSender implements EmailSender {
  readonly #apiKey: string;
  readonly #fromEmail: string;
  readonly #endpoint: string;
  readonly #fetchImpl: typeof fetch;

  constructor(options: ResendEmailSenderOptions) {
    this.#apiKey = options.apiKey.trim();
    this.#fromEmail = options.fromEmail.trim();
    this.#endpoint = options.endpoint ?? "https://api.resend.com/emails";
    this.#fetchImpl = options.fetchImpl ?? fetch;
  }

  async send(message: EmailMessage): Promise<EmailSendResult> {
    if (!this.#apiKey) {
      throw new Error("RESEND_API_KEY secret is missing.");
    }
    if (!this.#fromEmail) {
      throw new Error("RESEND_FROM_EMAIL configuration is missing.");
    }

    const response = await this.#fetchImpl(this.#endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.#apiKey}`,
      },
      body: JSON.stringify({
        from: this.#fromEmail,
        to: [message.to],
        subject: message.subject,
        html: message.html,
        text: message.text,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `Resend API responded with HTTP ${response.status}: ${errorText}`,
      );
    }

    const json = (await response.json()) as { id?: string | null };
    return {
      messageId: json.id ?? null,
    };
  }
}
