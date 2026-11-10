import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

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
      Circular(
        id: 'c-4',
        userId: 'user-1',
        title: 'Rolling Fellowship',
        sector: CircularSector.ngo,
        organizationName: 'BRAC',
        updatedAt: DateTime.utc(2026, 11, 10, 11), // no deadline -> none band
      ),
    ];
  }

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

  group('Circular Search, Filter, and Sort Providers', () {
    test('circularSearchQueryProvider searches across text fields and clears',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      // Organization name match
      container.read(circularSearchQueryProvider.notifier).setQuery('bangla');
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        containsAll(['c-1', 'c-2']),
      );

      // Syllabus match
      container
          .read(circularSearchQueryProvider.notifier)
          .setQuery('quantitative');
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-2']),
      );

      // Instructions match
      container
          .read(circularSearchQueryProvider.notifier)
          .setQuery('portfolio');
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-3']),
      );

      container.read(circularSearchQueryProvider.notifier).clear();
      expect(
        container.read(filteredCircularsProvider).requireValue.length,
        equals(4),
      );
    });

    test('circularFilterProvider filters by sector, statuses, band, and flags',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      // Sector
      container
          .read(circularFilterProvider.notifier)
          .toggleSector(CircularSector.bcs);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1']),
      );
      container
          .read(circularFilterProvider.notifier)
          .toggleSector(CircularSector.bcs);

      // Workflow status + priority + application status
      container
          .read(circularFilterProvider.notifier)
          .toggleWorkflowStatus(CircularWorkflowStatus.preparing);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1']),
      );
      container.read(circularFilterProvider.notifier)
        ..toggleWorkflowStatus(CircularWorkflowStatus.preparing)
        ..togglePriority(CircularPriority.high);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-2']),
      );
      container.read(circularFilterProvider.notifier)
        ..togglePriority(CircularPriority.high)
        ..toggleApplicationStatus(ApplicationStatus.exempt);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-3']),
      );
      container
          .read(circularFilterProvider.notifier)
          .toggleApplicationStatus(ApplicationStatus.exempt);

      // Deadline color bands (red, amber, green, none)
      container
          .read(circularFilterProvider.notifier)
          .setDeadlineBand(DeadlineColorBand.red);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1']),
      );
      container
          .read(circularFilterProvider.notifier)
          .setDeadlineBand(DeadlineColorBand.amber);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-2']),
      );
      container
          .read(circularFilterProvider.notifier)
          .setDeadlineBand(DeadlineColorBand.green);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-3']),
      );
      container
          .read(circularFilterProvider.notifier)
          .setDeadlineBand(DeadlineColorBand.none);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-4']),
      );
      container.read(circularFilterProvider.notifier).setDeadlineBand(null);

      // Quick capture & archive exclusion
      container
          .read(circularFilterProvider.notifier)
          .setOnlyQuickCapture(onlyQuickCapture: true);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-2']),
      );
      container.read(circularFilterProvider.notifier)
        ..setOnlyQuickCapture()
        ..setIncludeArchived(includeArchived: false);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1', 'c-2', 'c-4']),
      );
      expect(container.read(circularFilterProvider).hasActiveFilters, isTrue);

      container
          .read(circularFilterProvider.notifier)
          .setFilter(const CircularFilter());
      expect(container.read(circularFilterProvider).hasActiveFilters, isFalse);
      expect(
        container.read(filteredCircularsProvider).requireValue.length,
        equals(4),
      );
    });

    test('circularFilterProvider supports all sort orders with null deadlines',
        () async {
      final repo = FakeCircularRepository(
        initialItems: seedCirculars(),
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      final filterNotifier = container.read(circularFilterProvider.notifier);

      // Default: deadlineAsc puts no-deadline items last
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1', 'c-2', 'c-3', 'c-4']),
      );

      filterNotifier.setSortBy(CircularSortOption.updatedDesc);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-4', 'c-2', 'c-1', 'c-3']),
      );

      filterNotifier.setSortBy(CircularSortOption.priorityDesc);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1', 'c-2', 'c-3', 'c-4']),
      );

      filterNotifier.setSortBy(CircularSortOption.titleAsc);
      expect(
        container.read(filteredCircularsProvider).requireValue.map((c) => c.id),
        equals(['c-1', 'c-2', 'c-4', 'c-3']),
      );
    });
  });
}
