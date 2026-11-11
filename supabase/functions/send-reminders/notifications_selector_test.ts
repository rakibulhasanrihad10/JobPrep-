import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { processReminders } from "./handler.ts";
import {
  dispatchDailyNotifications,
  filterDuplicateNotificationCandidates,
  isStudyPlanBehindSchedule,
  selectDueNotifications,
} from "./notifications_selector.ts";
import type {
  MaterialProgressRecord,
  NotificationCandidate,
  NotificationStore,
  RevisionDueRecord,
  StudyPlanRecord,
  UserNotificationPreferences,
} from "./notifications_types.ts";
import type {
  CircularReminderRecord,
  EmailMessage,
  EmailSendResult,
  EmailSender,
  NewReminderLogClaim,
  ReminderStore,
  UserReminderProfile,
} from "./types.ts";

class InMemoryNotificationStore implements NotificationStore {
  rows: Map<string, NotificationCandidate> = new Map();

  constructor(
    private readonly preferences: ReadonlyArray<UserNotificationPreferences>,
    private readonly revisionItems: ReadonlyArray<RevisionDueRecord>,
    private readonly plans: ReadonlyArray<StudyPlanRecord>,
    private readonly materials: ReadonlyArray<MaterialProgressRecord>,
  ) {}

  loadNotificationPreferences(): Promise<
    ReadonlyArray<UserNotificationPreferences>
  > {
    return Promise.resolve(this.preferences);
  }

  loadRevisionItemsDueBy(
    todayDate: string,
  ): Promise<ReadonlyArray<RevisionDueRecord>> {
    return Promise.resolve(
      this.revisionItems.filter((item) => item.dueOn <= todayDate),
    );
  }

  loadStudyPlansContext(): Promise<{
    plans: ReadonlyArray<StudyPlanRecord>;
    materials: ReadonlyArray<MaterialProgressRecord>;
  }> {
    return Promise.resolve({ plans: this.plans, materials: this.materials });
  }

  upsertNotifications(
    candidates: ReadonlyArray<NotificationCandidate>,
  ): Promise<{ inserted: number; skippedDuplicates: number }> {
    let inserted = 0;
    let skippedDuplicates = 0;
    for (const candidate of candidates) {
      const key = `${candidate.userId}|${candidate.dedupeKey}`;
      if (this.rows.has(key)) {
        skippedDuplicates += 1;
        continue;
      }
      this.rows.set(key, candidate);
      inserted += 1;
    }
    return Promise.resolve({ inserted, skippedDuplicates });
  }
}

Deno.test("selectDueNotifications creates all 5 notification types respecting toggles and review day", () => {
  // 2026-11-15T02:00:00Z = Sunday 2026-11-15 08:00 AM +06:00 (weekday 0)
  const nowIso = "2026-11-15T02:00:00Z";

  const preferences: UserNotificationPreferences[] = [
    {
      userId: "u-1",
      deadlineSoonEnabled: true,
      examSoonEnabled: true,
      revisionDueEnabled: true,
      behindScheduleEnabled: true,
      weeklyReviewEnabled: true,
      weeklyReviewDay: 0, // Sunday
    },
    {
      userId: "u-2",
      deadlineSoonEnabled: false,
      examSoonEnabled: false,
      revisionDueEnabled: false,
      behindScheduleEnabled: false,
      weeklyReviewEnabled: true,
      weeklyReviewDay: 5, // Friday -> should not trigger on Sunday
    },
  ];

  const circulars: CircularReminderRecord[] = [
    {
      id: "c-1",
      userId: "u-1",
      title: "47th BCS",
      organizationName: "BPSC",
      deadline: "2026-11-18T17:00:00+06:00", // 3 days
      workflowStatus: "preparing",
      examDates: [
        {
          id: "e-1",
          circularId: "c-1",
          userId: "u-1",
          stage: "preliminary",
          examDate: "2026-11-16T10:00:00+06:00", // 1 day
          venue: null,
        },
        {
          id: "e-ignored",
          circularId: "c-1",
          userId: "u-1",
          stage: "written",
          examDate: "2026-11-20T10:00:00+06:00", // 5 days -> ignored
          venue: null,
        },
      ],
    },
    {
      id: "c-muted",
      userId: "u-2",
      title: "Bank Job",
      organizationName: null,
      deadline: "2026-11-16T17:00:00+06:00", // muted via deadlineSoonEnabled=false
      workflowStatus: "saved",
      examDates: [],
    },
  ];

  const revisionItems: RevisionDueRecord[] = [
    { id: "r-1", userId: "u-1", dueOn: "2026-11-15", status: "pending" },
    { id: "r-2", userId: "u-1", dueOn: "2026-11-14", status: "revised" },
    { id: "r-future", userId: "u-1", dueOn: "2026-11-18", status: "pending" },
    { id: "r-done", userId: "u-1", dueOn: "2026-11-15", status: "mastered" },
    { id: "r-u2", userId: "u-2", dueOn: "2026-11-15", status: "pending" },
  ];

  const studyPlans: StudyPlanRecord[] = [
    {
      id: "sp-behind",
      userId: "u-1",
      subjectId: "subj-1",
      subjectName: "Bangladesh Affairs",
      startDate: "2026-11-01",
      targetDate: "2026-11-30",
      finishBufferDays: 5,
      restDaysPerWeek: 0,
      extraStudyDays: 0,
      initialCompletedUnits: 0,
      postponedMaterialIds: [],
    },
    {
      id: "sp-u2-off",
      userId: "u-2",
      subjectId: null,
      subjectName: null,
      startDate: "2026-11-01",
      targetDate: "2026-11-20",
      finishBufferDays: 7,
      restDaysPerWeek: 0,
      extraStudyDays: 0,
      initialCompletedUnits: 0,
      postponedMaterialIds: [],
    },
  ];

  const materials: MaterialProgressRecord[] = [
    {
      id: "m-1",
      userId: "u-1",
      subjectId: "subj-1",
      totalUnits: 240,
      completedUnits: 20, // behind pace by Nov 15
    },
    {
      id: "m-2",
      userId: "u-2",
      subjectId: "subj-2",
      totalUnits: 100,
      completedUnits: 10,
    },
  ];

  const selected = selectDueNotifications({
    userIds: ["u-1", "u-2"],
    preferences,
    circulars,
    revisionItems,
    studyPlans,
    materials,
    nowIso,
    timeZoneOffsetMinutes: 360,
  });

  assertEquals(selected.length, 5);
  assertEquals(
    selected.map((c) => c.type),
    [
      "behind_schedule",
      "deadline_soon",
      "exam_soon",
      "revision_due",
      "weekly_review",
    ],
  );
  assertEquals(selected[0].params, { subject: "Bangladesh Affairs" });
  assertEquals(selected[0].route, "/prep/subj-1");
  assertEquals(selected[1].params, {
    title: "47th BCS",
    days: 3,
    targetDate: "2026-11-18",
  });
  assertEquals(selected[2].params, {
    title: "47th BCS",
    stage: "preliminary",
    days: 1,
    targetDate: "2026-11-16",
  });
  assertEquals(selected[3].params, { count: 2 });
  assertEquals(selected[4].route, "/weekly-review");
});

