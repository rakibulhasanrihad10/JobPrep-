import type { SupabaseClient } from "npm:@supabase/supabase-js@2.49.1";

import {
  buildReminderDedupKey,
  mergeUserReminderProfiles,
  type RawAuthUser,
  type RawUserReminderSettings,
} from "./selector.ts";
import type {
  CircularExamDateRecord,
  CircularReminderRecord,
  ClaimReminderLogsResult,
  ClaimedReminderLog,
  NewReminderLogClaim,
  ReminderKind,
  ReminderStore,
  UserReminderProfile,
} from "./types.ts";

interface CircularExamRow {
  id: string;
  circular_id: string;
  user_id: string;
  stage: string;
  exam_date: string;
  venue: string | null;
}

interface CircularRow {
  id: string;
  user_id: string;
  title: string;
  organization_name: string | null;
  deadline: string | null;
  workflow_status: string;
  circular_exam_dates: CircularExamRow[] | null;
}

interface ReminderLogKeyRow {
  user_id: string;
  reminder_kind: string;
  circular_id: string;
  exam_date_id: string | null;
  days_before: number;
  target_date: string;
}

export class SupabaseReminderStore implements ReminderStore {
  readonly #client: SupabaseClient;

  constructor(client: SupabaseClient) {
    this.#client = client;
  }

  async loadUserProfiles(): Promise<ReadonlyArray<UserReminderProfile>> {
    const authUsers: RawAuthUser[] = [];
    const perPage = 1000;
    let page = 1;

    while (true) {
      const { data, error } = await this.#client.auth.admin.listUsers({
        page,
        perPage,
      });
      if (error) {
        throw new Error(`Failed loading auth users: ${error.message}`);
      }
      const batch = data?.users ?? [];
      authUsers.push(...batch);
      if (batch.length < perPage) break;
      page += 1;
    }

    const { data: settingsRows, error: settingsError } = await this.#client
      .from("user_reminder_settings")
      .select("user_id, reminders_enabled, email_language");

    if (settingsError) {
      throw new Error(
        `Failed loading user_reminder_settings: ${settingsError.message}`,
      );
    }

    return mergeUserReminderProfiles(
      authUsers,
      (settingsRows ?? []) as RawUserReminderSettings[],
    );
  }

  async loadActiveCirculars(): Promise<ReadonlyArray<CircularReminderRecord>> {
    const { data, error } = await this.#client
      .from("circulars")
      .select(
        "id, user_id, title, organization_name, deadline, workflow_status, circular_exam_dates(id, circular_id, user_id, stage, exam_date, venue)",
      )
      .neq("workflow_status", "archived");

    if (error) {
      throw new Error(`Failed loading circulars: ${error.message}`);
    }

    return ((data ?? []) as CircularRow[]).map((row) => ({
      id: row.id,
      userId: row.user_id,
      title: row.title,
      organizationName: row.organization_name,
      deadline: row.deadline,
      workflowStatus: row.workflow_status,
      examDates: (row.circular_exam_dates ?? []).map(
        (exam): CircularExamDateRecord => ({
          id: exam.id,
          circularId: exam.circular_id,
          userId: exam.user_id,
          stage: exam.stage,
          examDate: exam.exam_date,
          venue: exam.venue,
        }),
      ),
    }));
  }

  async loadSentDedupKeys(
    targetDates: ReadonlyArray<string>,
  ): Promise<ReadonlySet<string>> {
    if (targetDates.length === 0) return new Set();

    const { data, error } = await this.#client
      .from("reminder_log")
      .select(
        "user_id, reminder_kind, circular_id, exam_date_id, days_before, target_date",
      )
      .in("target_date", [...targetDates]);

    if (error) {
      throw new Error(`Failed loading reminder_log keys: ${error.message}`);
    }

    const keys = new Set<string>();
    for (const row of (data ?? []) as ReminderLogKeyRow[]) {
      keys.add(
        buildReminderDedupKey({
          userId: row.user_id,
          reminderKind: row.reminder_kind as ReminderKind,
          circularId: row.circular_id,
          examDateId: row.exam_date_id,
          daysBefore: row.days_before,
          targetDate: row.target_date,
        }),
      );
    }
    return keys;
  }

  async claimReminderLogs(
    claims: ReadonlyArray<NewReminderLogClaim>,
  ): Promise<ClaimReminderLogsResult> {
    const claimed: ClaimedReminderLog[] = [];
    const duplicateKeys: string[] = [];

    for (const claim of claims) {
      const { data, error } = await this.#client
        .from("reminder_log")
        .insert({
          user_id: claim.userId,
          circular_id: claim.circularId,
          exam_date_id: claim.examDateId,
          reminder_kind: claim.reminderKind,
          days_before: claim.daysBefore,
          target_date: claim.targetDate,
          recipient_email: claim.recipientEmail,
          email_language: claim.emailLanguage,
          provider: claim.provider,
        })
        .select("id")
        .single();

      if (error) {
        if (error.code === "23505") {
          duplicateKeys.push(claim.dedupKey);
          continue;
        }
        throw new Error(
          `Failed claiming reminder_log row: ${error.message}`,
        );
      }

      claimed.push({
        id: String((data as { id: string }).id),
        dedupKey: claim.dedupKey,
      });
    }

    return { claimed, duplicateKeys };
  }

  async markReminderLogsDelivered(
    claimIds: ReadonlyArray<string>,
    providerMessageId: string | null,
  ): Promise<void> {
    if (claimIds.length === 0) return;

    const { error } = await this.#client
      .from("reminder_log")
      .update({
        provider_message_id: providerMessageId,
        sent_at: new Date().toISOString(),
      })
      .in("id", [...claimIds]);

    if (error) {
      throw new Error(
        `Failed updating reminder_log delivery state: ${error.message}`,
      );
    }
  }

  async releaseReminderLogClaims(
    claimIds: ReadonlyArray<string>,
  ): Promise<void> {
    if (claimIds.length === 0) return;

    const { error } = await this.#client
      .from("reminder_log")
      .delete()
      .in("id", [...claimIds]);

    if (error) {
      throw new Error(
        `Failed releasing failed reminder_log claims: ${error.message}`,
      );
    }
  }
}
