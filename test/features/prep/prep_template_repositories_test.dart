import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/repositories/local_prep_template_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_plan.dart';

import '../../contracts/mock_supabase_http_client.dart';

class _FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return jsonEncode({
      'id': 'tpl-mock',
      'slug': 'mock_plan',
      'title': 'Mock Plan',
      'description': 'Mock Desc',
      'exam_type': 'general',
      'is_system': true,
      'sort_order': 1,
      'items': [
        {
          'id': 'item-1',
          'template_id': 'tpl-mock',
          'subject_name': 'Math',
          'subject_color': '#4CAF50',
          'subject_icon': 'book',
          'exam_type': 'general',
          'subject_sort_order': 0,
          'material_title': 'Calculus',
          'material_kind': 'book',
          'unit_label': 'pages',
          'total_units': 100,
          'item_sort_order': 0,
        }
      ],
    });
  }
}

void main() {
  group('LocalPrepTemplateRepository', () {
    test('loads bundled templates and manages personal templates', () async {
      final repo = LocalPrepTemplateRepository(bundle: _FakeAssetBundle());
      final templates = await repo.getTemplates();
      expect(templates, isNotEmpty);
      expect(templates.first.isSystem, isTrue);

      const subject = Subject(id: 'sub-1', name: 'Science');
      const material = PrepMaterial(
        id: 'mat-1',
        subjectId: 'sub-1',
        title: 'Physics Book',
        totalUnits: 250,
      );

      final saved = await repo.savePersonalTemplate(
        title: 'My Custom Plan',
        description: 'Test description',
        subjects: [subject],
        materials: [material],
      );

      expect(saved.title, equals('My Custom Plan'));
      expect(saved.isSystem, isFalse);
      expect(saved.items, hasLength(1));

      final allTemplates = await repo.getTemplates();
      expect(allTemplates.any((t) => t.id == saved.id), isTrue);

      await repo.deletePersonalTemplate(saved.id);
      final afterDelete = await repo.getTemplates();
      expect(afterDelete.any((t) => t.id == saved.id), isFalse);
    });

    test('validates title and subjects', () async {
      final repo = LocalPrepTemplateRepository();
      expect(
        () => repo.savePersonalTemplate(
          title: '   ',
          subjects: [],
          materials: [],
        ),
        throwsA(isA<PrepValidationFailure>()),
      );
    });
  });

  group('SupabasePrepTemplateRepository', () {
    late MockSupabaseHttpClient mockHttp;
    late SupabasePrepTemplateRepository repo;

    setUp(() {
      mockHttp = MockSupabaseHttpClient();
      final client = MockSupabaseClient(mockHttpClient: mockHttp);
      repo = SupabasePrepTemplateRepository(client);
    });

    test('validates inputs before saving personal template', () async {
      expect(
        () => repo.savePersonalTemplate(
          title: '',
          subjects: [],
          materials: [],
        ),
        throwsA(isA<PrepValidationFailure>()),
      );

      expect(
        () => repo.savePersonalTemplate(
          title: 'Valid Title',
          subjects: [],
          materials: [],
        ),
        throwsA(isA<PrepValidationFailure>()),
      );
    });

    test('getTemplates queries templates table', () async {
      mockHttp.tables['prep_templates'] = [
        {
          'id': 'tpl-1',
          'title': 'BCS Starter',
          'description': 'Desc',
          'exam_type': 'bcs',
          'is_system': true,
          'sort_order': 0,
          'created_at': DateTime.utc(2026).toIso8601String(),
          'prep_template_items': <Map<String, dynamic>>[],
        }
      ];

      final templates = await repo.getTemplates();
      expect(templates, hasLength(1));
      expect(templates.first.title, equals('BCS Starter'));
    });
  });

  group('PrepTemplatePlan Entities', () {
    test('PrepTemplateApplyResult properties', () {
      const result = PrepTemplateApplyResult(
        templateTitle: 'Govt Job',
        subjectsCreated: 3,
        materialsCreated: 5,
        subjectsSkipped: 1,
        materialsSkipped: 2,
      );
      expect(result.alreadyApplied, isFalse);
      expect(result.templateTitle, equals('Govt Job'));

      const noOp = PrepTemplateApplyResult(
        templateTitle: 'Govt Job',
        subjectsCreated: 0,
        materialsCreated: 0,
        subjectsSkipped: 4,
        materialsSkipped: 7,
      );
      expect(noOp.alreadyApplied, isTrue);

      const plan = PrepTemplateCopyPlan(
        operations: [],
        summary: result,
      );
      expect(plan.hasChanges, isTrue);
    });
  });
}
