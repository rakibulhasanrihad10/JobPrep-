import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 9G - Topic Links, Material Chapters, and RLS Test', () {
    test('migration 20261116000000 topic links is valid', () {
      final file = File(
        'supabase/migrations/20261116000000_topic_links_and_study_plan_basis.sql',
      );
      expect(file.existsSync(), isTrue);

      final sql = file.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('CREATE TABLE public.mock_test_topics'));
      expect(sql, contains('CREATE TABLE public.material_chapters'));
      expect(
        sql,
        contains(
          'ALTER TABLE public.mock_test_topics ENABLE ROW LEVEL SECURITY',
        ),
      );
      expect(
        sql,
        contains(
          'ALTER TABLE public.material_chapters ENABLE ROW LEVEL SECURITY',
        ),
      );
      expect(sql, contains('plan_basis text NOT NULL DEFAULT'));
      expect(sql, contains('study_plans_plan_basis_check'));
    });

    test('pgTAP test 20_topic_links_and_rls_test.sql is complete', () {
      final file = File('supabase/tests/20_topic_links_and_rls_test.sql');
      expect(file.existsSync(), isTrue);

      final sql = file.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('SELECT plan('));
      expect(sql, contains('mock_test_topics'));
      expect(sql, contains('material_chapters'));
      expect(sql, contains('study_plans'));
      expect(sql, contains('plan_basis'));
      expect(
        sql,
        contains('Every public table has Row Level Security enabled'),
      );
      expect(sql, contains('SELECT * FROM finish();'));
    });
  });
}
