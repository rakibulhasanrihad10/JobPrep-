import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_material_cover_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_material_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  group('PrepSubjectsController & PrepMaterialController', () {
    test('defaults cover repository to UnconfiguredMaterialCoverRepository',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(materialCoverRepositoryProvider);
      expect(repo, isA<UnconfiguredMaterialCoverRepository>());

      await expectLater(
        () => repo.uploadCover(
          folderKey: 'mat-1',
          fileName: 'a.png',
          mimeType: 'image/png',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<PrepPermissionFailure>()),
      );
      await expectLater(
        () => repo.createSignedCoverUrl('user-1/mat-1/a.png'),
        throwsA(isA<PrepNotFoundFailure>()),
      );
      await repo.deleteCover('user-1/mat-1/a.png');
    });

    test(
        'cleans up newly uploaded cover blob when material DB save fails and '
        'deletes orphaned covers when deleting a subject', () async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(id: 'sub-1', userId: 'u-1', name: 'Physics'),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-existing',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'Mechanics',
            totalUnits: 200,
            coverImagePath: 'u-1/sub-1/mech.png',
          ),
        ],
      );
      final coverRepo = FakeMaterialCoverRepository(
        defaultUserId: 'u-1',
        initialBlobs: {
          'u-1/sub-1/mech.png': Uint8List.fromList([9, 8, 7]),
        },
      );

      final container = ProviderContainer(
        overrides: [
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          materialCoverRepositoryProvider.overrideWithValue(coverRepo),
        ],
      );
      addTearDown(container.dispose);

      // Inject DB write failure after storage upload completes
      materialRepo.nextError = const PrepNetworkFailure();
      final pending = PreparedCoverImageResult(
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        fileName: 'opt.png',
        mimeType: 'image/png',
        wasResized: true,
        width: 600,
        height: 800,
      );

      final saved = await container
          .read(prepMaterialControllerProvider.notifier)
          .saveMaterial(
            subjectId: 'sub-1',
            title: 'Optics',
            kind: MaterialKind.book,
            unitLabel: 'pages',
            totalUnits: 120,
            pendingCoverUpload: pending,
          );

      // Allow best-effort unawaited cleanup to flush
      await Future<void>.delayed(Duration.zero);

      expect(saved, isNull);
      expect(coverRepo.deletedPaths, hasLength(1));
      expect(coverRepo.uploadedBlobs.containsKey('u-1/sub-1/mech.png'), isTrue);
      expect(
        container.read(prepMaterialControllerProvider).error,
        isA<PrepNetworkFailure>(),
      );

      // Deleting the subject removes its DB row and orphaned cover storage blob
      final deleted = await container
          .read(prepSubjectsControllerProvider.notifier)
          .deleteSubject(const Subject(id: 'sub-1', name: 'Physics'));
      await Future<void>.delayed(Duration.zero);

      expect(deleted, isTrue);
      expect(subjectRepo.subjects, isEmpty);
      expect(coverRepo.deletedPaths, contains('u-1/sub-1/mech.png'));
      expect(
        coverRepo.uploadedBlobs.containsKey('u-1/sub-1/mech.png'),
        isFalse,
      );
    });

    test('sets validation flags on empty or invalid picked cover files',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(prepMaterialControllerProvider.notifier);

      final emptyResult = await notifier.preparePickedCover(
        PickedMaterialCover.fromBytes(
          name: 'cover.png',
          bytes: Uint8List(0),
        ),
      );
      expect(emptyResult, isNull);
      expect(
        container.read(prepMaterialControllerProvider).coverValidationError,
        MaterialCoverValidationError.emptyFile,
      );

      final tooBigResult = await notifier.preparePickedCover(
        PickedMaterialCover(
          name: 'huge.webp',
          sizeBytes: MaterialCoverValidator.maxRawImageInputBytes + 10,
          readBytes: () async => Uint8List(0),
        ),
      );
      expect(tooBigResult, isNull);
      expect(
        container.read(prepMaterialControllerProvider).isRawImageTooLarge,
        isTrue,
      );

      final invalidUrlSaved = await notifier.saveMaterial(
        subjectId: 'sub-1',
        title: 'Bad URL Book',
        kind: MaterialKind.book,
        unitLabel: 'pages',
        totalUnits: 100,
        coverUrl: 'not-a-valid-url',
      );
      expect(invalidUrlSaved, isNull);
      expect(
        container.read(prepMaterialControllerProvider).coverValidationError,
        MaterialCoverValidationError.invalidUrl,
      );
    });
  });
}
