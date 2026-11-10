import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 3A - Circulars Database Migration & pgTAP RLS Tests', () {
    test(
      'circulars schema migration defines all tables, columns, and security',
      () {
        final migrationFile = File(
          'supabase/migrations/20261110000000_circulars_schema.sql',
        );
        expect(migrationFile.existsSync(), isTrue);

        final sql = migrationFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        // Shared trigger function
        expect(
          sql,
          contains('CREATE OR REPLACE FUNCTION public.set_updated_at()'),
        );
        expect(sql, contains('NEW.updated_at := now();'));

        // Required tables
        expect(sql, contains('CREATE TABLE public.circulars'));
        expect(sql, contains('CREATE TABLE public.circular_exam_dates'));
        expect(sql, contains('CREATE TABLE public.circular_files'));

        // Common columns and primary/foreign keys
        expect(
          RegExp(r'id uuid PRIMARY KEY DEFAULT gen_random_uuid\(\)')
              .allMatches(sql)
              .length,
          equals(3),
        );
        expect(
          RegExp(r'REFERENCES auth\.users \(id\) ON DELETE CASCADE')
              .allMatches(sql)
              .length,
          equals(3),
        );
        expect(
          RegExp(r'BEFORE UPDATE ON public\.circular').allMatches(sql).length,
          equals(3),
        );

        // Required circulars columns
        const circularsColumns = <String>[
          'title',
          'sector',
          'organization_name',
          'organization_website',
          'circular_url',
          'application_url',
          'deadline',
          'vacancies',
          'salary_min',
          'salary_max',
          'salary_note',
          'application_fee',
          'fee_note',
          'application_status',
          'admit_card_status',
          'priority',
          'workflow_status',
          'instructions',
          'notes',
          'syllabus',
          'is_quick_capture',
          'created_at',
          'updated_at',
        ];
        for (final column in circularsColumns) {
          expect(sql, contains('  $column '));
        }

        // Required circular_exam_dates & circular_files columns
        for (final column in const [
          'circular_id',
          'stage',
          'exam_date',
          'venue',
          'notes',
          'storage_path',
          'file_name',
          'mime_type',
          'size_bytes',
        ]) {
          expect(sql, contains('  $column '));
        }

        // Check constraints on sector and status fields
        expect(sql, contains('circulars_sector_check CHECK'));
        expect(sql, contains('circulars_application_status_check CHECK'));
        expect(sql, contains('circulars_admit_card_status_check CHECK'));
        expect(sql, contains('circulars_priority_check CHECK'));
        expect(sql, contains('circulars_workflow_status_check CHECK'));

        // Indexes on user_id, deadline, and workflow_status
        expect(sql, contains('idx_circulars_user_id'));
        expect(sql, contains('idx_circulars_deadline'));
        expect(sql, contains('idx_circulars_workflow_status'));
        expect(sql, contains('idx_circular_exam_dates_user_id'));
        expect(sql, contains('idx_circular_files_user_id'));

        // Row Level Security enabled & policies on all 3 tables
        expect(
          RegExp('ENABLE ROW LEVEL SECURITY;').allMatches(sql).length,
          equals(3),
        );
        expect(
          RegExp(r'USING \(user_id = auth\.uid\(\)\)').allMatches(sql).length,
          equals(9),
        );
        expect(
          RegExp(r'WITH CHECK \(user_id = auth\.uid\(\)\)')
              .allMatches(sql)
              .length,
          equals(6),
        );
      },
    );

    test(
      'pgTAP test suite covers multi-user RLS isolation and constraints',
      () {
        final testFile = File(
          'supabase/tests/01_circulars_schema_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('CREATE EXTENSION IF NOT EXISTS pgtap'));
        expect(sql, contains('SELECT plan(62);'));
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));

        // Ensure User A vs User B isolation tests exist for read, update,
        // and delete across all three tables.
        expect(sql, contains('User A only reads own circulars'));
        expect(sql, contains('User A cannot update User B circular'));
        expect(sql, contains('User A cannot delete User B circular'));
        expect(
          sql,
          contains('User A cannot update User B circular_exam_dates row'),
        );
        expect(
          sql,
          contains('User A cannot delete User B circular_exam_dates row'),
        );
        expect(sql, contains('User A cannot update User B circular_files row'));
        expect(sql, contains('User A cannot delete User B circular_files row'));
      },
    );

    test('CI database workflow executes supabase test db', () {
      final ciFile = File('.github/workflows/ci.yml');
      expect(ciFile.existsSync(), isTrue);

      final ciYaml = ciFile.readAsStringSync();
      expect(ciYaml, isNot(contains('\r\n')));
      expect(ciYaml, contains('supabase db reset'));
      expect(ciYaml, contains('supabase test db'));
    });
  });
}
