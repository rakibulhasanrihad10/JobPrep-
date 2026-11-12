import { diffCalendarDays, extractCalendarDate, matchLeadDays } from "./selector.ts";
import type { CircularReminderRecord } from "./types.ts";
import {
  DEFAULT_USER_NOTIFICATION_PREFERENCES,
  type MaterialProgressRecord,
  type NotificationCandidate,
  type NotificationDispatchSummary,
  type NotificationStore,
  type RevisionDueRecord,
  type StudyPlanRecord,
  type UserNotificationPreferences,
} from "./notifications_types.ts";

const COMPARISON_EPSILON = 1e-6;
const MILLIS_PER_DAY = 86_400_000;

export function getLocalCalendarDateAndWeekday(
  nowIso: string,
  timeZoneOffsetMinutes = 0,
): { todayDate: string; weekday: number } {
  const date = new Date(nowIso);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid nowIso timestamp: ${nowIso}`);
  }
  const shifted = new Date(date.getTime() + timeZoneOffsetMinutes * 60_000);
  return {
    todayDate: shifted.toISOString().slice(0, 10),
    weekday: shifted.getUTCDay(),
  };
}

function extractIsoCalendarDate(isoTimestamp: string): string | null {
  return extractCalendarDate(isoTimestamp)?.isoDate ?? null;
}

export function addCalendarDays(isoDate: string, deltaDays: number): string {
  const parts = extractCalendarDate(isoDate);
  if (!parts) {
    throw new Error(`Invalid calendar date: ${isoDate}`);
  }
  const utcMidnight = Date.UTC(parts.year, parts.month - 1, parts.day);
  return new Date(utcMidnight + deltaDays * MILLIS_PER_DAY)
    .toISOString()
    .slice(0, 10);
}

function diffIsoDates(fromDate: string, toDate: string): number {
  const fromParts = extractCalendarDate(fromDate);
  const toParts = extractCalendarDate(toDate);
  if (!fromParts || !toParts) return 0;
  const fromUtc = Date.UTC(fromParts.year, fromParts.month - 1, fromParts.day);
  const toUtc = Date.UTC(toParts.year, toParts.month - 1, toParts.day);
  return Math.round((toUtc - fromUtc) / MILLIS_PER_DAY);
}

function countRestDays(calendarDays: number, restDaysPerWeek: number): number {
  if (calendarDays <= 0 || restDaysPerWeek <= 0) return 0;
  const clampedRest = Math.min(6, Math.max(0, restDaysPerWeek));
  return Math.min(calendarDays, Math.floor((calendarDays * clampedRest) / 7));
}

export function isStudyPlanBehindSchedule(
  plan: StudyPlanRecord,
  materials: ReadonlyArray<MaterialProgressRecord>,
  todayDate: string,
): boolean {
  const postponedSet = new Set(plan.postponedMaterialIds);
  let completedUnits = 0;
  let remainingUnits = 0;

  for (const material of materials) {
    if (material.userId !== plan.userId) continue;
    if (plan.subjectId !== null && material.subjectId !== plan.subjectId) {
      continue;
    }
    if (postponedSet.has(material.id)) continue;

    const total = Math.max(0, material.totalUnits);
    const completed = Math.max(0, material.completedUnits);
    completedUnits += Math.min(total, completed);
    if (total > completed) {
      remainingUnits += total - completed;
    }
  }

  if (remainingUnits <= 0) return false;

  const today = extractIsoCalendarDate(todayDate);
  const startDay = extractIsoCalendarDate(plan.startDate);
  const targetDay = extractIsoCalendarDate(plan.targetDate);
  if (!today || !startDay || !targetDay) return false;

  const effectiveFinishDay = addCalendarDays(
    targetDay,
    -Math.max(0, plan.finishBufferDays),
  );

  const calendarDaysLeft = Math.max(0, diffIsoDates(today, effectiveFinishDay));
  const scheduledRest = countRestDays(calendarDaysLeft, plan.restDaysPerWeek);
  const restDaysLeft = Math.max(0, scheduledRest - Math.max(0, plan.extraStudyDays));
  const studyDaysLeft = Math.max(0, calendarDaysLeft - restDaysLeft);

  if (studyDaysLeft <= 0) return true;

  const totalCalendarDays = Math.max(
    0,
    diffIsoDates(startDay, effectiveFinishDay),
  );
  const totalRestDays = countRestDays(totalCalendarDays, plan.restDaysPerWeek);
  const totalStudyDays = Math.max(0, totalCalendarDays - totalRestDays);

  const baselineRemainingStudy = Math.max(0, calendarDaysLeft - scheduledRest);
  const elapsedStudyDays = today <= startDay
    ? 0
    : Math.max(0, totalStudyDays - baselineRemainingStudy);

  const baselineDone = Math.min(
    Math.max(0, plan.initialCompletedUnits),
    completedUnits,
  );
  const completedSinceStart = Math.max(0, completedUnits - baselineDone);
  const totalSpanUnits = completedSinceStart + remainingUnits;

  const baselineDailyPace = totalStudyDays > 0
    ? totalSpanUnits / totalStudyDays
    : totalSpanUnits > 0
    ? totalSpanUnits
    : 0;
  const idealBeforeToday = Math.min(
    totalSpanUnits,
    elapsedStudyDays * baselineDailyPace,
  );

  return completedSinceStart < idealBeforeToday - COMPARISON_EPSILON;
}

export function selectDueNotifications(params: {
  userIds: ReadonlyArray<string>;
  preferences: ReadonlyArray<UserNotificationPreferences>;
  circulars: ReadonlyArray<CircularReminderRecord>;
  revisionItems: ReadonlyArray<RevisionDueRecord>;
  studyPlans: ReadonlyArray<StudyPlanRecord>;
  materials: ReadonlyArray<MaterialProgressRecord>;
  nowIso: string;
  timeZoneOffsetMinutes?: number;
}): NotificationCandidate[] {
  const offset = params.timeZoneOffsetMinutes ?? 0;
  const { todayDate, weekday } = getLocalCalendarDateAndWeekday(
    params.nowIso,
    offset,
  );

  const prefMap = new Map<string, UserNotificationPreferences>();
  for (const pref of params.preferences) {
    prefMap.set(pref.userId, pref);
  }
  const prefsFor = (userId: string): UserNotificationPreferences =>
    prefMap.get(userId) ?? {
      userId,
      ...DEFAULT_USER_NOTIFICATION_PREFERENCES,
    };

  const candidates: NotificationCandidate[] = [];

  for (const circular of params.circulars) {
    if (circular.workflowStatus === "archived") continue;
    const prefs = prefsFor(circular.userId);

    if (prefs.deadlineSoonEnabled && circular.deadline) {
      const deadlineDiff = diffCalendarDays(
        circular.deadline,
        params.nowIso,
        offset,
      );
      if (deadlineDiff) {
        const { daysUntil, targetDate } = deadlineDiff;
        const leadDays = matchLeadDays(daysUntil);
        if (leadDays !== null) {
          candidates.push({
            userId: circular.userId,
            type: "deadline_soon",
            messageKey: "notificationMsgDeadlineSoon",
            params: {
              title: circular.title,
              days: leadDays,
              targetDate,
            },
            route: `/circulars/${circular.id}`,
            dedupeKey: `deadline_soon|${circular.id}|${leadDays}d|${targetDate}`,
          });
        }
      }
    }

    if (prefs.examSoonEnabled) {
      for (const exam of circular.examDates) {
        const examDiff = diffCalendarDays(
          exam.examDate,
          params.nowIso,
          offset,
        );
        if (!examDiff) continue;
        const { daysUntil, targetDate } = examDiff;
        const leadDays = matchLeadDays(daysUntil);
        if (leadDays === null) continue;
        candidates.push({
          userId: circular.userId,
          type: "exam_soon",
          messageKey: "notificationMsgExamSoon",
          params: {
            title: circular.title,
            stage: exam.stage,
            days: leadDays,
            targetDate,
          },
          route: `/circulars/${circular.id}`,
          dedupeKey:
            `exam_soon|${circular.id}|${exam.id}|${leadDays}d|${targetDate}`,
        });
      }
    }
  }

  const dueCountsByUser = new Map<string, number>();
  for (const item of params.revisionItems) {
    if (item.status !== "pending" && item.status !== "revised") continue;
    const dueOn = extractIsoCalendarDate(item.dueOn);
    if (dueOn !== null && dueOn <= todayDate) {
      dueCountsByUser.set(item.userId, (dueCountsByUser.get(item.userId) ?? 0) + 1);
    }
  }
  for (const [userId, count] of dueCountsByUser.entries()) {
    const prefs = prefsFor(userId);
    if (!prefs.revisionDueEnabled || count <= 0) continue;
    candidates.push({
      userId,
      type: "revision_due",
      messageKey: "notificationMsgRevisionDue",
      params: { count },
      route: "/prep/revision",
      dedupeKey: `revision_due|${todayDate}`,
    });
  }

  for (const plan of params.studyPlans) {
    const prefs = prefsFor(plan.userId);
    if (!prefs.behindScheduleEnabled) continue;
    if (!isStudyPlanBehindSchedule(plan, params.materials, todayDate)) continue;
    const hasSubject = plan.subjectId !== null && plan.subjectName !== null;
    candidates.push({
      userId: plan.userId,
      type: "behind_schedule",
      messageKey: hasSubject
        ? "notificationMsgBehindScheduleSubject"
        : "notificationMsgBehindScheduleAll",
      params: hasSubject ? { subject: plan.subjectName! } : {},
      route: plan.subjectId ? `/prep/${plan.subjectId}` : "/today",
      dedupeKey: `behind_schedule|${plan.id}|${todayDate}`,
    });
  }

  const weekStart = addCalendarDays(todayDate, -6);
  for (const userId of params.userIds) {
    const prefs = prefsFor(userId);
    if (!prefs.weeklyReviewEnabled) continue;
    if (prefs.weeklyReviewDay !== weekday) continue;
    candidates.push({
      userId,
      type: "weekly_review",
      messageKey: "notificationMsgWeeklyReview",
      params: { weekStart, weekEnd: todayDate },
      route: "/weekly-review",
      dedupeKey: `weekly_review|${todayDate}`,
    });
  }

  candidates.sort((a, b) =>
    `${a.userId}|${a.type}|${a.dedupeKey}`.localeCompare(
      `${b.userId}|${b.type}|${b.dedupeKey}`,
    )
  );
  return candidates;
}

export function filterDuplicateNotificationCandidates(
  candidates: ReadonlyArray<NotificationCandidate>,
  existingKeys: ReadonlySet<string>,
): { unique: NotificationCandidate[]; skippedDuplicates: number } {
  const seen = new Set<string>(existingKeys);
  const unique: NotificationCandidate[] = [];
  let skippedDuplicates = 0;

  for (const candidate of candidates) {
    const compositeKey = `${candidate.userId}|${candidate.dedupeKey}`;
    if (seen.has(compositeKey)) {
      skippedDuplicates += 1;
      continue;
    }
    seen.add(compositeKey);
    unique.push(candidate);
  }

  return { unique, skippedDuplicates };
}

export async function dispatchDailyNotifications(params: {
  notificationStore: NotificationStore;
  userIds: ReadonlyArray<string>;
  circulars: ReadonlyArray<CircularReminderRecord>;
  nowIso: string;
  timeZoneOffsetMinutes: number;
}): Promise<NotificationDispatchSummary> {
  const { todayDate } = getLocalCalendarDateAndWeekday(
    params.nowIso,
    params.timeZoneOffsetMinutes,
  );
  const [preferences, revisionItems, studyPlansContext] = await Promise.all([
    params.notificationStore.loadNotificationPreferences(),
    params.notificationStore.loadRevisionItemsDueBy(todayDate),
    params.notificationStore.loadStudyPlansContext(),
  ]);

  const candidates = selectDueNotifications({
    userIds: params.userIds,
    preferences,
    circulars: params.circulars,
    revisionItems,
    studyPlans: studyPlansContext.plans,
    materials: studyPlansContext.materials,
    nowIso: params.nowIso,
    timeZoneOffsetMinutes: params.timeZoneOffsetMinutes,
  });

  if (candidates.length === 0) {
    return { candidates: 0, inserted: 0, skippedDuplicates: 0 };
  }

  const upsertResult = await params.notificationStore.upsertNotifications(
    candidates,
  );
  return {
    candidates: candidates.length,
    inserted: upsertResult.inserted,
    skippedDuplicates: upsertResult.skippedDuplicates,
  };
}
