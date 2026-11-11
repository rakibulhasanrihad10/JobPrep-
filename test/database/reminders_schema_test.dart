import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 5B - Reminders Migration, Edge Function & pgTAP Tests', () {
    test(
      'migration defines user_reminder_settings, reminder_log dedup index, '
      'RLS, and daily pg_cron schedule without embedded secrets',
      () {
        final migration = File(
          'supabase/migrations/20261111000000_reminders.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('CREATE TABLE public.user_reminder_settings'));
        expect(sql, contains('CREATE TABLE public.reminder_log'));

        expect(
          sql,
          contains(
            'ALTER TABLE public.user_reminder_settings '
            'ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(
          sql,
          contains(
            'ALTER TABLE public.reminder_log ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));

        expect(sql, contains("email_language IN ('en', 'bn')"));
        expect(sql, contains('days_before IN (7, 3, 1)'));
        expect(
          sql,
          contains("reminder_kind IN ('circular_deadline', 'exam_date')"),
        );

        // Deduplication index must coalesce nullable exam_date_id so deadline
        // reminders cannot fire twice.
        expect(sql, contains('CREATE UNIQUE INDEX idx_reminder_log_dedup'));
        expect(sql, contains('COALESCE(exam_date_id,'));

        // Daily pg_cron trigger referencing Vault secrets instead of literals
        expect(
          sql,
          contains(
            'CREATE OR REPLACE FUNCTION public.dispatch_daily_reminders()',
          ),
        );
        expect(sql, contains('vault.decrypted_secrets'));
        expect(sql, contains("'project_url'"));
        expect(sql, contains("'reminder_cron_secret'"));
        expect(sql, contains('/functions/v1/send-reminders'));
        expect(sql, contains("'jobprep-daily-reminders'"));
        expect(sql, contains("'0 2 * * *'"));
      },
    );

    test(
      'pgTAP suite verifies RLS isolation and duplicate-send 23505 protection',
      () {
        final pgTap = File(
          'supabase/tests/08_reminders_and_rls_test.sql',
        );
        expect(pgTap.existsSync(), isTrue);

        final sql = pgTap.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(27);'));
        expect(sql, contains("'idx_reminder_log_dedup'"));
        expect(sql, contains("'23505'"));
        expect(sql, contains('Duplicate circular_deadline reminder'));
        expect(sql, contains('Duplicate exam_date reminder'));
        expect(sql, contains('User B cannot read User A reminder settings'));
        expect(sql, contains('User B cannot read User A reminder_log entries'));
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );

    test(
      'Edge Function files and CI workflow verify pure selector & dedup tests',
      () {
        final requiredFiles = [
          'supabase/functions/send-reminders/deno.json',
          'supabase/functions/send-reminders/types.ts',
          'supabase/functions/send-reminders/selector.ts',
          'supabase/functions/send-reminders/email_templates.ts',
          'supabase/functions/send-reminders/handler.ts',
          'supabase/functions/send-reminders/resend_client.ts',
          'supabase/functions/send-reminders/supabase_store.ts',
          'supabase/functions/send-reminders/index.ts',
          'supabase/functions/send-reminders/selector_test.ts',
        ];
        for (final path in requiredFiles) {
          final file = File(path);
          expect(file.existsSync(), isTrue, reason: 'Missing $path');
          expect(
            file.readAsStringSync(),
            isNot(contains('\r\n')),
            reason: 'CRLF found in $path',
          );
        }

        final indexTs = File(
          'supabase/functions/send-reminders/index.ts',
        ).readAsStringSync();
        expect(indexTs, contains('Deno.env.get("RESEND_API_KEY")'));
        expect(indexTs, contains('Deno.env.get("REMINDER_CRON_SECRET")'));

        final configToml = File('supabase/config.toml').readAsStringSync();
        expect(configToml, contains('[functions.send-reminders]'));

        final ciYml = File('.github/workflows/ci.yml').readAsStringSync();
        expect(
          ciYml,
          contains('deno check supabase/functions/send-reminders/*.ts'),
        );
        expect(
          ciYml,
          contains(
            'deno test --allow-env '
            'supabase/functions/send-reminders/selector_test.ts',
          ),
        );
      },
    );
  });
}
