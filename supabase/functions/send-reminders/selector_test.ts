import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

import { renderReminderEmail } from "./email_templates.ts";
import { createReminderHandler, processReminders } from "./handler.ts";
import {
  buildReminderDedupKey,
  diffCalendarDays,
  filterUnsentReminders,
  mergeUserReminderProfiles,
  selectDueReminders,
} from "./selector.ts";
import type {
  CircularReminderRecord,
  ClaimedReminderLog,
  ClaimReminderLogsResult,
  EmailMessage,
  EmailSender,
  EmailSendResult,
  NewReminderLogClaim,
  ReminderStore,
  UserReminderProfile,
} from "./types.ts";

class InMemoryReminderStore implements ReminderStore {
  users: UserReminderProfile[];
  circulars: CircularReminderRecord[];
  sentLogs = new Map<string, { id: string; providerMessageId: string | null }>();
  forcedDuplicateKeys = new Set<string>();
  #seq = 0;

  constructor(
    users: UserReminderProfile[],
    circulars: CircularReminderRecord[],
  ) {
    this.users = users;
    this.circulars = circulars;
  }

  loadUserProfiles(): Promise<ReadonlyArray<UserReminderProfile>> {
    return Promise.resolve(this.users);
  }

  loadActiveCirculars(): Promise<ReadonlyArray<CircularReminderRecord>> {
    return Promise.resolve(this.circulars);
  }

  loadSentDedupKeys(
    targetDates: ReadonlyArray<string>,
  ): Promise<ReadonlySet<string>> {
    const wantedDates = new Set(targetDates);
    const matching = new Set<string>();
    for (const key of this.sentLogs.keys()) {
      const keyDate = key.split("|")[5];
      if (wantedDates.has(keyDate)) {
        matching.add(key);
      }
    }
    return Promise.resolve(matching);
  }

  claimReminderLogs(
    claims: ReadonlyArray<NewReminderLogClaim>,
  ): Promise<ClaimReminderLogsResult> {
    const claimed: ClaimedReminderLog[] = [];
    const duplicateKeys: string[] = [];

    for (const claim of claims) {
      if (
        this.sentLogs.has(claim.dedupKey) ||
        this.forcedDuplicateKeys.has(claim.dedupKey)
      ) {
        duplicateKeys.push(claim.dedupKey);
        continue;
      }
      const id = `claim-${++this.#seq}`;
      this.sentLogs.set(claim.dedupKey, { id, providerMessageId: null });
      claimed.push({ id, dedupKey: claim.dedupKey });
    }

    return Promise.resolve({ claimed, duplicateKeys });
  }

  markReminderLogsDelivered(
    claimIds: ReadonlyArray<string>,
    providerMessageId: string | null,
  ): Promise<void> {
    const idSet = new Set(claimIds);
    for (const entry of this.sentLogs.values()) {
      if (idSet.has(entry.id)) {
        entry.providerMessageId = providerMessageId;
      }
    }
    return Promise.resolve();
  }

  releaseReminderLogClaims(claimIds: ReadonlyArray<string>): Promise<void> {
    const idSet = new Set(claimIds);
    for (const [key, entry] of this.sentLogs.entries()) {
      if (idSet.has(entry.id)) {
        this.sentLogs.delete(key);
      }
    }
    return Promise.resolve();
  }
}

class RecordingEmailSender implements EmailSender {
  sent: EmailMessage[] = [];
  shouldThrow = false;

  send(message: EmailMessage): Promise<EmailSendResult> {
    if (this.shouldThrow) {
      return Promise.reject(new Error("Simulated provider outage"));
    }
    this.sent.push(message);
    return Promise.resolve({ messageId: `msg-${this.sent.length}` });
  }
}

