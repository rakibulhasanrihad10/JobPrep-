import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/mappers/prep_template_item_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_template_mapper.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_prep_template_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_prep_template_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  group('PrepTemplate Mappers, Planner & ActionController', () {
    test('mappers deserialize embedded items deterministically & clamp bounds',
        () {
      final json = <String, dynamic>{
        'id': 'tpl-1',
        'user_id': null,
        'slug': 'government_job',
        'title': 'Government Job',
        'description': 'Seeded pack',
        'exam_type': 'government',
        'is_system': true,
        'sort_order': 0,
        'prep_template_items': [
          <String, dynamic>{
            'id': 'item-2',
            'template_id': 'tpl-1',
            'subject_name': 'English',
            'subject_color': 'info',
            'subject_icon': 'menu_book',
            'exam_type': 'government',
            'subject_sort_order': 1,
            'material_title': 'Grammar',
            'material_kind': 'book',
            'unit_label': 'pages',
            'total_units': 300,
            'item_sort_order': 1,
          },
          <String, dynamic>{
            'id': 'item-1',
            'template_id': 'tpl-1',
            'subject_name': 'Bengali',
            'subject_color': 'gold',
            'subject_icon': 'language',
            'exam_type': 'government',
            'subject_sort_order': 0,
            'material_title': 'Literature',
            'material_kind': 'book',
            'unit_label': 'pages',
            'total_units': -50,
            'item_sort_order': 0,
          },
        ],
      };

      final parsed = PrepTemplateMapper.fromJson(json);
      expect(parsed.isSystem, isTrue);
      expect(parsed.items, hasLength(2));
      expect(parsed.items.first.subjectName, 'Bengali');
      expect(parsed.items.first.totalUnits, 0);
      expect(parsed.items.last.subjectName, 'English');

      final insertTemplateJson = PrepTemplateMapper.toInsertJson(
        parsed.copyWith(id: '', userId: 'u-1', isSystem: true),
      );
      expect(insertTemplateJson['is_system'], isFalse);

      final insertItemJson = PrepTemplateItemMapper.toInsertJson(
        parsed.items.first,
        templateId: 'tpl-new',
        userId: 'u-1',
      );
      expect(insertItemJson['template_id'], 'tpl-new');
      expect(insertItemJson['user_id'], 'u-1');
    });

    test(
        'default prepTemplateRepositoryProvider serves read-only packs and '
        'blocks unconfigured personal writes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(prepTemplateRepositoryProvider);
      expect(repo, isA<UnconfiguredPrepTemplateRepository>());

      final defaults = await repo.getTemplates();
      expect(defaults, hasLength(2));
      expect(
        defaults.first.groupedSubjects.map((g) => g.subjectName).toList(),
        [
          'Bengali',
          'English',
          'General Knowledge',
          'Mathematics',
          'Analytical Reasoning',
          'Computer',
        ],
      );
      expect(
        defaults.last.groupedSubjects.map((g) => g.subjectName).toList(),
        [
          'Data Structures and Algorithms',
          'Database Systems',
          'Object-Oriented Programming',
          'Web Development',
          'Software Quality Assurance',
        ],
      );

      await expectLater(
        () => repo.savePersonalTemplate(
          title: 'Personal',
          subjects: const [Subject(id: 's1', name: 'Math')],
          materials: const [],
        ),
        throwsA(isA<PrepFailure>()),
      );
      await expectLater(
        () => repo.deletePersonalTemplate('id-1'),
        throwsA(isA<PrepFailure>()),
      );
    });

    test(
        'applying Government Job & Software Engineer supports unit overrides '
        'and prevents duplicates when applied twice or concurrently', () async {
      final subjectRepo = FakeSubjectRepository();
      final materialRepo = FakeMaterialRepository();
      final templateRepo = FakePrepTemplateRepository();

      final container = ProviderContainer(
        overrides: [
          prepTemplateRepositoryProvider.overrideWithValue(templateRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        prepTemplateActionControllerProvider.notifier,
      );
      const govPack = PrepSeededTemplates.governmentJob;
      const swePack = PrepSeededTemplates.softwareEngineer;

      // Apply Software Engineer with custom unit override on DSA Problem Set
      final dsaItem = swePack.items.first;
      final firstSwe = await controller.applyTemplate(
        swePack,
        unitOverrides: {dsaItem.id: 225},
      );
      expect(firstSwe, isNotNull);
      expect(firstSwe!.subjectsCreated, 5);
      expect(firstSwe.materialsCreated, 8);
      expect(firstSwe.alreadyApplied, isFalse);

      final dsaMaterial = materialRepo.materials
          .firstWhere((m) => m.title == 'Core DSA Problem Set');
      expect(dsaMaterial.totalUnits, 225);

      // Copied subjects and materials are user-owned & fully editable afterward
      final updatedMaterial = await materialRepo.updateMaterial(
        dsaMaterial.copyWith(totalUnits: 260),
      );
      expect(updatedMaterial.totalUnits, 260);

      // Second apply of Software Engineer produces ZERO duplicates
      final secondSwe = await controller.applyTemplate(swePack);
      expect(secondSwe, isNotNull);
      expect(secondSwe!.alreadyApplied, isTrue);
      expect(secondSwe.subjectsCreated, 0);
      expect(secondSwe.materialsCreated, 0);
      expect(subjectRepo.subjects, hasLength(5));
      expect(materialRepo.materials, hasLength(8));
      expect(
        materialRepo.materials
            .firstWhere((m) => m.title == 'Core DSA Problem Set')
            .totalUnits,
        260,
      );

      // Deleting 1 subject then re-applying restores ONLY the missing subject
      final sqaSubject = subjectRepo.subjects
          .firstWhere((s) => s.name == 'Software Quality Assurance');
      await subjectRepo.deleteSubject(sqaSubject.id);
      final sqaMaterialIds = materialRepo.materials
          .where((m) => m.subjectId == sqaSubject.id)
          .map((m) => m.id)
          .toList();
      for (final id in sqaMaterialIds) {
        await materialRepo.deleteMaterial(id);
      }

      final restoreSwe = await controller.applyTemplate(swePack);
      expect(restoreSwe, isNotNull);
      expect(restoreSwe!.subjectsCreated, 1);
      expect(restoreSwe.materialsCreated, 1);
      expect(subjectRepo.subjects, hasLength(5));

      // Concurrent double-apply guard prevents race duplicates
      final concurrent = await Future.wait(<Future<PrepTemplateApplyResult?>>[
        controller.applyTemplate(govPack),
        controller.applyTemplate(govPack),
      ]);
      final executed = concurrent.whereType<PrepTemplateApplyResult>().toList();
      expect(executed, hasLength(1));
      expect(executed.single.subjectsCreated, 6);
      expect(subjectRepo.subjects, hasLength(11)); // 5 SWE + 6 Gov
    });

    test(
        'personal templates enforce validation, read-only system rules, and '
        'cross-user isolation', () async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 's1',
            userId: 'user-1',
            name: 'Algorithms',
            color: 'info',
            icon: 'computer',
            examType: 'SWE',
          ),
          Subject(
            id: 's2',
            userId: 'user-1',
            name: 'System Design',
            examType: 'SWE',
            sortOrder: 1,
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'm1',
            userId: 'user-1',
            subjectId: 's1',
            title: 'Graph Algorithms',
            kind: MaterialKind.questionBank,
            unitLabel: 'questions',
            totalUnits: 120,
          ),
        ],
      );
      final templateRepo = FakePrepTemplateRepository();

      final container = ProviderContainer(
        overrides: [
          prepTemplateRepositoryProvider.overrideWithValue(templateRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        prepTemplateActionControllerProvider.notifier,
      );

      // Blank title rejected
      expect(
        await controller.savePersonalTemplate(
          title: '   ',
          subjects: subjectRepo.subjects,
          materials: materialRepo.materials,
        ),
        isNull,
      );

      // Valid save captures both multi-material & empty subjects cleanly
      final saved = await controller.savePersonalTemplate(
        title: 'My Custom SWE Plan',
        description: 'Reusable backend track',
        examType: 'SWE',
        subjects: subjectRepo.subjects,
        materials: materialRepo.materials,
      );
      expect(saved, isNotNull);
      expect(saved!.isSystem, isFalse);
      expect(saved.subjectCount, 2);
      expect(saved.materialCount, 1);

      // Cannot delete read-only system starter pack
      expect(
        await controller.deletePersonalTemplate(
          PrepSeededTemplates.governmentJob,
        ),
        isFalse,
      );
      expect(
        container.read(prepTemplateActionControllerProvider).error,
        isA<PrepPermissionFailure>(),
      );

      // Cross-user isolation: User 2 sees system packs, not User 1 personal
      templateRepo.activeUserId = 'user-2';
      final userTwoVisible = await templateRepo.getTemplates();
      expect(userTwoVisible.where((t) => !t.isSystem), isEmpty);
      await expectLater(
        () => templateRepo.deletePersonalTemplate(saved.id),
        throwsA(isA<PrepPermissionFailure>()),
      );

      // User 1 can delete own personal template
      templateRepo.activeUserId = 'user-1';
      expect(await controller.deletePersonalTemplate(saved), isTrue);
      expect(
        (await templateRepo.getTemplates()).where((t) => !t.isSystem),
        isEmpty,
      );
    });
  });
}
