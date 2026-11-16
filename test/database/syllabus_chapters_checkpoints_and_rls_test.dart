import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 9F - Syllabus Chapters, Checkpoints, and RLS Test', () {
    test('migration 20261113000000_syllabus_chapters_checkpoints.sql is valid',
        () {
      final file = File(
        'supabase/migrations/20261113000000_syllabus_chapters_checkpoints.sql',
      );
      expect(file.existsSync(), isTrue);

      final sql = file.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('CREATE TABLE public.chapters'));
      expect(
        sql,
        contains('ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY'),
      );
      expect(sql, contains('enabled_checkpoints text[]'));
      expect(sql, contains('chapter_id uuid'));
      expect(sql, contains('study_done_at timestamptz'));
      expect(sql, contains('practice_done_at timestamptz'));
      expect(sql, contains('model_test_done_at timestamptz'));
      expect(sql, contains('revision_done_at timestamptz'));
      expect(sql, contains('weight integer NOT NULL DEFAULT 1'));
    });

    test(
        'pgTAP test 19_syllabus_chapters_checkpoints_and_rls_test.sql '
        'is complete', () {
      final file = File(
        'supabase/tests/19_syllabus_chapters_checkpoints_and_rls_test.sql',
      );
      expect(file.existsSync(), isTrue);

      final sql = file.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('public.chapters table exists'));
      expect(sql, contains('User A can read own chapter'));
      expect(sql, contains('User B cannot read User A chapter'));
      expect(sql, contains('User B cannot read User A topic'));
      expect(sql, contains('Status migration stamps study_done_at'));
    });
  });
}
