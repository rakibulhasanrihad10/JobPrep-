import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_templates.dart';
import 'package:job_prep/l10n/app_localizations.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  group('PrepTemplates & PrepProgressLogNotifier', () {
    test('loads localized templates and applies bcsCore subjects & materials',
        () async {
      final enL10n = lookupAppLocalizations(const Locale('en'));
      final bnL10n = lookupAppLocalizations(const Locale('bn'));
      final enTemplates = PrepTemplates.all(enL10n);
      final bnTemplates = PrepTemplates.all(bnL10n);

      expect(enTemplates, hasLength(3));
      expect(bnTemplates, hasLength(3));
      expect(
        enTemplates.first.subjects.first.materials.map((m) => m.totalUnits),
        [300, 300, 400],
      );

      final subjectRepo = FakeSubjectRepository();
      final materialRepo = FakeMaterialRepository();
      final container = ProviderContainer(
        overrides: [
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
        ],
      );
      addTearDown(container.dispose);

      final ok = await container
          .read(prepSubjectsControllerProvider.notifier)
          .applyTemplate(enTemplates.first);

      expect(ok, isTrue);
      expect(subjectRepo.subjects, hasLength(3));
      expect(subjectRepo.subjects.map((s) => s.sortOrder).toList(), [0, 1, 2]);
      expect(materialRepo.materials, hasLength(5));
      expect(
        await container.read(subjectsProvider.future),
        hasLength(3),
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
