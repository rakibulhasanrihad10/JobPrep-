export type EmailLanguage = "en" | "bn";

export type ReminderKind = "circular_deadline" | "exam_date";

export type ReminderLeadDays = 7 | 3 | 1;

export interface UserReminderProfile {
  userId: string;
  email: string;
  remindersEnabled: boolean;
  emailLanguage: EmailLanguage;
}

export interface CircularExamDateRecord {
  id: string;
  circularId: string;
  userId: string;
  stage: string;
  examDate: string;
  venue: string | null;
}

export interface CircularReminderRecord {
  id: string;
  userId: string;
  title: string;
  organizationName: string | null;
  deadline: string | null;
  workflowStatus: string;
  examDates: ReadonlyArray<CircularExamDateRecord>;
}

export interface ReminderCandidate {
  dedupKey: string;
  userId: string;
  recipientEmail: string;
  emailLanguage: EmailLanguage;
  circularId: string;
  circularTitle: string;
  organizationName: string | null;
  examDateId: string | null;
  examStage: string | null;
  venue: string | null;
  reminderKind: ReminderKind;
  daysBefore: ReminderLeadDays;
  targetDate: string;
  eventTimestampIso: string;
}

export interface NewReminderLogClaim {
  dedupKey: string;
  userId: string;
  circularId: string;
  examDateId: string | null;
  reminderKind: ReminderKind;
  daysBefore: ReminderLeadDays;
  targetDate: string;
  recipientEmail: string;
  emailLanguage: EmailLanguage;
  provider: string;
}

export interface ClaimedReminderLog {
  id: string;
  dedupKey: string;
}

export interface ClaimReminderLogsResult {
  claimed: ReadonlyArray<ClaimedReminderLog>;
  duplicateKeys: ReadonlyArray<string>;
}

export interface EmailMessage {
  to: string;
  subject: string;
  html: string;
  text: string;
}

export interface EmailSendResult {
  messageId: string | null;
}

export interface EmailSender {
  send(message: EmailMessage): Promise<EmailSendResult>;
}

export interface ReminderStore {
  loadUserProfiles(): Promise<ReadonlyArray<UserReminderProfile>>;
  loadActiveCirculars(): Promise<ReadonlyArray<CircularReminderRecord>>;
  loadSentDedupKeys(
    targetDates: ReadonlyArray<string>,
  ): Promise<ReadonlySet<string>>;
  claimReminderLogs(
    claims: ReadonlyArray<NewReminderLogClaim>,
  ): Promise<ClaimReminderLogsResult>;
  markReminderLogsDelivered(
    claimIds: ReadonlyArray<string>,
    providerMessageId: string | null,
  ): Promise<void>;
  releaseReminderLogClaims(claimIds: ReadonlyArray<string>): Promise<void>;
}

import type { NotificationDispatchSummary } from "./notifications_types.ts";

export interface ReminderRunSummary {
  nowIso: string;
  evaluatedUsers: number;
  matchedCandidates: number;
  sentEmails: number;
  loggedReminders: number;
  skippedDuplicates: number;
  notifications?: NotificationDispatchSummary;
  errors: ReadonlyArray<string>;
}
