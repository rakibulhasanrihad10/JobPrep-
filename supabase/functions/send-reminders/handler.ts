import { renderReminderEmail } from "./email_templates.ts";
import { dispatchDailyNotifications } from "./notifications_selector.ts";
import type {
  NotificationDispatchSummary,
  NotificationStore,
} from "./notifications_types.ts";
import { filterUnsentReminders, selectDueReminders } from "./selector.ts";
import type {
  EmailSender,
  NewReminderLogClaim,
  ReminderCandidate,
  ReminderRunSummary,
  ReminderStore,
} from "./types.ts";

export interface ProcessRemindersDeps {
  store: ReminderStore;
  notificationStore?: NotificationStore;
  emailSender: EmailSender;
  now?: () => Date;
  timeZoneOffsetMinutes?: number;
  providerName?: string;
}

/**
 * Constant-time string comparison guarding against timing side-channels on
 * shared cron secret validation.
 */
export function constantTimeEquals(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i += 1) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}

export function extractCronSecret(request: Request): string {
  const explicitHeader = request.headers.get("x-cron-secret")?.trim();
  if (explicitHeader) return explicitHeader;

  const authHeader = request.headers.get("authorization")?.trim() ?? "";
  if (authHeader.toLowerCase().startsWith("bearer ")) {
    return authHeader.slice(7).trim();
  }
  return "";
}

/**
 * Runs one daily reminder pass: selects 7/3/1-day due items, filters prior
 * `reminder_log` entries, atomically claims unsent log keys, sends localized
 * emails per user, and rolls back claims on delivery failure so retries work.
 */
export async function processReminders(
  deps: ProcessRemindersDeps,
): Promise<ReminderRunSummary> {
  const nowDate = (deps.now ?? (() => new Date()))();
  const nowIso = nowDate.toISOString();
  const providerName = deps.providerName ?? "resend";

  const [users, circulars] = await Promise.all([
    deps.store.loadUserProfiles(),
    deps.store.loadActiveCirculars(),
  ]);

  const timeZoneOffsetMinutes = deps.timeZoneOffsetMinutes ?? 0;
  const candidates = selectDueReminders({
    users,
    circulars,
    nowIso,
    timeZoneOffsetMinutes,
  });

  let sentEmails = 0;
  let loggedReminders = 0;
  let skippedDuplicates = 0;
  const errors: string[] = [];

  if (candidates.length > 0) {
    const targetDates = Array.from(
      new Set(candidates.map((c) => c.targetDate)),
    );
    const alreadySentKeys = await deps.store.loadSentDedupKeys(targetDates);
    const filtered = filterUnsentReminders(candidates, alreadySentKeys);
    skippedDuplicates = filtered.skippedDuplicates;

    const byUser = new Map<string, ReminderCandidate[]>();
    for (const item of filtered.unsent) {
      const group = byUser.get(item.userId);
      if (group) {
        group.push(item);
      } else {
        byUser.set(item.userId, [item]);
      }
    }

    for (const userItems of byUser.values()) {
      const claims: NewReminderLogClaim[] = userItems.map((item) => ({
        dedupKey: item.dedupKey,
        userId: item.userId,
        circularId: item.circularId,
        examDateId: item.examDateId,
        reminderKind: item.reminderKind,
        daysBefore: item.daysBefore,
        targetDate: item.targetDate,
        recipientEmail: item.recipientEmail,
        emailLanguage: item.emailLanguage,
        provider: providerName,
      }));

      const claimResult = await deps.store.claimReminderLogs(claims);
      skippedDuplicates += claimResult.duplicateKeys.length;

      if (claimResult.claimed.length === 0) {
        continue;
      }

      const claimedKeySet = new Set(claimResult.claimed.map((c) => c.dedupKey));
      const claimedItems = userItems.filter((item) =>
        claimedKeySet.has(item.dedupKey)
      );
      const claimIds = claimResult.claimed.map((c) => c.id);

      const first = claimedItems[0];
      const message = renderReminderEmail({
        recipientEmail: first.recipientEmail,
        language: first.emailLanguage,
        items: claimedItems,
      });

      try {
        const sendResult = await deps.emailSender.send(message);
        await deps.store.markReminderLogsDelivered(
          claimIds,
          sendResult.messageId,
        );
        sentEmails += 1;
        loggedReminders += claimIds.length;
      } catch (error) {
        const reason = error instanceof Error ? error.message : String(error);
        errors.push(`User ${first.userId} delivery failed: ${reason}`);
        await deps.store.releaseReminderLogClaims(claimIds);
      }
    }
  }

  let notifications: NotificationDispatchSummary | undefined;
  if (deps.notificationStore) {
    try {
      notifications = await dispatchDailyNotifications({
        notificationStore: deps.notificationStore,
        userIds: Array.from(new Set(users.map((u) => u.userId))),
        circulars,
        nowIso,
        timeZoneOffsetMinutes,
      });
    } catch (error) {
      const reason = error instanceof Error ? error.message : String(error);
      errors.push(`Notifications dispatch failed: ${reason}`);
    }
  }

  return {
    nowIso,
    evaluatedUsers: users.length,
    matchedCandidates: candidates.length,
    sentEmails,
    loggedReminders,
    skippedDuplicates,
    ...(notifications ? { notifications } : {}),
    errors,
  };
}

export interface CreateHandlerDeps extends ProcessRemindersDeps {
  cronSecret: string;
}

export function createReminderHandler(deps: CreateHandlerDeps) {
  return async (request: Request): Promise<Response> => {
    if (request.method !== "POST") {
      return Response.json({ error: "Method not allowed" }, { status: 405 });
    }

    if (!deps.cronSecret.trim()) {
      return Response.json(
        { error: "REMINDER_CRON_SECRET is not configured" },
        { status: 500 },
      );
    }

    const providedSecret = extractCronSecret(request);
    if (!constantTimeEquals(providedSecret, deps.cronSecret.trim())) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const summary = await processReminders(deps);
    const status = summary.errors.length > 0 ? 207 : 200;
    return Response.json(summary, { status });
  };
}
