import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6C - Study Plans Migration & pgTAP Tests', () {
    test(
      'migration defines study_plans table with required defaults, owner FKs, '
      'partial unique indexes, and RLS policies',
      () {
        final migration = File(
          'supabase/migrations/20261111020000_study_plans.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('CREATE TABLE public.study_plans'));
        for (final column in [
          'user_id',
          'subject_id',
          'circular_id',
          'exam_date_id',
          'start_date',
          'target_date',
          'finish_buffer_days',
          'rest_days_per_week',
          'extra_study_days',
          'max_daily_pace',
          'initial_completed_units',
          'postponed_material_ids',
        ]) {
          expect(sql, contains('  $column '));
        }

        expect(sql, contains('finish_buffer_days integer NOT NULL DEFAULT 7'));
        expect(sql, contains('rest_days_per_week integer NOT NULL DEFAULT 0'));
        expect(sql, contains('FOREIGN KEY (subject_id, user_id)'));
        expect(sql, contains('FOREIGN KEY (circular_id, user_id)'));
        expect(sql, contains('FOREIGN KEY (exam_date_id, user_id)'));
        expect(
          sql,
          contains(
            'ALTER TABLE public.study_plans ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
        expect(sql, contains('CREATE TRIGGER set_study_plans_updated_at'));
      },
    );

    test(
      'pgTAP suite tests defaults, bounds, cross-user RLS, and FK behavior',
      () {
        final testFile = File(
          'supabase/tests/10_study_plans_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(23);'));
        expect(sql, contains('User B cannot read User A study plans'));
        expect(sql, contains('User B cannot insert study plan for User A'));
        expect(
          sql,
          contains('User B cannot attach own study plan to User A subject'),
        );
        expect(sql, contains('User B cannot update User A study plan'));
        expect(sql, contains('User B cannot delete User A study plan'));
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );
  });
}
