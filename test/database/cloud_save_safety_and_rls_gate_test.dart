import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 9E - Cloud Save Safety & Schema RLS Gate Test', () {
    test(
        '18_cloud_save_upsert_safety_and_rls_gate_test.sql '
        'is valid and complete', () {
      final pgtapFile = File(
        'supabase/tests/18_cloud_save_upsert_safety_and_rls_gate_test.sql',
      );
      expect(pgtapFile.existsSync(), isTrue);

      final sql = pgtapFile.readAsStringSync();
      expect(sql, isNot(contains('\r\n')));

      // Verifies RLS Gate
      expect(
        sql,
        contains(
          'RLS Gate: Every table in the public schema must have '
          'Row Level Security enabled',
        ),
      );
      expect(
        sql,
        contains(
          'RLS Gate: Every table in the public schema must have '
          'at least one RLS policy',
        ),
      );

      // Verifies Cross-tenant upsert safety
      expect(
        sql,
        contains('User A can insert a circular with client-generated id'),
      );
      expect(
        sql,
        contains('User B cannot insert a circular carrying User A user_id'),
      );
      expect(
        sql,
        contains(
          'User A circular remains unmodified after User B upsert attempt',
        ),
      );
      expect(
        sql,
        contains(
          'User A subject remains unmodified after User B upsert attempt',
        ),
      );
      expect(
        sql,
        contains(
          'User A material remains unmodified after User B upsert attempt',
        ),
      );
      expect(
        sql,
        contains(
          'User A progress log units_done is unmodified after User B '
          'upsert attempt',
        ),
      );

      // Verifies anon insertion rejection
      expect(sql, contains('Anon cannot insert circulars'));
      expect(sql, contains('Anon cannot insert subjects'));
      expect(sql, contains('Anon cannot insert materials'));
      expect(sql, contains('Anon cannot insert progress_logs'));
      expect(sql, contains('Anon cannot insert user_settings'));

      // Verifies legitimate owner idempotency
      expect(
        sql,
        contains('Saving same circular id twice leaves exactly one row'),
      );
      expect(
        sql,
        contains('Saving same subject id twice leaves exactly one row'),
      );
      expect(
        sql,
        contains('Saving same material id twice leaves exactly one row'),
      );
    });

    test('all migration files declare Row Level Security on all created tables',
        () {
      final migrationsDir = Directory('supabase/migrations');
      expect(migrationsDir.existsSync(), isTrue);

      final files = migrationsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      final createdTables = <String>{};
      final rlsEnabledTables = <String>{};

      final tableRegex = RegExp(
        r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?public\.([a-z0-9_]+)',
        caseSensitive: false,
      );
      final rlsRegex = RegExp(
        r'ALTER\s+TABLE\s+(?:ONLY\s+)?public\.([a-z0-9_]+)\s+ENABLE\s+ROW\s+LEVEL\s+SECURITY',
        caseSensitive: false,
      );

      for (final file in files) {
        final content = file.readAsStringSync();
        for (final match in tableRegex.allMatches(content)) {
          createdTables.add(match.group(1)!);
        }
        for (final match in rlsRegex.allMatches(content)) {
          rlsEnabledTables.add(match.group(1)!);
        }
      }

      // Assert that every created table has RLS explicitly enabled
      for (final table in createdTables) {
        expect(
          rlsEnabledTables.contains(table),
          isTrue,
          reason: 'Table public.$table must have ENABLE ROW LEVEL SECURITY',
        );
      }

      expect(createdTables.length, greaterThanOrEqualTo(18));
    });
  });
}
