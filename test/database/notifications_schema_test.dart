import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6J - Notifications Migration, pgTAP & Edge Dispatch Tests', () {
    test(
      'migration creates notifications table, user_dedupe unique index, RLS, '
      'Realtime publication, and user_reminder_settings extensions',
      () {
        final migration = File(
          'supabase/migrations/20261111070000_notifications.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('CREATE TABLE public.notifications'));
        expect(sql, contains("'deadline_soon'"));
        expect(sql, contains("'exam_soon'"));
        expect(sql, contains("'revision_due'"));
        expect(sql, contains("'behind_schedule'"));
        expect(sql, contains("'weekly_review'"));
        expect(sql, contains('message_key text NOT NULL'));
        expect(sql, contains("params jsonb NOT NULL DEFAULT '{}'::jsonb"));
        expect(sql, contains('route text NOT NULL'));
        expect(sql, contains('dedupe_key text NOT NULL'));
        expect(sql, contains('read_at timestamptz'));

        expect(
          sql,
          contains(
            'CREATE UNIQUE INDEX idx_notifications_user_dedupe\n'
            '  ON public.notifications (user_id, dedupe_key)',
          ),
        );
        expect(
          sql,
          contains(
            'ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
        expect(
          sql,
          contains(
            'ALTER PUBLICATION supabase_realtime ADD TABLE '
            'public.notifications',
          ),
        );

        expect(sql, contains('ALTER TABLE public.user_reminder_settings'));
        expect(
          sql,
          contains('deadline_soon_enabled boolean NOT NULL DEFAULT true'),
        );
        expect(
          sql,
          contains('exam_soon_enabled boolean NOT NULL DEFAULT true'),
        );
        expect(
          sql,
          contains('revision_due_enabled boolean NOT NULL DEFAULT true'),
        );
        expect(
          sql,
          contains('behind_schedule_enabled boolean NOT NULL DEFAULT true'),
        );
        expect(
          sql,
          contains('weekly_review_enabled boolean NOT NULL DEFAULT true'),
        );
        expect(
          sql,
          contains('weekly_review_day integer NOT NULL DEFAULT 0'),
        );
        expect(sql, contains('weekly_review_day BETWEEN 0 AND 6'));
      },
    );

    test(
      'pgTAP verifies RLS isolation, 23505 dedupe index, and check rules',
      () {
        final pgTap = File(
          'supabase/tests/15_notifications_and_rls_test.sql',
        );
        expect(pgTap.existsSync(), isTrue);

        final sql = pgTap.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(19);'));
        expect(sql, contains("'idx_notifications_user_dedupe'"));
        expect(sql, contains("'23505'"));
        expect(sql, contains("'42501'"));
        expect(sql, contains("'23514'"));
        expect(sql, contains('User B cannot read User A notifications'));
        expect(
          sql,
          contains('User B cannot insert notification spoofed as User A'),
        );
        expect(sql, contains('User B cannot update User A notification'));
        expect(sql, contains('User B cannot delete User A notification'));
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );

    test(
      'Edge Function notification selector & CI checks exist with LF endings',
      () {
        final files = [
          'supabase/functions/send-reminders/notifications_selector.ts',
          'supabase/functions/send-reminders/notifications_selector_test.ts',
        ];
        for (final path in files) {
          final file = File(path);
          expect(file.existsSync(), isTrue, reason: 'Missing $path');
          expect(
            file.readAsStringSync(),
            isNot(contains('\r\n')),
            reason: 'CRLF found in $path',
          );
        }

        final ciYml = File('.github/workflows/ci.yml').readAsStringSync();
        expect(
          ciYml,
          contains(
            'deno test --allow-env '
            'supabase/functions/send-reminders/notifications_selector_test.ts',
          ),
        );
      },
    );
  });
}
