import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6F - progress_logs entry_type Migration & pgTAP Tests', () {
    test(
      'migration adds entry_type check constraint defaulting to study',
      () {
        final migration = File(
          'supabase/migrations/20261111040000_progress_logs_entry_type.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('ALTER TABLE public.progress_logs'));
        expect(
          sql,
          contains("ADD COLUMN entry_type text NOT NULL DEFAULT 'study'"),
        );
        expect(
          sql,
          contains("CHECK (entry_type IN ('study', 'correction'))"),
        );
        expect(
          sql,
          contains('progress_logs_user_entry_type_logged_on_idx'),
        );
      },
    );

    test(
      'pgTAP suite verifies entry_type defaults, corrections, clamping, & RLS',
      () {
        final testFile = File(
          'supabase/tests/12_progress_logs_entry_type_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(14);'));
        expect(sql, contains("'study'"));
        expect(sql, contains("'correction'"));
        expect(
          sql,
          contains(
            'Forward book position log (+45 from 200) '
            'sets completed_units to 245',
          ),
        );
        expect(
          sql,
          contains(
            'Correction entry (-65) updates material completed_units to 180',
          ),
        );
        expect(
          sql,
          contains('Studied units filter excludes correction rows'),
        );
        expect(
          sql,
          contains(
            'User B cannot read User A study or correction progress_logs',
          ),
        );
        expect(
          sql,
          contains(
            'User B cannot insert a correction entry '
            'referencing User A material',
          ),
        );
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );
  });
}
