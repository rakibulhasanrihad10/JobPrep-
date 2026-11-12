import { createClient } from "npm:@supabase/supabase-js@2.49.1";

import { createReminderHandler } from "./handler.ts";
import { SupabaseNotificationStore } from "./notifications_store.ts";
import { ResendEmailSender } from "./resend_client.ts";
import { SupabaseReminderStore } from "./supabase_store.ts";

const DEFAULT_TIMEZONE_OFFSET_MINUTES = 360; // Asia/Dhaka (+06:00)

function parseTimezoneOffsetMinutes(raw: string | undefined): number {
  if (!raw || !raw.trim()) return DEFAULT_TIMEZONE_OFFSET_MINUTES;
  const parsed = Number.parseInt(raw.trim(), 10);
  return Number.isFinite(parsed) ? parsed : DEFAULT_TIMEZONE_OFFSET_MINUTES;
}

Deno.serve((request: Request) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const resendApiKey = Deno.env.get("RESEND_API_KEY") ?? "";
  const fromEmail =
    Deno.env.get("RESEND_FROM_EMAIL") ?? "JobPrep <reminders@jobprep.app>";
  const cronSecret = Deno.env.get("REMINDER_CRON_SECRET") ?? "";
  const timeZoneOffsetMinutes = parseTimezoneOffsetMinutes(
    Deno.env.get("REMINDER_TIMEZONE_OFFSET_MINUTES"),
  );

  if (!supabaseUrl || !serviceRoleKey) {
    return Response.json(
      { error: "Supabase service credentials are missing in environment." },
      { status: 500 },
    );
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const handler = createReminderHandler({
    cronSecret,
    store: new SupabaseReminderStore(adminClient),
    notificationStore: new SupabaseNotificationStore(adminClient),
    emailSender: new ResendEmailSender({
      apiKey: resendApiKey,
      fromEmail,
    }),
    timeZoneOffsetMinutes,
  });

  return handler(request);
});
