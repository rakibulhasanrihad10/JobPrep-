import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';

void main() {
  group('Supabase Base - Riverpod Client Provider Tests', () {
    test(
      'throws error with guidance when Supabase credentials are not set',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container.read(supabaseClientProvider),
          throwsA(
            predicate(
              (e) => e.toString().contains(
                    'Provide SUPABASE_URL and SUPABASE_ANON_KEY',
                  ),
            ),
          ),
        );
      },
    );
  });

  group('Supabase Base - CLI & Local Development Structure Tests', () {
    test('supabase/config.toml exists and configures jobprep project', () {
      final configFile = File('supabase/config.toml');
      expect(configFile.existsSync(), isTrue, reason: 'config.toml must exist');

      final content = configFile.readAsStringSync();
      expect(content, contains('project_id = "jobprep"'));
      expect(content, contains('[api]'));
      expect(content, contains('[db]'));
    });

    test('supabase/migrations directory contains initial baseline migration',
        () {
      final migrationsDir = Directory('supabase/migrations');
      expect(
        migrationsDir.existsSync(),
        isTrue,
        reason: 'supabase/migrations must exist',
      );

      final sqlFiles = migrationsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      expect(
        sqlFiles,
        isNotEmpty,
        reason: 'At least one migration file must exist',
      );

      final firstMigration = sqlFiles.first;
      final content = firstMigration.readAsStringSync().trim();
      expect(content, isNotEmpty);
      expect(content, contains('CREATE EXTENSION IF NOT EXISTS "pgcrypto"'));
    });

    test('README.md comprehensively documents local and cloud Supabase setup',
        () {
      final readme = File('README.md');
      expect(readme.existsSync(), isTrue);

      final content = readme.readAsStringSync();
      // Local development
      expect(content, contains('npx supabase start'));
      expect(content, contains('npx supabase status'));
      expect(content, contains('npx supabase db reset'));
      expect(content, contains('npx supabase stop'));

      // Real project setup & credentials
      expect(content, contains('Project URL'));
      expect(content, contains('anon'));
      expect(content, contains('--dart-define=SUPABASE_URL'));
      expect(content, contains('--dart-define=SUPABASE_ANON_KEY'));

      // Security requirement
      expect(content, contains('service_role'));
      expect(
        content,
        contains('Never put the `service_role` key in the client application'),
      );
    });
  });
}