Deno.test("isStudyPlanBehindSchedule returns false when completed or ahead of pace", () => {
  const materials: MaterialProgressRecord[] = [
    {
      id: "m-1",
      userId: "u-1",
      subjectId: "s-1",
      totalUnits: 100,
      completedUnits: 80,
    },
  ];
  const plan: StudyPlanRecord = {
    id: "p-1",
    userId: "u-1",
    subjectId: "s-1",
    subjectName: "English",
    startDate: "2026-11-01",
    targetDate: "2026-11-27",
    finishBufferDays: 6, // finish 2026-11-21 (20 study days)
    restDaysPerWeek: 0,
    extraStudyDays: 0,
    initialCompletedUnits: 0,
    postponedMaterialIds: [],
  };

  // On Nov 11: 10 elapsed days -> ideal 50 units, completed 80 -> not behind
  assertEquals(isStudyPlanBehindSchedule(plan, materials, "2026-11-11"), false);
});

Deno.test("dispatchDailyNotifications deduplicates across repeat runs", async () => {
  const store = new InMemoryNotificationStore(
    [],
    [{ id: "r-1", userId: "u-1", dueOn: "2026-11-15", status: "pending" }],
    [],
    [],
  );

  const first = await dispatchDailyNotifications({
    notificationStore: store,
    userIds: ["u-1"],
    circulars: [],
    nowIso: "2026-11-15T02:00:00Z",
    timeZoneOffsetMinutes: 360,
  });
  assertEquals(first, { candidates: 2, inserted: 2, skippedDuplicates: 0 });

  const second = await dispatchDailyNotifications({
    notificationStore: store,
    userIds: ["u-1"],
    circulars: [],
    nowIso: "2026-11-15T06:00:00Z",
    timeZoneOffsetMinutes: 360,
  });
  assertEquals(second, { candidates: 2, inserted: 0, skippedDuplicates: 2 });

  const filtered = filterDuplicateNotificationCandidates(
    Array.from(store.rows.values()),
    new Set(store.rows.keys()),
  );
  assertEquals(filtered.unique.length, 0);
  assertEquals(filtered.skippedDuplicates, 2);
});

Deno.test("processReminders dispatches weekly review notifications even on days with no due emails", async () => {
  const users: UserReminderProfile[] = [
    {
      userId: "u-sun",
      email: "sun@example.test",
      remindersEnabled: false,
      emailLanguage: "en",
    },
  ];
  const emptyReminderStore: ReminderStore = {
    loadUserProfiles: () => Promise.resolve(users),
    loadActiveCirculars: () => Promise.resolve([]),
    loadSentDedupKeys: () => Promise.resolve(new Set<string>()),
    claimReminderLogs: (_claims: ReadonlyArray<NewReminderLogClaim>) =>
      Promise.resolve({ claimed: [], duplicateKeys: [] }),
    markReminderLogsDelivered: () => Promise.resolve(),
    releaseReminderLogClaims: () => Promise.resolve(),
  };
  const noopSender: EmailSender = {
    send: (_message: EmailMessage): Promise<EmailSendResult> =>
      Promise.resolve({ messageId: "unused" }),
  };
  const notifStore = new InMemoryNotificationStore([], [], [], []);

  const summary = await processReminders({
    store: emptyReminderStore,
    notificationStore: notifStore,
    emailSender: noopSender,
    now: () => new Date("2026-11-15T02:00:00Z"), // Sunday +06:00
    timeZoneOffsetMinutes: 360,
  });

  assertEquals(summary.matchedCandidates, 0);
  assertEquals(summary.notifications, {
    candidates: 1,
    inserted: 1,
    skippedDuplicates: 0,
  });
  assertEquals(notifStore.rows.size, 1);
});
