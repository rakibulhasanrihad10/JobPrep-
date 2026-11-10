import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_topic_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_material_and_log_repositories.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  group('Prep Riverpod Providers & Trigger-Synced Progress', () {
    test('defaults to unconfigured fallbacks when Supabase client is unset',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(subjectRepositoryProvider),
        isA<UnconfiguredSubjectRepository>(),
      );
      expect(
        container.read(materialRepositoryProvider),
        isA<UnconfiguredMaterialRepository>(),
      );
      expect(
        container.read(progressLogRepositoryProvider),
        isA<UnconfiguredProgressLogRepository>(),
      );
      expect(
        container.read(topicRepositoryProvider),
        isA<UnconfiguredTopicRepository>(),
      );
    });

    test(
        'provides subjects, materials per subject, progress logs, and live '
        'computed 30% -> 45% subject and overall progress', () async {
      final fakeSubjects = FakeSubjectRepository(
        initialSubjects: const [
          Subject(id: 'sub-bcs', name: 'BCS Core', sortOrder: 1),
          Subject(id: 'sub-empty', name: 'Empty Subject', sortOrder: 2),
        ],
      );
      final fakeMaterials = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'book-1',
            subjectId: 'sub-bcs',
            title: 'Book One',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'book-2',
            subjectId: 'sub-bcs',
            title: 'Book Two',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'book-3',
            subjectId: 'sub-bcs',
            title: 'Book Three',
            totalUnits: 400,
          ),
        ],
      );
      final fakeLogs = FakeProgressLogRepository(
        materialRepository: fakeMaterials,
      );
      final fakeTopics = FakeTopicRepository(
        initialTopics: const [
          Topic(id: 'top-1', subjectId: 'sub-bcs', name: 'Constitution'),
        ],
      );

      final fakeAuth = FakeAuthRepository.authenticated(
        const AuthUser(
          id: 'user-1',
          email: 'user@example.test',
        ),
      );
      addTearDown(fakeAuth.dispose);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuth),
          subjectRepositoryProvider.overrideWithValue(fakeSubjects),
          materialRepositoryProvider.overrideWithValue(fakeMaterials),
          progressLogRepositoryProvider.overrideWithValue(fakeLogs),
          topicRepositoryProvider.overrideWithValue(fakeTopics),
        ],
      );
      addTearDown(container.dispose);

      final loadedSubjects = await container.read(subjectsProvider.future);
      expect(loadedSubjects.map((s) => s.id), ['sub-bcs', 'sub-empty']);

      final bcsMaterials = await container.read(
        materialsForSubjectProvider('sub-bcs').future,
      );
      expect(bcsMaterials, hasLength(3));
      expect(await container.read(allMaterialsProvider.future), hasLength(3));
      expect(
        await container.read(topicsForSubjectProvider('sub-bcs').future),
        hasLength(1),
      );
      expect(
        await container.read(materialsForSubjectProvider('').future),
        isEmpty,
      );

      // Finish Book One (300 pages) -> Book 100%, Subject 30%, Overall across
      // [sub-bcs (0.30), sub-empty (0.0)] = 0.15.
      await fakeLogs.createLog(
        ProgressLog(
          materialId: 'book-1',
          unitsDone: 300,
          loggedOn: DateTime(2026, 11, 10),
        ),
      );
      container
        ..invalidate(progressLogsForMaterialProvider('book-1'))
        ..invalidate(materialsForSubjectProvider('sub-bcs'))
        ..invalidate(allMaterialsProvider);

      expect(
        await container.read(
          progressLogsForMaterialProvider('book-1').future,
        ),
        hasLength(1),
      );
      await container.read(materialsForSubjectProvider('sub-bcs').future);
      await container.read(allMaterialsProvider.future);

      expect(
        container.read(subjectProgressProvider('sub-bcs')).value,
        closeTo(0.30, 1e-9),
      );
      expect(
        container.read(subjectProgressProvider('sub-empty')).value ?? 0.0,
        0.0,
      );
      expect(
        container.read(overallPrepProgressProvider).value,
        closeTo(0.15, 1e-9),
      );

      // Finish 150 pages of Book Two -> Subject 45%, Overall 22.5%.
      await fakeLogs.createLog(
        ProgressLog(
          materialId: 'book-2',
          unitsDone: 150,
          loggedOn: DateTime(2026, 11, 10),
        ),
      );
      container
        ..invalidate(materialsForSubjectProvider('sub-bcs'))
        ..invalidate(allMaterialsProvider);
      await container.read(materialsForSubjectProvider('sub-bcs').future);
      await container.read(allMaterialsProvider.future);

      expect(
        container.read(subjectProgressProvider('sub-bcs')).value,
        closeTo(0.45, 1e-9),
      );
      expect(
        container.read(overallPrepProgressProvider).value,
        closeTo(0.225, 1e-9),
      );
    });
  });
}
