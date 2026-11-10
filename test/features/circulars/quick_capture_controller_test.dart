import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/inbox_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/quick_capture_controller.dart';

import 'fake_circular_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  ProviderContainer createContainer(FakeCircularRepository repo) {
    final container = ProviderContainer(
      overrides: [
        circularRepositoryProvider.overrideWithValue(repo),
        circularNowProvider.overrideWithValue(() => fixedNow),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('QuickCaptureController', () {
    test('saves circular with only a link using inbox status and quick flag',
        () async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      final provider = quickCaptureControllerProvider(null);
      final sub = container.listen(provider, (_, __) {});
      addTearDown(sub.close);

      // Submitting blank link fails validation without touching repository.
      expect(await container.read(provider.notifier).submit(), isNull);
      expect(
        container.read(provider).linkError,
        equals(QuickCaptureLinkValidationError.required),
      );
      expect(repo.createdItems, isEmpty);

      // Entering only a link saves cleanly with fallback hostname title.
      container
          .read(provider.notifier)
          .updateLink('https://www.bpsc.gov.bd/notices/47');
      expect(container.read(provider).linkError, isNull);

      final saved = await container.read(provider.notifier).submit();
      expect(saved, isNotNull);
      expect(saved!.title, equals('bpsc.gov.bd'));
      expect(saved.circularUrl, equals('https://www.bpsc.gov.bd/notices/47'));
      expect(saved.workflowStatus, equals(CircularWorkflowStatus.inbox));
      expect(saved.isQuickCapture, isTrue);
      expect(saved.deadline, isNull);
      expect(repo.createdItems, hasLength(1));

      await container.read(circularsListProvider.future);
      expect(container.read(inboxCountProvider), equals(1));
      expect(
        container.read(inboxCircularsProvider).requireValue.single.id,
        equals(saved.id),
      );
    });

    test('saves optional title and deadline alongside duplicate link check',
        () async {
      final repo = FakeCircularRepository(
        initialItems: const [
          Circular(
            id: 'existing-1',
            title: '47th BCS Preliminary',
            circularUrl: 'https://bpsc.gov.bd/notices/47',
          ),
        ],
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      final provider = quickCaptureControllerProvider(
        'https://BPSC.GOV.BD/notices/47/#top',
      );
      final sub = container.listen(provider, (_, __) {});
      addTearDown(sub.close);

      // Prefilled initialUrl detects Phase 3D normalized duplicate immediately.
      expect(
        container.read(provider).duplicateCircular?.id,
        equals('existing-1'),
      );

      final deadline = DateTime.utc(2026, 11, 28);
      container.read(provider.notifier)
        ..updateLink('https://bb.org.bd/career/ad')
        ..updateTitle('Bangladesh Bank AD')
        ..updateDeadline(deadline);

      expect(container.read(provider).duplicateCircular, isNull);

      final saved = await container.read(provider.notifier).submit();
      expect(saved, isNotNull);
      expect(saved!.title, equals('Bangladesh Bank AD'));
      expect(saved.circularUrl, equals('https://bb.org.bd/career/ad'));
      expect(saved.deadline, equals(deadline));
      expect(saved.workflowStatus, equals(CircularWorkflowStatus.inbox));
      expect(saved.isQuickCapture, isTrue);
    });

    test('surfaces repository failures cleanly without crashing', () async {
      final repo = FakeCircularRepository(clock: () => fixedNow);
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      final provider = quickCaptureControllerProvider(null);
      final sub = container.listen(provider, (_, __) {});
      addTearDown(sub.close);

      repo.nextError = const CircularNetworkFailure();
      container
          .read(provider.notifier)
          .updateLink('https://example.com/circular');

      final saved = await container.read(provider.notifier).submit();
      expect(saved, isNull);
      expect(
        container.read(provider).submitFailure,
        isA<CircularNetworkFailure>(),
      );
      expect(container.read(provider).isSubmitting, isFalse);
    });
  });

  group('InboxController & Providers', () {
    test('skip archives item out of Inbox and delete removes it permanently',
        () async {
      final repo = FakeCircularRepository(
        initialItems: [
          Circular(
            id: 'in-1',
            userId: 'u-1',
            title: 'bpsc.gov.bd',
            circularUrl: 'https://bpsc.gov.bd/47',
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
            createdAt: DateTime.utc(2026, 11, 10, 9),
          ),
          Circular(
            id: 'in-2',
            userId: 'u-1',
            title: 'bb.org.bd',
            circularUrl: 'https://bb.org.bd/ad',
            workflowStatus: CircularWorkflowStatus.inbox,
            isQuickCapture: true,
            createdAt: DateTime.utc(2026, 11, 10, 11),
          ),
          const Circular(
            id: 'saved-1',
            userId: 'u-1',
            title: 'Already Active',
          ),
        ],
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      expect(container.read(inboxCountProvider), equals(2));
      expect(
        container
            .read(inboxCircularsProvider)
            .requireValue
            .map((c) => c.id)
            .toList(),
        equals(['in-2', 'in-1']),
      );

      // Skip in-2 -> moves to archived, leaves Inbox, keeps URL in repo.
      final skipped = await container
          .read(inboxControllerProvider.notifier)
          .skip(repo.items.firstWhere((c) => c.id == 'in-2'));
      expect(skipped, isTrue);

      await container.read(circularsListProvider.future);
      expect(container.read(inboxCountProvider), equals(1));
      expect(
        repo.items.firstWhere((c) => c.id == 'in-2').workflowStatus,
        equals(CircularWorkflowStatus.archived),
      );

      // Delete in-1 -> removes permanently from repo & Inbox.
      final deleted = await container
          .read(inboxControllerProvider.notifier)
          .delete(repo.items.firstWhere((c) => c.id == 'in-1'));
      expect(deleted, isTrue);

      await container.read(circularsListProvider.future);
      expect(container.read(inboxCountProvider), equals(0));
      expect(repo.deletedIds, equals(['in-1']));
      expect(repo.items.any((c) => c.id == 'in-1'), isFalse);
    });
  });
}
