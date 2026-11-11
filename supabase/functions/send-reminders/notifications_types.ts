export type NotificationType =
  | "deadline_soon"
  | "exam_soon"
  | "revision_due"
  | "behind_schedule"
  | "weekly_review";

export interface UserNotificationPreferences {
  userId: string;
  deadlineSoonEnabled: boolean;
  examSoonEnabled: boolean;
  revisionDueEnabled: boolean;
  behindScheduleEnabled: boolean;
  weeklyReviewEnabled: boolean;
  /** 0 = Sunday .. 6 = Saturday */
  weeklyReviewDay: number;
}

export interface RevisionDueRecord {
  id: string;
  userId: string;
  dueOn: string;
  status: string;
}

export interface StudyPlanRecord {
  id: string;
  userId: string;
  subjectId: string | null;
  subjectName: string | null;
  startDate: string;
  targetDate: string;
  finishBufferDays: number;
  restDaysPerWeek: number;
  extraStudyDays: number;
  initialCompletedUnits: number;
  postponedMaterialIds: ReadonlyArray<string>;
}

export interface MaterialProgressRecord {
  id: string;
  userId: string;
  subjectId: string;
  totalUnits: number;
  completedUnits: number;
}

export type NotificationParamValue = string | number | boolean;

export interface NotificationCandidate {
  userId: string;
  type: NotificationType;
  messageKey: string;
  params: Readonly<Record<string, NotificationParamValue>>;
  route: string;
  dedupeKey: string;
}

export interface NotificationDispatchSummary {
  candidates: number;
  inserted: number;
  skippedDuplicates: number;
}

export interface NotificationStore {
  loadNotificationPreferences(): Promise<
    ReadonlyArray<UserNotificationPreferences>
  >;
  loadRevisionItemsDueBy(
    todayDate: string,
  ): Promise<ReadonlyArray<RevisionDueRecord>>;
  loadStudyPlansContext(): Promise<{
    plans: ReadonlyArray<StudyPlanRecord>;
    materials: ReadonlyArray<MaterialProgressRecord>;
  }>;
  upsertNotifications(
    candidates: ReadonlyArray<NotificationCandidate>,
  ): Promise<{ inserted: number; skippedDuplicates: number }>;
}

export const DEFAULT_USER_NOTIFICATION_PREFERENCES: Omit<
  UserNotificationPreferences,
  "userId"
> = {
  deadlineSoonEnabled: true,
  examSoonEnabled: true,
  revisionDueEnabled: true,
  behindScheduleEnabled: true,
  weeklyReviewEnabled: true,
  weeklyReviewDay: 0,
};
