import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 7A - user_settings Preferences Migration & pgTAP Tests', () {
    test(
      'migration adds preference columns, check constraints, and '
      'delete_my_account RPC',
      () {
        final migration = File(
          'supabase/migrations/20261112000000_user_settings_preferences.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('ALTER TABLE public.user_settings'));
        expect(sql, contains('ADD COLUMN display_name text'));
        expect(
          sql,
          contains("ADD COLUMN theme_mode text NOT NULL DEFAULT 'system'"),
        );
        expect(
          sql,
          contains('ADD COLUMN reduce_effects boolean NOT NULL DEFAULT false'),
        );
        expect(
          sql,
          contains("ADD COLUMN locale_code text NOT NULL DEFAULT 'en'"),
        );
        expect(
          sql,
          contains('ADD COLUMN bangla_digits boolean NOT NULL DEFAULT false'),
        );
        expect(
          sql,
          contains('ADD COLUMN focus_minutes integer NOT NULL DEFAULT 25'),
        );
        expect(
          sql,
          contains(
            'ADD COLUMN short_break_minutes integer NOT NULL DEFAULT 5',
          ),
        );
        expect(
          sql,
          contains(
            'ADD COLUMN long_break_minutes integer NOT NULL DEFAULT 15',
          ),
        );
        expect(sql, contains("theme_mode IN ('system', 'light', 'dark')"));
        expect(sql, contains("locale_code IN ('en', 'bn')"));
        expect(
          sql,
          contains('CREATE OR REPLACE FUNCTION public.delete_my_account()'),
        );
        expect(sql, contains('SECURITY DEFINER'));
        expect(
          sql,
          contains(
            'GRANT EXECUTE ON FUNCTION public.delete_my_account() TO '
            'authenticated',
          ),
        );
      },
    );

    test('pgTAP tests RLS isolation, check constraints, and account delete',
        () {
      final pgTap = File(
        'supabase/tests/17_user_settings_preferences_rls_test.sql',
      );
      expect(pgTap.existsSync(), isTrue);

      final sql = pgTap.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('SELECT plan(14);'));
      expect(sql, contains('public.delete_my_account()'));
      expect(sql, contains('User B cannot read User A preference settings'));
      expect(sql, contains('User B settings remain intact'));
    });
  });
}