Deno.test("diffCalendarDays aligns timestamps in target timezone offset", () => {
  // 2026-11-10T02:00:00Z = 08:00 AM +06:00 on 2026-11-10
  // 2026-11-17T17:59:00Z = 23:59 PM +06:00 on 2026-11-17 (exact +7 days)
  const diff = diffCalendarDays(
    "2026-11-17T17:59:00Z",
    "2026-11-10T02:00:00Z",
    360,
  );
  assertEquals(diff, { daysUntil: 7, targetDate: "2026-11-17" });
});

Deno.test("selectDueReminders matches only 7, 3, and 1 day windows and respects opt-out and archive", () => {
  const nowIso = "2026-11-10T02:00:00Z";
  const users: UserReminderProfile[] = [
    {
      userId: "u-en",
      email: "en@example.test",
      remindersEnabled: true,
      emailLanguage: "en",
    },
    {
      userId: "u-bn",
      email: "bn@example.test",
      remindersEnabled: true,
      emailLanguage: "bn",
    },
    {
      userId: "u-off",
      email: "off@example.test",
      remindersEnabled: false,
      emailLanguage: "en",
    },
  ];

  const circulars: CircularReminderRecord[] = [
    {
      id: "c-1",
      userId: "u-en",
      title: "48th BCS Special",
      organizationName: "BPSC",
      deadline: "2026-11-17T17:00:00+06:00", // 7 days
      workflowStatus: "preparing",
      examDates: [
        {
          id: "e-1d",
          circularId: "c-1",
          userId: "u-en",
          stage: "preliminary",
          examDate: "2026-11-11T10:00:00+06:00", // 1 day
          venue: "Dhaka College",
        },
        {
          id: "e-4d",
          circularId: "c-1",
          userId: "u-en",
          stage: "written",
          examDate: "2026-11-14T10:00:00+06:00", // 4 days -> excluded
          venue: null,
        },
      ],
    },
    {
      id: "c-2",
      userId: "u-bn",
      title: "Combined Bank Officer",
      organizationName: null,
      deadline: "2026-11-13T17:00:00+06:00", // 3 days
      workflowStatus: "saved",
      examDates: [],
    },
    {
      id: "c-archived",
      userId: "u-en",
      title: "Old Archived Circular",
      organizationName: null,
      deadline: "2026-11-11T17:00:00+06:00", // 1 day but archived
      workflowStatus: "archived",
      examDates: [],
    },
    {
      id: "c-optout",
      userId: "u-off",
      title: "Muted User Circular",
      organizationName: null,
      deadline: "2026-11-11T17:00:00+06:00", // user disabled reminders
      workflowStatus: "saved",
      examDates: [],
    },
  ];

  const selected = selectDueReminders({
    users,
    circulars,
    nowIso,
    timeZoneOffsetMinutes: 360,
  });

  assertEquals(selected.length, 3);
  assertEquals(selected[0].dedupKey, buildReminderDedupKey({
    userId: "u-bn",
    reminderKind: "circular_deadline",
    circularId: "c-2",
    examDateId: null,
    daysBefore: 3,
    targetDate: "2026-11-13",
  }));
  assertEquals(selected[1].reminderKind, "exam_date");
  assertEquals(selected[1].daysBefore, 1);
  assertEquals(selected[2].reminderKind, "circular_deadline");
  assertEquals(selected[2].daysBefore, 7);
});

Deno.test("filterUnsentReminders blocks duplicates from log and same-batch repeats", () => {
  const candidateA = selectDueReminders({
    users: [{
      userId: "u-1",
      email: "u1@example.test",
      remindersEnabled: true,
      emailLanguage: "en",
    }],
    circulars: [{
      id: "c-1",
      userId: "u-1",
      title: "BCS",
      organizationName: null,
      deadline: "2026-11-17T17:00:00+06:00",
      workflowStatus: "saved",
      examDates: [],
    }],
    nowIso: "2026-11-10T02:00:00Z",
    timeZoneOffsetMinutes: 360,
  })[0];

  const filtered = filterUnsentReminders(
    [candidateA, candidateA],
    new Set([candidateA.dedupKey]),
  );
  assertEquals(filtered.unsent.length, 0);
  assertEquals(filtered.skippedDuplicates, 2);
});

