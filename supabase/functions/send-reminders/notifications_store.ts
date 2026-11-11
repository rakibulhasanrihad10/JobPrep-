import type { CircularReminderRecord } from "./types.ts";
import type {
  MaterialProgressRecord,
  NotificationCandidate,
  NotificationStore,
  RevisionDueRecord,
  StudyPlanRecord,
  UserNotificationPreferences,
} from "./notifications_types.ts";

// deno-lint-ignore no-explicit-any
type AnySupabaseClient = any;

interface SettingsRow {
  user_id: string;
  deadline_soon_enabled?: boolean | null;
  exam_soon_enabled?: boolean | null;
  revision_due_enabled?: boolean | null;
  behind_schedule_enabled?: boolean | null;
  weekly_review_enabled?: boolean | null;
  weekly_review_day?: number | null;
}

interface RevisionRow {
  id: string;
  user_id: string;
  due_on: string;
  status: string;
}

interface StudyPlanRow {
  id: string;
  user_id: string;
  subject_id: string | null;
  start_date: string;
  target_date: string;
  finish_buffer_days: number | null;
  rest_days_per_week: number | null;
  extra_study_days: number | null;
  initial_completed_units: number | null;
  postponed_material_ids: string[] | null;
  subjects?: { name?: string | null } | Array<{ name?: string | null }> | null;
}

interface MaterialRow {
  id: string;
  user_id: string;
  subject_id: string;
  total_units: number | null;
  completed_units: number | null;
}

function extractSubjectName(
  subjects: StudyPlanRow["subjects"],
): string | null {
  if (!subjects) return null;
  if (Array.isArray(subjects)) {
    return subjects[0]?.name ?? null;
  }
  return subjects.name ?? null;
}

/**
 * PostgREST implementation of [NotificationStore] using Supabase service-role
 * access for daily cron notification creation and deduplication.
 */
export class SupabaseNotificationStore implements NotificationStore {
  constructor(private readonly client: AnySupabaseClient) {}

  async loadNotificationPreferences(): Promise<
    ReadonlyArray<UserNotificationPreferences>
  > {
    const { data, error } = await this.client
      .from("user_reminder_settings")
      .select(
        "user_id, deadline_soon_enabled, exam_soon_enabled, revision_due_enabled, behind_schedule_enabled, weekly_review_enabled, weekly_review_day",
      );
    if (error) {
      throw new Error(
        `Failed to load notification preferences: ${error.message}`,
      );
    }
    return ((data ?? []) as SettingsRow[]).map((row) => ({
      userId: row.user_id,
      deadlineSoonEnabled: row.deadline_soon_enabled ?? true,
      examSoonEnabled: row.exam_soon_enabled ?? true,
      revisionDueEnabled: row.revision_due_enabled ?? true,
      behindScheduleEnabled: row.behind_schedule_enabled ?? true,
      weeklyReviewEnabled: row.weekly_review_enabled ?? true,
      weeklyReviewDay:
        typeof row.weekly_review_day === "number" &&
          row.weekly_review_day >= 0 &&
          row.weekly_review_day <= 6
          ? row.weekly_review_day
          : 0,
    }));
  }

  async loadRevisionItemsDueBy(
    todayDate: string,
  ): Promise<ReadonlyArray<RevisionDueRecord>> {
    const { data, error } = await this.client
      .from("revision_items")
      .select("id, user_id, due_on, status")
      .in("status", ["pending", "revised"])
      .lte("due_on", todayDate);
    if (error) {
      throw new Error(`Failed to load due revision items: ${error.message}`);
    }
    return ((data ?? []) as RevisionRow[]).map((row) => ({
      id: row.id,
      userId: row.user_id,
      dueOn: row.due_on,
      status: row.status,
    }));
  }

  async loadStudyPlansContext(): Promise<{
    plans: ReadonlyArray<StudyPlanRecord>;
    materials: ReadonlyArray<MaterialProgressRecord>;
  }> {
    const [plansResult, materialsResult] = await Promise.all([
      this.client
        .from("study_plans")
        .select(
          "id, user_id, subject_id, start_date, target_date, finish_buffer_days, rest_days_per_week, extra_study_days, initial_completed_units, postponed_material_ids, subjects(name)",
        ),
      this.client
        .from("materials")
        .select("id, user_id, subject_id, total_units, completed_units"),
    ]);

    if (plansResult.error) {
      throw new Error(
        `Failed to load study plans: ${plansResult.error.message}`,
      );
    }
    if (materialsResult.error) {
      throw new Error(
        `Failed to load materials: ${materialsResult.error.message}`,
      );
    }

    const plans: StudyPlanRecord[] = ((plansResult.data ?? []) as StudyPlanRow[])
      .map((row) => ({
        id: row.id,
        userId: row.user_id,
        subjectId: row.subject_id,
        subjectName: extractSubjectName(row.subjects),
        startDate: row.start_date,
        targetDate: row.target_date,
        finishBufferDays: row.finish_buffer_days ?? 7,
        restDaysPerWeek: row.rest_days_per_week ?? 0,
        extraStudyDays: row.extra_study_days ?? 0,
        initialCompletedUnits: row.initial_completed_units ?? 0,
        postponedMaterialIds: row.postponed_material_ids ?? [],
      }));

    const materials: MaterialProgressRecord[] =
      ((materialsResult.data ?? []) as MaterialRow[]).map((row) => ({
        id: row.id,
        userId: row.user_id,
        subjectId: row.subject_id,
        totalUnits: row.total_units ?? 0,
        completedUnits: row.completed_units ?? 0,
      }));

    return { plans, materials };
  }

  async upsertNotifications(
    candidates: ReadonlyArray<NotificationCandidate>,
  ): Promise<{ inserted: number; skippedDuplicates: number }> {
    if (candidates.length === 0) {
      return { inserted: 0, skippedDuplicates: 0 };
    }
    const payload = candidates.map((c) => ({
      user_id: c.userId,
      type: c.type,
      message_key: c.messageKey,
      params: c.params,
      route: c.route,
      dedupe_key: c.dedupeKey,
    }));

    const { data, error } = await this.client
      .from("notifications")
      .upsert(payload, {
        onConflict: "user_id,dedupe_key",
        ignoreDuplicates: true,
      })
      .select("id");

    if (error) {
      throw new Error(`Failed to upsert notifications: ${error.message}`);
    }
    const inserted = Array.isArray(data) ? data.length : 0;
    return {
      inserted,
      skippedDuplicates: Math.max(0, candidates.length - inserted),
    };
  }
}

export function extractCircularUserIds(
  circulars: ReadonlyArray<CircularReminderRecord>,
): string[] {
  const seen = new Set<string>();
  for (const circular of circulars) {
    seen.add(circular.userId);
  }
  return Array.from(seen);
}
