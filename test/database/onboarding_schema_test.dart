import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6K - user_settings Onboarding Migration & pgTAP Tests', () {
    test(
      'migration defines user_settings with onboarding columns, RLS, and '
      'no PII columns',
      () {
        final migration = File(
          'supabase/migrations/20261111080000_user_settings_onboarding.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('CREATE TABLE public.user_settings'));
        expect(sql, contains('onboarding_completed_at timestamptz'));
        expect(
          sql,
          contains('onboarding_step integer NOT NULL DEFAULT 1'),
        );
        expect(sql, contains('onboarding_step BETWEEN 1 AND 6'));
        expect(
          sql,
          contains('today_tips_dismissed boolean NOT NULL DEFAULT false'),
        );
        expect(
          sql,
          contains(
            'ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));

        // Never ask for or store personal demographic/contact data.
        expect(sql.toLowerCase(), isNot(contains('phone')));
        expect(sql.toLowerCase(), isNot(contains('address')));
        expect(sql.toLowerCase(), isNot(contains('age')));
      },
    );

    test('pgTAP verifies RLS isolation and onboarding_step constraints', () {
      final pgTap = File(
        'supabase/tests/16_user_settings_onboarding_rls_test.sql',
      );
      expect(pgTap.existsSync(), isTrue);

      final sql = pgTap.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('BEGIN;'));
      expect(sql, contains('SELECT plan(13);'));
      expect(sql, contains("'23514'"));
      expect(sql, contains("'42501'"));
      expect(sql, contains('User B cannot read User A settings'));
      expect(sql, contains('User B cannot update User A settings'));
      expect(sql, contains('User B cannot delete User A settings'));
      expect(sql, contains('SELECT * FROM finish();'));
      expect(sql, contains('ROLLBACK;'));
    });
  });
}
