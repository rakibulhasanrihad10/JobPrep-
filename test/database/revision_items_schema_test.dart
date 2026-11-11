import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6G - revision_items Migration & pgTAP Tests', () {
    test(
      'migration defines revision_items table, constraints, indexes, and RLS',
      () {
        final migration = File(
          'supabase/migrations/20261111050000_revision_items.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('CREATE TABLE public.revision_items'));

        for (final column in [
          'user_id',
          'material_id',
          'subject_id',
          'topic_id',
          'reference_label',
          'page_number',
          'note',
          'reason',
          'source',
          'progress_log_id',
          'mock_test_id',
          'status',
          'due_on',
          'review_count',
          'last_reviewed_on',
        ]) {
          expect(sql, contains('  $column '));
        }

        expect(
          sql,
          contains("reason IN ('tricky', 'forgot', 'important', 'mistake')"),
        );
        expect(
          sql,
          contains("source IN ('log', 'mock_test', 'manual')"),
        );
        expect(
          sql,
          contains(
            "status IN ('pending', 'revised', 'mastered', 'dismissed')",
          ),
        );
        expect(sql, contains('idx_revision_items_user_id'));
        expect(sql, contains('idx_revision_items_status'));
        expect(sql, contains('idx_revision_items_due_on'));
        expect(
          sql,
          contains(
            'ALTER TABLE public.revision_items ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
      },
    );

    test(
      'pgTAP suite verifies defaults, constraints, indexes, and RLS isolation',
      () {
        final testFile = File(
          'supabase/tests/13_revision_items_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(22);'));
        expect(sql, contains('idx_revision_items_user_id'));
        expect(sql, contains('idx_revision_items_status'));
        expect(sql, contains('idx_revision_items_due_on'));
        expect(sql, contains('User B cannot read User A revision items'));
        expect(
          sql,
          contains('User B cannot update User A revision item'),
        );
        expect(
          sql,
          contains('User B cannot delete User A revision item'),
        );
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );
  });
}
