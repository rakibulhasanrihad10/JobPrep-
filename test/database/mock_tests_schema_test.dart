import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6D - Mock Tests Migration & pgTAP Tests', () {
    test(
      'migration defines mock_tests table with required columns, marks check '
      'constraints, owner FKs, and RLS policies',
      () {
        final migration = File(
          'supabase/migrations/20261111030000_mock_tests.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('CREATE TABLE public.mock_tests'));
        for (final column in [
          'user_id',
          'subject_id',
          'circular_id',
          'material_id',
          'topic_id',
          'title',
          'source',
          'taken_on',
          'marks_obtained',
          'total_marks',
          'negative_marks',
          'time_taken_minutes',
          'time_limit_minutes',
          'weak_topics',
          'notes',
        ]) {
          expect(sql, contains('  $column '));
        }

        expect(
          sql,
          contains('marks_obtained >= 0 AND marks_obtained <= total_marks'),
        );
        expect(sql, contains('total_marks > 0'));
        expect(sql, contains('FOREIGN KEY (subject_id, user_id)'));
        expect(sql, contains('FOREIGN KEY (circular_id, user_id)'));
        expect(sql, contains('FOREIGN KEY (material_id, user_id)'));
        expect(sql, contains('FOREIGN KEY (topic_id, user_id)'));
        expect(
          sql,
          contains(
            'ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
        expect(sql, contains('CREATE TRIGGER set_mock_tests_updated_at'));
      },
    );

    test(
      'pgTAP suite verifies marks bounds, cross-user RLS, and attachment FKs',
      () {
        final testFile = File(
          'supabase/tests/11_mock_tests_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(24);'));
        expect(sql, contains('mock_tests rejects negative marks_obtained'));
        expect(
          sql,
          contains('mock_tests rejects marks_obtained above total_marks'),
        );
        expect(sql, contains('User B cannot read User A mock tests'));
        expect(
          sql,
          contains('User B cannot attach own mock test to User A subject'),
        );
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );
  });
}
