import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_mutation_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_circular_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  List<Circular> seedCirculars() {
    return [
      Circular(
        id: 'c-1',
        userId: 'user-1',
        title: '47th BCS General Cadre',
        sector: CircularSector.bcs,
        organizationName: 'Bangladesh Public Service Commission',
        deadline: DateTime.utc(2026, 11, 12, 17), // 2 days -> red
        priority: CircularPriority.urgent,
        workflowStatus: CircularWorkflowStatus.preparing,
        applicationStatus: ApplicationStatus.applied,
        notes: 'Focus on Constitution and Liberation War',
        updatedAt: DateTime.utc(2026, 11, 9, 10),
      ),
      Circular(
        id: 'c-2',
        userId: 'user-1',
        title: 'Assistant Director General',
        sector: CircularSector.bank,
        organizationName: 'Bangladesh Bank',
        deadline: DateTime.utc(2026, 11, 15, 17), // 5 days -> amber
        priority: CircularPriority.high,
        syllabus: 'Analytical ability and quantitative aptitude',
        isQuickCapture: true,
        updatedAt: DateTime.utc(2026, 11, 10, 8),
      ),
      Circular(
        id: 'c-3',
        userId: 'user-1',
        title: 'Senior Software Engineer',
        sector: CircularSector.private,
        organizationName: 'Brac IT',
        deadline: DateTime.utc(2026, 11, 25, 17), // 15 days -> green
        workflowStatus: CircularWorkflowStatus.archived,
        applicationStatus: ApplicationStatus.exempt,
        instructions: 'Send portfolio link with CV',
        updatedAt: DateTime.utc(2026, 11, 8, 9),
      ),
    ];
  }

  ProviderContainer createContainer(
    FakeCircularRepository fakeRepo, {
    FakeAuthRepository? fakeAuthRepo,
  }) {
    final container = ProviderContainer(
      overrides: [
        circularRepositoryProvider.overrideWithValue(fakeRepo),
        circularNowProvider.overrideWithValue(() => fixedNow),
        if (fakeAuthRepo != null)
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Circular List & Single Item Providers', () {
    test('circularsListProvider loads circulars sorted by ascending deadline',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars().reversed.toList(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);

      final items = await container.read(circularsListProvider.future);

      expect(items.map((c) => c.id), equals(['c-1', 'c-2', 'c-3']));
      expect(repo.getCircularsCalls, equals(1));
    });

    test(
        'circularByIdProvider fetches single item and returns null when absent',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);

      final found = await container.read(circularByIdProvider('c-2').future);
      final missing =
          await container.read(circularByIdProvider('missing-id').future);
      final blank = await container.read(circularByIdProvider('   ').future);

      expect(found?.title, equals('Assistant Director General'));
      expect(missing, isNull);
      expect(blank, isNull);
    });

    test('circularsListProvider reloads when authenticated user changes',
        () async {
      final authRepo = FakeAuthRepository(
        initialSession: const AuthSessionState.signedIn(
          AuthUser(id: 'user-1', email: 'u1@example.com', emailConfirmed: true),
        ),
      );
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo, fakeAuthRepo: authRepo);

      await container.read(circularsListProvider.future);
      expect(repo.getCircularsCalls, equals(1));

      authRepo.emitSession(
        const AuthSessionState.signedIn(
          AuthUser(id: 'user-2', email: 'u2@example.com', emailConfirmed: true),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await container.read(circularsListProvider.future);

      expect(repo.getCircularsCalls, equals(2));
    });
  });

  group('Circular Create, Update, Delete Mutation Providers', () {
    test('createCircularProvider creates item and invalidates list and item',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);

      await container.read(circularsListProvider.future);

      const draft = Circular(
        title: 'Biman Flight Engineer',
        sector: CircularSector.autonomous,
        isQuickCapture: true,
      );

      final created =
          await container.read(createCircularProvider.notifier).create(draft);

      expect(created, isNotNull);
      expect(created!.id, equals('circ-1'));
      expect(container.read(createCircularProvider).value, equals(created));

      final refreshedList = await container.read(circularsListProvider.future);
      expect(refreshedList.any((c) => c.id == created.id), isTrue);

      final detail =
          await container.read(circularByIdProvider(created.id).future);
      expect(detail?.title, equals('Biman Flight Engineer'));
    });

    test('createCircularProvider surfaces failure cleanly in AsyncError',
        () async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      final container = createContainer(repo);

      final created = await container
          .read(createCircularProvider.notifier)
          .create(const Circular(title: '   '));

      expect(created, isNull);
      final state = container.read(createCircularProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<CircularValidationFailure>());
    });

    test('updateCircularProvider updates item and refreshes list and detail',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);

      final original =
          (await container.read(circularByIdProvider('c-2').future))!;

      final updated =
          await container.read(updateCircularProvider.notifier).updateCircular(
                original.copyWith(
                  workflowStatus: CircularWorkflowStatus.applied,
                  applicationStatus: ApplicationStatus.feePaid,
                ),
              );

      expect(updated?.workflowStatus, equals(CircularWorkflowStatus.applied));
      expect(
        container.read(updateCircularProvider).value?.applicationStatus,
        equals(ApplicationStatus.feePaid),
      );

      final refetchedDetail =
          await container.read(circularByIdProvider('c-2').future);
      expect(
        refetchedDetail?.workflowStatus,
        equals(CircularWorkflowStatus.applied),
      );

      final list = await container.read(circularsListProvider.future);
      expect(
        list.firstWhere((c) => c.id == 'c-2').workflowStatus,
        equals(CircularWorkflowStatus.applied),
      );
    });

    test('deleteCircularProvider removes item and clears caches', () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);

      await container.read(circularsListProvider.future);
      await container.read(circularByIdProvider('c-1').future);

      final deleted =
          await container.read(deleteCircularProvider.notifier).delete('c-1');

      expect(deleted, isTrue);
      expect(container.read(deleteCircularProvider).hasError, isFalse);

      final refreshedList = await container.read(circularsListProvider.future);
      expect(refreshedList.map((c) => c.id), isNot(contains('c-1')));

      final detail = await container.read(circularByIdProvider('c-1').future);
      expect(detail, isNull);
    });

    test('deleteCircularProvider captures repository errors cleanly', () async {
      final repo = FakeCircularRepository(clock: () => fixedNow)
        ..nextError = const CircularPermissionFailure(code: '42501');
      final container = createContainer(repo);

      final deleted =
          await container.read(deleteCircularProvider.notifier).delete('c-1');

      expect(deleted, isFalse);
      final state = container.read(deleteCircularProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<CircularPermissionFailure>());
    });

    test('refresh and reset clear and reload provider states cleanly',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);

      await container.read(circularsListProvider.future);
      expect(repo.getCircularsCalls, equals(1));

      await container.read(circularsListProvider.notifier).refresh();
      expect(repo.getCircularsCalls, equals(2));

      await container
          .read(createCircularProvider.notifier)
          .create(const Circular(title: 'Extra Circular'));
      expect(container.read(createCircularProvider).value, isNotNull);

      container.read(createCircularProvider.notifier).reset();
      expect(container.read(createCircularProvider).value, isNull);
    });
  });
}