Deno.test("processReminders never sends duplicate emails across repeated or racing runs", async () => {
  const users: UserReminderProfile[] = [
    {
      userId: "u-en",
      email: "en@example.test",
      remindersEnabled: true,
      emailLanguage: "en",
    },
    {
      userId: "u-bn",
      email: "bn@example.test",
      remindersEnabled: true,
      emailLanguage: "bn",
    },
  ];
  const circulars: CircularReminderRecord[] = [
    {
      id: "c-1",
      userId: "u-en",
      title: "Assistant Programmer",
      organizationName: "BPSC",
      deadline: "2026-11-17T17:00:00+06:00",
      workflowStatus: "saved",
      examDates: [],
    },
    {
      id: "c-2",
      userId: "u-bn",
      title: "সহকারী প্রকৌশলী",
      organizationName: "পিজিসিবি",
      deadline: "2026-11-11T17:00:00+06:00",
      workflowStatus: "saved",
      examDates: [],
    },
  ];

  const store = new InMemoryReminderStore(users, circulars);
  const sender = new RecordingEmailSender();

  // First run delivers 2 bilingual emails and claims 2 reminder_log rows.
  const firstRun = await processReminders({
    store,
    emailSender: sender,
    now: () => new Date("2026-11-10T02:00:00Z"),
    timeZoneOffsetMinutes: 360,
  });

  assertEquals(firstRun.matchedCandidates, 2);
  assertEquals(firstRun.sentEmails, 2);
  assertEquals(firstRun.loggedReminders, 2);
  assertEquals(firstRun.skippedDuplicates, 0);
  assertEquals(sender.sent.length, 2);
  assertEquals(sender.sent[0].subject.includes("JobPrep অনুস্মারক"), true);
  assertEquals(sender.sent[1].subject.includes("JobPrep Reminder"), true);

  // Second run on the same day skips all reminders via reminder_log.
  const secondRun = await processReminders({
    store,
    emailSender: sender,
    now: () => new Date("2026-11-10T08:00:00Z"),
    timeZoneOffsetMinutes: 360,
  });

  assertEquals(secondRun.matchedCandidates, 2);
  assertEquals(secondRun.sentEmails, 0);
  assertEquals(secondRun.skippedDuplicates, 2);
  assertEquals(sender.sent.length, 2);
});

Deno.test("processReminders releases claimed logs if provider delivery throws so retries succeed", async () => {
  const store = new InMemoryReminderStore(
    [{
      userId: "u-1",
      email: "retry@example.test",
      remindersEnabled: true,
      emailLanguage: "en",
    }],
    [{
      id: "c-1",
      userId: "u-1",
      title: "Bank PO",
      organizationName: null,
      deadline: "2026-11-13T17:00:00+06:00",
      workflowStatus: "saved",
      examDates: [],
    }],
  );
  const sender = new RecordingEmailSender();
  sender.shouldThrow = true;

  const failedRun = await processReminders({
    store,
    emailSender: sender,
    now: () => new Date("2026-11-10T02:00:00Z"),
    timeZoneOffsetMinutes: 360,
  });
  assertEquals(failedRun.errors.length, 1);
  assertEquals(failedRun.sentEmails, 0);
  assertEquals(store.sentLogs.size, 0);

  sender.shouldThrow = false;
  const retryRun = await processReminders({
    store,
    emailSender: sender,
    now: () => new Date("2026-11-10T03:00:00Z"),
    timeZoneOffsetMinutes: 360,
  });
  assertEquals(retryRun.sentEmails, 1);
  assertEquals(store.sentLogs.size, 1);
});

