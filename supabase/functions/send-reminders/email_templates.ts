import type {
  EmailLanguage,
  EmailMessage,
  ReminderCandidate,
} from "./types.ts";

const BANGLA_DIGITS = ["০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯"];

function toBanglaDigits(input: string): string {
  return input.replace(/[0-9]/g, (digit) => BANGLA_DIGITS[Number(digit)]);
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function examStageLabel(
  stage: string | null,
  language: EmailLanguage,
): string {
  const normalized = (stage ?? "other").toLowerCase();
  if (language === "bn") {
    switch (normalized) {
      case "preliminary":
        return "প্রিলিমিনারি";
      case "written":
        return "লিখিত";
      case "viva":
        return "ভাইভা";
      case "practical":
        return "ব্যবহারিক";
      default:
        return "পরীক্ষা";
    }
  }

  switch (normalized) {
    case "preliminary":
      return "Preliminary";
    case "written":
      return "Written";
    case "viva":
      return "Viva";
    case "practical":
      return "Practical";
    default:
      return "Exam";
  }
}

function leadBadgeLabel(daysBefore: number, language: EmailLanguage): string {
  if (language === "bn") {
    if (daysBefore === 1) return "আগামীকাল (১ দিন বাকি)";
    return `${toBanglaDigits(String(daysBefore))} দিন বাকি`;
  }
  if (daysBefore === 1) return "Tomorrow (1 day left)";
  return `${daysBefore} days left`;
}

function kindLabel(item: ReminderCandidate, language: EmailLanguage): string {
  if (item.reminderKind === "circular_deadline") {
    return language === "bn" ? "আবেদনের শেষ তারিখ" : "Application deadline";
  }
  const stage = examStageLabel(item.examStage, language);
  return language === "bn" ? `${stage} পরীক্ষা` : `${stage} exam`;
}

function formatDisplayDate(
  isoDate: string,
  language: EmailLanguage,
): string {
  return language === "bn" ? toBanglaDigits(isoDate) : isoDate;
}

/**
 * Renders a localized bilingual HTML and plain-text digest email summarizing
 * all due 7-, 3-, and 1-day reminders for a single user.
 */
export function renderReminderEmail(params: {
  recipientEmail: string;
  language: EmailLanguage;
  items: ReadonlyArray<ReminderCandidate>;
}): EmailMessage {
  const { recipientEmail, language, items } = params;
  const countStr = language === "bn"
    ? toBanglaDigits(String(items.length))
    : String(items.length);

  const subject = language === "bn"
    ? `JobPrep অনুস্মারক: আপনার ${countStr}টি আসন্ন সময়সীমা ও পরীক্ষা`
    : `JobPrep Reminder: ${countStr} upcoming ${
      items.length === 1 ? "date" : "dates"
    }`;

  const heading = language === "bn"
    ? "JobPrep আসন্ন সময়সীমা ও পরীক্ষার অনুস্মারক"
    : "Upcoming JobPrep Deadlines & Exams";

  const intro = language === "bn"
    ? "নিম্নলিখিত চাকরির সার্কুলারের আবেদনের শেষ তারিখ ও পরীক্ষার সূচি শীঘ্রই আসছে:"
    : "Here are your tracked job circular deadlines and exam dates coming up in 7, 3, or 1 days:";

  const footer = language === "bn"
    ? "আপনি JobPrep-এর Settings থেকে যেকোনো সময় ইমেইল অনুস্মারক বন্ধ বা ভাষা পরিবর্তন করতে পারেন।"
    : "You can turn email reminders on or off and change your email language anytime in JobPrep Settings.";

  const htmlRows = items.map((item) => {
    const title = escapeHtml(item.circularTitle);
    const org = item.organizationName
      ? ` — ${escapeHtml(item.organizationName)}`
      : "";
    const kind = escapeHtml(kindLabel(item, language));
    const badge = escapeHtml(leadBadgeLabel(item.daysBefore, language));
    const dateText = escapeHtml(formatDisplayDate(item.targetDate, language));
    const venueLine = item.venue
      ? `<div style="color:#64748b;font-size:12px;margin-top:4px;">${
        language === "bn" ? "কেন্দ্র: " : "Venue: "
      }${escapeHtml(item.venue)}</div>`
      : "";

    return `
      <tr>
        <td style="padding:14px 16px;border:1px solid #1e293b;border-radius:8px;background:#0f172a;">
          <div style="font-size:12px;font-weight:600;color:#d4af37;">${kind} · ${badge}</div>
          <div style="font-size:16px;font-weight:600;color:#f8fafc;margin-top:4px;">${title}${org}</div>
          <div style="font-size:13px;color:#cbd5e1;margin-top:4px;">${
      language === "bn" ? "তারিখ: " : "Date: "
    }${dateText}</div>
          ${venueLine}
        </td>
      </tr>
      <tr><td style="height:10px;"></td></tr>`;
  }).join("\n");

  const html = `<!DOCTYPE html>
<html lang="${language}">
<body style="margin:0;padding:24px;background:#070d1a;color:#e2e8f0;font-family:Inter,Noto Sans Bengali,Arial,sans-serif;">
  <table role="presentation" style="max-width:600px;width:100%;margin:0 auto;border-collapse:collapse;">
    <tr>
      <td style="padding:24px;border-radius:12px;background:#0b1324;border:1px solid #1e293b;">
        <h1 style="margin:0 0 8px;font-size:20px;color:#d4af37;">${
    escapeHtml(heading)
  }</h1>
        <p style="margin:0 0 18px;font-size:14px;line-height:1.5;color:#cbd5e1;">${
    escapeHtml(intro)
  }</p>
        <table role="presentation" style="width:100%;border-collapse:collapse;">
          ${htmlRows}
        </table>
        <p style="margin:16px 0 0;font-size:12px;line-height:1.5;color:#94a3b8;">${
    escapeHtml(footer)
  }</p>
      </td>
    </tr>
  </table>
</body>
</html>`;

  const textLines = items.map((item) => {
    const org = item.organizationName ? ` (${item.organizationName})` : "";
    const venue = item.venue
      ? ` | ${language === "bn" ? "কেন্দ্র" : "Venue"}: ${item.venue}`
      : "";
    return `- [${kindLabel(item, language)} | ${
      leadBadgeLabel(item.daysBefore, language)
    }] ${item.circularTitle}${org} — ${
      formatDisplayDate(item.targetDate, language)
    }${venue}`;
  });

  const text = `${heading}\n\n${intro}\n\n${textLines.join("\n")}\n\n${footer}`;

  return {
    to: recipientEmail,
    subject,
    html,
    text,
  };
}
