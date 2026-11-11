import type {
  CircularReminderRecord,
  EmailLanguage,
  ReminderCandidate,
  ReminderKind,
  ReminderLeadDays,
  UserReminderProfile,
} from "./types.ts";

export const REMINDER_LEAD_DAYS: ReadonlyArray<ReminderLeadDays> = [7, 3, 1];

const MS_PER_MINUTE = 60_000;
const MS_PER_DAY = 86_400_000;

export interface CalendarDateParts {
  year: number;
  month: number;
  day: number;
  isoDate: string;
}

export function normalizeEmailLanguage(
  raw: string | null | undefined,
): EmailLanguage {
  return raw === "bn" ? "bn" : "en";
}

export interface RawAuthUser {
  id: string;
  email?: string | null;
}

export interface RawUserReminderSettings {
  user_id: string;
  reminders_enabled: boolean;
  email_language: string;
}

/**
 * Combines Auth users with optional `user_reminder_settings` rows, defaulting
 * unconfigured users to enabled English reminders.
 */
export function mergeUserReminderProfiles(
  authUsers: ReadonlyArray<RawAuthUser>,
  settingsRows: ReadonlyArray<RawUserReminderSettings>,
): UserReminderProfile[] {
  const settingsByUser = new Map<string, RawUserReminderSettings>();
  for (const row of settingsRows) {
    settingsByUser.set(row.user_id, row);
  }

  const profiles: UserReminderProfile[] = [];
  for (const authUser of authUsers) {
    const email = authUser.email?.trim() ?? "";
    if (!email) continue;

    const pref = settingsByUser.get(authUser.id);
    profiles.push({
      userId: authUser.id,
      email,
      remindersEnabled: pref?.reminders_enabled ?? true,
      emailLanguage: normalizeEmailLanguage(pref?.email_language),
    });
  }
  return profiles;
}

export function extractCalendarDate(
  isoTimestamp: string,
  timeZoneOffsetMinutes = 0,
): CalendarDateParts | null {
  const trimmed = isoTimestamp.trim();
  if (!trimmed) return null;

  const parsedMs = Date.parse(trimmed);
  if (!Number.isFinite(parsedMs)) return null;

  const shifted = new Date(parsedMs + timeZoneOffsetMinutes * MS_PER_MINUTE);
  const year = shifted.getUTCFullYear();
  const month = shifted.getUTCMonth() + 1;
  const day = shifted.getUTCDate();

  const yyyy = String(year).padStart(4, "0");
  const mm = String(month).padStart(2, "0");
  const dd = String(day).padStart(2, "0");

  return {
    year,
    month,
    day,
    isoDate: `${yyyy}-${mm}-${dd}`,
  };
}

export function diffCalendarDays(
  targetIso: string,
  nowIso: string,
  timeZoneOffsetMinutes = 0,
): { daysUntil: number; targetDate: string } | null {
  const targetParts = extractCalendarDate(targetIso, timeZoneOffsetMinutes);
  const nowParts = extractCalendarDate(nowIso, timeZoneOffsetMinutes);
  if (!targetParts || !nowParts) return null;

  const targetUtcDay = Date.UTC(
    targetParts.year,
    targetParts.month - 1,
    targetParts.day,
  );
  const nowUtcDay = Date.UTC(
    nowParts.year,
    nowParts.month - 1,
    nowParts.day,
  );

  return {
    daysUntil: Math.round((targetUtcDay - nowUtcDay) / MS_PER_DAY),
    targetDate: targetParts.isoDate,
  };
}

export function matchLeadDays(
  daysUntil: number,
  leadDaysList: ReadonlyArray<ReminderLeadDays> = REMINDER_LEAD_DAYS,
): ReminderLeadDays | null {
  for (const lead of leadDaysList) {
    if (daysUntil === lead) return lead;
  }
  return null;
}

export function buildReminderDedupKey(parts: {
  userId: string;
  reminderKind: ReminderKind;
  circularId: string;
  examDateId: string | null;
  daysBefore: number;
  targetDate: string;
}): string {
  const examKey = parts.examDateId ?? "none";
  return `${parts.userId}|${parts.reminderKind}|${parts.circularId}|${examKey}|${parts.daysBefore}|${parts.targetDate}`;
}

export interface SelectDueRemindersInput {
  users: ReadonlyArray<UserReminderProfile>;
  circulars: ReadonlyArray<CircularReminderRecord>;
  nowIso: string;
  timeZoneOffsetMinutes?: number;
  leadDaysList?: ReadonlyArray<ReminderLeadDays>;
}

