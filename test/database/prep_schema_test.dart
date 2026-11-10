import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 4A - Preparation Database Migration & pgTAP Tests', () {
    test('prep schema migration defines all 5 tables, trigger, views, and RLS',
        () {
      final migration = File(
        'supabase/migrations/20261110040000_prep_schema.sql',
      );
      expect(migration.existsSync(), isTrue);

      final sql = migration.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));

      for (final table in [
        'subjects',
        'materials',
        'progress_logs',
        'topics',
        'circular_subjects',
      ]) {
        expect(sql, contains('CREATE TABLE public.$table'));
        expect(
          sql,
          contains('ALTER TABLE public.$table ENABLE ROW LEVEL SECURITY'),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
        expect(sql, contains('CREATE TRIGGER set_${table}_updated_at'));
      }

      // Required columns
      expect(sql, contains('exam_type'));
      expect(sql, contains('sort_order'));
      expect(sql, contains('unit_label'));
      expect(sql, contains('total_units'));
      expect(sql, contains('completed_units'));
      expect(sql, contains('cover_image_path'));
      expect(sql, contains('cover_image_url'));
      expect(sql, contains('units_done'));
      expect(sql, contains('logged_on'));

      // Recalculation trigger with clamping bounds [0, total_units]
      expect(
        sql,
        contains('CREATE OR REPLACE FUNCTION '
            'public.recalculate_material_completed_units()'),
      );
      expect(
        sql,
        contains('AFTER INSERT OR UPDATE OR DELETE ON public.progress_logs'),
      );
      expect(sql, contains('LEAST(m.total_units, GREATEST(0, v_sum))'));

      // Progress views with division-by-zero protection and caller RLS
      expect(sql, contains('CREATE VIEW public.material_progress'));
      expect(sql, contains('CREATE VIEW public.subject_progress'));
      expect(sql, contains('WITH (security_invoker = true)'));
    });

    test(
        'pgTAP suite verifies trigger, 300/300/400 views, division by zero, '
        'and RLS isolation', () {
      final testFile = File(
        'supabase/tests/05_prep_schema_views_and_rls_test.sql',
      );
      expect(testFile.existsSync(), isTrue);

      final sql = testFile.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('BEGIN;'));
      expect(sql, contains('SELECT plan(42);'));
      expect(sql, contains('SELECT * FROM finish();'));
      expect(sql, contains('ROLLBACK;'));

      // Verifies 300, 300, 400 books example -> 100% book one & 30% subject
      expect(sql, contains("'1.00|100.00'"));
      expect(sql, contains("'300|1000|0.30|30.00'"));
      expect(sql, contains('division by zero'));
      expect(sql, contains('User B cannot read User A subjects'));
      expect(sql, contains('User B cannot read User A materials'));
      expect(sql, contains('User B cannot read User A progress_logs'));
      expect(sql, contains('User B cannot read User A topics'));
      expect(sql, contains('User B cannot read User A circular_subjects'));
      expect(
        sql,
        contains('User B cannot read User A rows from material_progress view'),
      );
      expect(
        sql,
        contains('User B cannot read User A rows from subject_progress view'),
      );
    });
  });

  group('Phase 4C - Material Covers Private Storage Migration & pgTAP Tests',
      () {
    test('storage migration defines private material-covers bucket and RLS',
        () {
      final migration = File(
        'supabase/migrations/20261110050000_storage_material_covers_bucket.sql',
      );
      expect(migration.existsSync(), isTrue);

      final sql = migration.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains("'material-covers'"));
      expect(sql, contains('false'));
      expect(sql, contains('5242880'));
      expect(sql, contains("'image/jpeg'"));
      expect(sql, contains("'image/png'"));
      expect(sql, contains("'image/webp'"));
      expect(sql, contains('ON storage.objects'));
      expect(sql, contains("split_part(name, '/', 1) = auth.uid()::text"));
      expect(sql, contains("strpos(name, '/') > 0"));
      expect(sql, contains('FOR SELECT'));
      expect(sql, contains('FOR INSERT'));
      expect(sql, contains('FOR UPDATE'));
      expect(sql, contains('FOR DELETE'));
    });

    test('pgTAP test verifies private cover bucket and cross-user isolation',
        () {
      final testFile = File(
        'supabase/tests/06_storage_material_covers_bucket_test.sql',
      );
      expect(testFile.existsSync(), isTrue);

      final sql = testFile.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, isNot(contains('DELETE FROM storage.objects')));
      expect(sql, contains('pg_catalog.pg_policies'));
      expect(sql, contains('BEGIN;'));
      expect(sql, contains('SELECT plan(13);'));
      expect(sql, contains("'material-covers'"));
      expect(
        sql,
        contains(
          'User A can upload material cover into own user_id folder',
        ),
      );
      expect(sql, contains('User B cannot read User A cover'));
      expect(sql, contains('User B cannot update User A cover'));
      expect(sql, contains('User B cannot delete User A cover'));
      expect(sql, contains('SELECT * FROM finish();'));
      expect(sql, contains('ROLLBACK;'));
    });
  });

  group('Phase 4E - Prep Templates Migration & pgTAP Tests', () {
    test(
        'migration creates prep_templates & prep_template_items with RLS and '
        'seeds Government Job & Software Engineer packs', () {
      final migration = File(
        'supabase/migrations/20261110060000_prep_templates.sql',
      );
      expect(migration.existsSync(), isTrue);

      final sql = migration.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('CREATE TABLE public.prep_templates'));
      expect(sql, contains('CREATE TABLE public.prep_template_items'));
      expect(
        sql,
        contains(
          'ALTER TABLE public.prep_templates ENABLE ROW LEVEL SECURITY',
        ),
      );
      expect(
        sql,
        contains(
          'ALTER TABLE public.prep_template_items ENABLE ROW LEVEL SECURITY',
        ),
      );
      expect(sql, contains("'government_job'"));
      expect(sql, contains("'Government Job'"));
      expect(sql, contains("'software_engineer'"));
      expect(sql, contains("'Software Engineer'"));

      for (final subject in [
        'Bengali',
        'English',
        'General Knowledge',
        'Mathematics',
        'Analytical Reasoning',
        'Computer',
        'Data Structures and Algorithms',
        'Database Systems',
        'Object-Oriented Programming',
        'Web Development',
        'Software Quality Assurance',
      ]) {
        expect(sql, contains("'$subject'"));
      }
    });

    test(
        'pgTAP suite verifies read-only system packs, personal templates, '
        'and cross-user RLS', () {
      final testFile = File(
        'supabase/tests/07_prep_templates_and_rls_test.sql',
      );
      expect(testFile.existsSync(), isTrue);

      final sql = testFile.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));
      expect(sql, contains('BEGIN;'));
      expect(sql, contains('SELECT plan(31);'));
      expect(sql, contains('Signed-in users cannot insert system templates'));
      expect(sql, contains('Signed-in users cannot update seeded system'));
      expect(sql, contains('Signed-in users cannot delete seeded system'));
      expect(sql, contains('User B cannot read User A personal template'));
      expect(sql, contains('User B cannot update User A personal template'));
      expect(sql, contains('User B cannot delete User A personal template'));
      expect(sql, contains('SELECT * FROM finish();'));
      expect(sql, contains('ROLLBACK;'));
    });
  });
}