Deno.test("renderReminderEmail escapes HTML and formats Bangla numerals cleanly", () => {
  const msg = renderReminderEmail({
    recipientEmail: "u@example.test",
    language: "bn",
    items: [{
      dedupKey: "k1",
      userId: "u1",
      recipientEmail: "u@example.test",
      emailLanguage: "bn",
      circularId: "c1",
      circularTitle: "Role <Test> & Title",
      organizationName: "Org",
      examDateId: null,
      examStage: null,
      venue: null,
      reminderKind: "circular_deadline",
      daysBefore: 3,
      targetDate: "2026-11-13",
      eventTimestampIso: "2026-11-13T17:00:00+06:00",
    }],
  });

  assertEquals(msg.subject.includes("১টি"), true);
  assertEquals(msg.html.includes("&lt;Test&gt; &amp; Title"), true);
  assertEquals(msg.html.includes("৩ দিন বাকি"), true);
  assertEquals(msg.html.includes("২০২৬-১১-১৩"), true);
});

Deno.test("createReminderHandler validates HTTP method and cron secret", async () => {
  const store = new InMemoryReminderStore([], []);
  const sender = new RecordingEmailSender();
  const handler = createReminderHandler({
    cronSecret: "local-cron-token-for-test",
    store,
    emailSender: sender,
    now: () => new Date("2026-11-10T02:00:00Z"),
  });

  const getRes = await handler(
    new Request("http://localhost/send-reminders", { method: "GET" }),
  );
  assertEquals(getRes.status, 405);

  const unauthRes = await handler(
    new Request("http://localhost/send-reminders", {
      method: "POST",
      headers: { "x-cron-secret": "wrong" },
    }),
  );
  assertEquals(unauthRes.status, 401);

  const okRes = await handler(
    new Request("http://localhost/send-reminders", {
      method: "POST",
      headers: { "x-cron-secret": "local-cron-token-for-test" },
    }),
  );
  assertEquals(okRes.status, 200);
});

Deno.test("processReminders skips sending when concurrent claim collides on unique index", async () => {
  const circulars: CircularReminderRecord[] = [{
    id: "c-race",
    userId: "u-race",
    title: "Judicial Service",
    organizationName: null,
    deadline: "2026-11-11T17:00:00+06:00",
    workflowStatus: "saved",
    examDates: [],
  }];
  const users: UserReminderProfile[] = [{
    userId: "u-race",
    email: "race@example.test",
    remindersEnabled: true,
    emailLanguage: "en",
  }];
  const store = new InMemoryReminderStore(users, circulars);
  store.forcedDuplicateKeys.add(
    buildReminderDedupKey({
      userId: "u-race",
      reminderKind: "circular_deadline",
      circularId: "c-race",
      examDateId: null,
      daysBefore: 1,
      targetDate: "2026-11-11",
    }),
  );
  const sender = new RecordingEmailSender();

  const summary = await processReminders({
    store,
    emailSender: sender,
    now: () => new Date("2026-11-10T02:00:00Z"),
    timeZoneOffsetMinutes: 360,
  });

  assertEquals(summary.sentEmails, 0);
  assertEquals(summary.skippedDuplicates, 1);
  assertEquals(sender.sent.length, 0);
});

Deno.test("mergeUserReminderProfiles defaults unconfigured users to enabled English", () => {
  const merged = mergeUserReminderProfiles(
    [
      { id: "u-default", email: "a@example.test" },
      { id: "u-bn", email: "b@example.test" },
      { id: "u-no-email", email: "" },
    ],
    [
      {
        user_id: "u-bn",
        reminders_enabled: false,
        email_language: "bn",
      },
    ],
  );

  assertEquals(merged, [
    {
      userId: "u-default",
      email: "a@example.test",
      remindersEnabled: true,
      emailLanguage: "en",
    },
    {
      userId: "u-bn",
      email: "b@example.test",
      remindersEnabled: false,
      emailLanguage: "bn",
    },
  ]);
});