/**
 * Pure date-selection function identifying every active circular deadline and
 * exam sitting falling exactly 7, 3, or 1 calendar days from `nowIso` for each
 * opted-in user.
 */
export function selectDueReminders(
  input: SelectDueRemindersInput,
): ReminderCandidate[] {
  const timeZoneOffsetMinutes = input.timeZoneOffsetMinutes ?? 0;
  const leadDaysList = input.leadDaysList ?? REMINDER_LEAD_DAYS;

  const profileByUserId = new Map<string, UserReminderProfile>();
  for (const profile of input.users) {
    const email = profile.email.trim();
    if (!email || !profile.remindersEnabled) continue;
    profileByUserId.set(profile.userId, {
      ...profile,
      email,
      emailLanguage: normalizeEmailLanguage(profile.emailLanguage),
    });
  }

  const candidates: ReminderCandidate[] = [];

  for (const circular of input.circulars) {
    if (circular.workflowStatus === "archived") continue;

    const user = profileByUserId.get(circular.userId);
    if (!user) continue;

    if (circular.deadline) {
      const deadlineDiff = diffCalendarDays(
        circular.deadline,
        input.nowIso,
        timeZoneOffsetMinutes,
      );
      if (deadlineDiff) {
        const matchedLead = matchLeadDays(deadlineDiff.daysUntil, leadDaysList);
        if (matchedLead !== null) {
          candidates.push({
            dedupKey: buildReminderDedupKey({
              userId: user.userId,
              reminderKind: "circular_deadline",
              circularId: circular.id,
              examDateId: null,
              daysBefore: matchedLead,
              targetDate: deadlineDiff.targetDate,
            }),
            userId: user.userId,
            recipientEmail: user.email,
            emailLanguage: user.emailLanguage,
            circularId: circular.id,
            circularTitle: circular.title,
            organizationName: circular.organizationName,
            examDateId: null,
            examStage: null,
            venue: null,
            reminderKind: "circular_deadline",
            daysBefore: matchedLead,
            targetDate: deadlineDiff.targetDate,
            eventTimestampIso: circular.deadline,
          });
        }
      }
    }

    for (const exam of circular.examDates) {
      const examDiff = diffCalendarDays(
        exam.examDate,
        input.nowIso,
        timeZoneOffsetMinutes,
      );
      if (!examDiff) continue;

      const matchedLead = matchLeadDays(examDiff.daysUntil, leadDaysList);
      if (matchedLead === null) continue;

      candidates.push({
        dedupKey: buildReminderDedupKey({
          userId: user.userId,
          reminderKind: "exam_date",
          circularId: circular.id,
          examDateId: exam.id,
          daysBefore: matchedLead,
          targetDate: examDiff.targetDate,
        }),
        userId: user.userId,
        recipientEmail: user.email,
        emailLanguage: user.emailLanguage,
        circularId: circular.id,
        circularTitle: circular.title,
        organizationName: circular.organizationName,
        examDateId: exam.id,
        examStage: exam.stage,
        venue: exam.venue,
        reminderKind: "exam_date",
        daysBefore: matchedLead,
        targetDate: examDiff.targetDate,
        eventTimestampIso: exam.examDate,
      });
    }
  }

  candidates.sort((a, b) => {
    if (a.userId !== b.userId) return a.userId.localeCompare(b.userId);
    if (a.daysBefore !== b.daysBefore) return a.daysBefore - b.daysBefore;
    if (a.targetDate !== b.targetDate) {
      return a.targetDate.localeCompare(b.targetDate);
    }
    if (a.reminderKind !== b.reminderKind) {
      return a.reminderKind.localeCompare(b.reminderKind);
    }
    return a.dedupKey.localeCompare(b.dedupKey);
  });

  return candidates;
}

export interface FilterUnsentResult {
  unsent: ReminderCandidate[];
  skippedDuplicates: number;
}

/**
 * Pure duplicate-protection filter preventing re-sending any candidate already
 * logged in `reminder_log` or duplicated inside the same evaluation batch.
 */
export function filterUnsentReminders(
  candidates: ReadonlyArray<ReminderCandidate>,
  alreadySentKeys: ReadonlySet<string>,
): FilterUnsentResult {
  const seen = new Set<string>(alreadySentKeys);
  const unsent: ReminderCandidate[] = [];
  let skippedDuplicates = 0;

  for (const candidate of candidates) {
    if (seen.has(candidate.dedupKey)) {
      skippedDuplicates += 1;
      continue;
    }
    seen.add(candidate.dedupKey);
    unsent.push(candidate);
  }

  return { unsent, skippedDuplicates };
}
