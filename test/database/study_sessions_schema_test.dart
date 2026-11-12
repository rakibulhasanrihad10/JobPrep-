import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6H - study_sessions Migration & pgTAP Tests', () {
    test(
      'migration defines study_sessions columns, check constraints, indexes, '
      'and RLS',
      () {
        final migration = File(
          'supabase/migrations/20261111060000_study_sessions.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('CREATE TABLE public.study_sessions'));

        for (final column in [
          'user_id',
          'subject_id',
          'material_id',
          'started_at',
          'ended_at',
          'duration_seconds',
          'mode',
          'note',
          'pause_intervals',
        ]) {
          expect(sql, contains('  $column '));
        }

        expect(sql, contains('duration_seconds >= 0'));
        expect(sql, contains("mode IN ('focus', 'stopwatch', 'manual')"));
        expect(sql, contains('ended_at IS NULL OR ended_at >= started_at'));
        expect(
          sql,
          contains(
            'ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
      },
    );

    test(
      'pgTAP suite verifies defaults, check constraints, FKs, and RLS '
      'isolation',
      () {
        final testFile = File(
          'supabase/tests/14_study_sessions_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(20);'));
        expect(sql, contains('Negative duration_seconds is rejected'));
        expect(sql, contains('User B cannot read User A study sessions'));
        expect(sql, contains('User B cannot update User A session'));
        expect(sql, contains('User B cannot delete User A session'));
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );
  });
}
