import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Template Packs JSON Assets Drift Verification', () {
    late String migrationSql;
    late Map<String, dynamic> govJobJson;
    late Map<String, dynamic> softEngJson;

    setUpAll(() {
      final migrationFile =
          File('supabase/migrations/20261110060000_prep_templates.sql');
      expect(migrationFile.existsSync(), isTrue);
      migrationSql = migrationFile.readAsStringSync();

      final govJobFile = File('assets/templates/government_job.json');
      expect(govJobFile.existsSync(), isTrue);
      govJobJson =
          jsonDecode(govJobFile.readAsStringSync()) as Map<String, dynamic>;

      final softEngFile = File('assets/templates/software_engineer.json');
      expect(softEngFile.existsSync(), isTrue);
      softEngJson =
          jsonDecode(softEngFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('government_job.json matches seeded migration data identically', () {
      expect(govJobJson['id'], equals('00000000-0000-4000-8000-000000000101'));
      expect(govJobJson['slug'], equals('government_job'));
      expect(govJobJson['title'], equals('Government Job'));
      expect(govJobJson['exam_type'], equals('government'));
      expect(govJobJson['is_system'], isTrue);
      expect(govJobJson['sort_order'], equals(0));

      final items = govJobJson['items'] as List<dynamic>;
      expect(items.length, equals(11));

      // Verify presence in SQL migration
      expect(migrationSql, contains(govJobJson['id'] as String));
      expect(migrationSql, contains(govJobJson['slug'] as String));

      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;
        expect(migrationSql, contains(item['id'] as String));
        expect(migrationSql, contains(item['material_title'] as String));
        expect(migrationSql, contains(item['total_units'].toString()));
      }
    });

    test('software_engineer.json matches seeded migration data identically',
        () {
      expect(
        softEngJson['id'],
        equals('00000000-0000-4000-8000-000000000102'),
      );
      expect(softEngJson['slug'], equals('software_engineer'));
      expect(softEngJson['title'], equals('Software Engineer'));
      expect(softEngJson['exam_type'], equals('engineering'));
      expect(softEngJson['is_system'], isTrue);
      expect(softEngJson['sort_order'], equals(1));

      final items = softEngJson['items'] as List<dynamic>;
      expect(items.length, equals(8));

      // Verify presence in SQL migration
      expect(migrationSql, contains(softEngJson['id'] as String));
      expect(migrationSql, contains(softEngJson['slug'] as String));

      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;
        expect(migrationSql, contains(item['id'] as String));
        expect(migrationSql, contains(item['material_title'] as String));
        expect(migrationSql, contains(item['total_units'].toString()));
      }
    });
  });
}
