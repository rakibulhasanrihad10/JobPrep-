import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_prep_template_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  group('PrepTemplates & PrepProgressLogNotifier', () {
    test('loads seeded packs and applies Government Job subjects & materials',
        () async {
      final templateRepo = FakePrepTemplateRepository();
      final templates = PrepSeededTemplates.defaults();

      expect(templates, hasLength(2));
      expect(
        templates.first.groupedSubjects.first.materials
            .map((m) => m.totalUnits),
        [300, 300, 400],
      );

      final subjectRepo = FakeSubjectRepository();
      final materialRepo = FakeMaterialRepository();
      final container = ProviderContainer(
        overrides: [
          prepTemplateRepositoryProvider.overrideWithValue(templateRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(prepTemplateActionControllerProvider.notifier)
          .applyTemplate(templates.first);

      expect(result, isNotNull);
      expect(result!.subjectsCreated, 6);
      expect(result.materialsCreated, 11);
      expect(subjectRepo.subjects, hasLength(6));
      expect(
        subjectRepo.subjects.map((s) => s.sortOrder).toList(),
        [0, 1, 2, 3, 4, 5],
      );
      expect(materialRepo.materials, hasLength(11));
      expect(
        await container.read(subjectsProvider.future),
        hasLength(6),
      );
    });

    test(
        'logs quick/custom units, updates and deletes past logs, and '
        'recomputes live subject and overall percentages', () async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(id: 'sub-1', userId: 'u-1', name: 'Bengali'),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'Book One',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'mat-2',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'Book Two',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'mat-3',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'Book Three',
            totalUnits: 400,
          ),
        ],
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
      );
      final fixedDate = DateTime.utc(2026, 11, 10, 9);

      final container = ProviderContainer(
        overrides: [
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          prepNowProvider.overrideWithValue(() => fixedDate),
        ],
      );
      addTearDown(container.dispose);

      await container.read(subjectsProvider.future);
      await container.read(allMaterialsProvider.future);

      final controller = container.read(
        prepProgressLogControllerProvider.notifier,
      );
      final mat1 = materialRepo.materials.first;

      // Non-positive units rejected cleanly
      expect(await controller.logUnits(material: mat1, units: 0), isFalse);
      expect(
        container.read(prepProgressLogControllerProvider).error,
        isA<PrepValidationFailure>(),
      );

      // Quick log +300 completes Book One (100% material, 30% subject)
      expect(
        await controller.logUnits(
          material: mat1,
          units: 300,
          note: 'Finished book 1',
        ),
        isTrue,
      );
      expect(
        container.read(subjectProgressProvider('sub-1')).value,
        closeTo(0.30, 1e-9),
      );
      expect(
        container.read(overallPrepProgressProvider).value,
        closeTo(0.30, 1e-9),
      );

      // Edit log from 300 -> 150 drops subject/overall cleanly to 15%
      final logs = await container.read(
        progressLogsForMaterialProvider('mat-1').future,
      );
      expect(logs, hasLength(1));
      expect(
        await controller.updateLog(
          material: mat1,
          existing: logs.first,
          unitsDone: 150,
          loggedOn: fixedDate,
          note: 'Updated note',
        ),
        isTrue,
      );
      expect(
        container.read(subjectProgressProvider('sub-1')).value,
        closeTo(0.15, 1e-9),
      );

      // Delete log restores 0%
      final updatedLogs = await container.read(
        progressLogsForMaterialProvider('mat-1').future,
      );
      expect(
        await controller.deleteLog(
          material: mat1,
          log: updatedLogs.first,
        ),
        isTrue,
      );
      expect(container.read(subjectProgressProvider('sub-1')).value, 0.0);

      // Maps network failure cleanly
      logRepo.nextError = const PrepNetworkFailure();
      expect(await controller.logUnits(material: mat1, units: 10), isFalse);
      expect(
        container.read(prepProgressLogControllerProvider).error,
        isA<PrepNetworkFailure>(),
      );
    });
  });
}
