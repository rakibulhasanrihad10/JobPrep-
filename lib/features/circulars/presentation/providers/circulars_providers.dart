import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_circular_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';

/// Dependency-injected [CircularRepository] provider.
///
/// Override this provider in tests with a fake [CircularRepository].
final circularRepositoryProvider = Provider<CircularRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredCircularRepository();
  }
  return SupabaseCircularRepository(client);
});

/// Clock callback used for deadline countdown filtering so tests can inject a
/// deterministic reference timestamp.
final circularNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

/// Async notifier loading and refreshing all circulars for the signed-in user.
class CircularsListNotifier extends AsyncNotifier<List<Circular>> {
  @override
  Future<List<Circular>> build() {
    // Re-fetch automatically when the authenticated user changes.
    ref.watch(currentUserProvider.select((user) => user?.id));
    final repository = ref.watch(circularRepositoryProvider);
    return repository.getCirculars();
  }

  /// Forces a reload from [CircularRepository].
  Future<List<Circular>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

Duration? _noRetry(int retryCount, Object error) => null;

/// Provides the full list of circulars for the active user.
final circularsListProvider =
    AsyncNotifierProvider<CircularsListNotifier, List<Circular>>(
  CircularsListNotifier.new,
  retry: _noRetry,
);

/// Fetches a single [Circular] by its identifier, including nested exam dates
/// and attached file metadata.
final FutureProviderFamily<Circular?, String> circularByIdProvider =
    FutureProvider.family<Circular?, String>(
  (ref, id) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    if (id.trim().isEmpty) return Future<Circular?>.value();
    final repository = ref.watch(circularRepositoryProvider);
    return repository.getCircularById(id);
  },
  retry: _noRetry,
);

/// Notifier holding the active circular search query text.
class CircularSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Updates the active search query.
  void setQuery(String query) {
    if (state == query) return;
    state = query;
  }

  /// Clears the search query back to empty.
  void clear() {
    state = '';
  }
}

/// Provides the current circular search query string.
final circularSearchQueryProvider =
    NotifierProvider<CircularSearchQueryNotifier, String>(
  CircularSearchQueryNotifier.new,
);

/// Notifier managing structured circular filters and sort ordering.
class CircularFilterNotifier extends Notifier<CircularFilter> {
  @override
  CircularFilter build() => const CircularFilter();

  /// Toggles membership of [sector] in the active sector filter set.
  void toggleSector(CircularSector sector) {
    state = state.copyWith(sectors: _toggleInSet(state.sectors, sector));
  }

  /// Toggles membership of [status] in the active workflow status filter set.
  void toggleWorkflowStatus(CircularWorkflowStatus status) {
    state = state.copyWith(
      workflowStatuses: _toggleInSet(state.workflowStatuses, status),
    );
  }

  /// Toggles membership of [status] in the active application status set.
  void toggleApplicationStatus(ApplicationStatus status) {
    state = state.copyWith(
      applicationStatuses: _toggleInSet(state.applicationStatuses, status),
    );
  }

  /// Toggles membership of [priority] in the active priority filter set.
  void togglePriority(CircularPriority priority) {
    state = state.copyWith(
      priorities: _toggleInSet(state.priorities, priority),
    );
  }

  /// Filters circulars by deadline urgency [band], or clears when `null`.
  void setDeadlineBand(DeadlineColorBand? band) {
    state = state.copyWith(deadlineBand: band);
  }

  /// Sets an inclusive calendar date range (`from`..`to`) for deadlines.
  void setDeadlineRange({DateTime? from, DateTime? to}) {
    state = state.copyWith(deadlineFrom: from, deadlineTo: to);
  }

  /// Filters by quick-capture status when non-null, or clears when `null`.
  void setOnlyQuickCapture({bool? onlyQuickCapture}) {
    state = state.copyWith(onlyQuickCapture: onlyQuickCapture);
  }

  /// Controls whether archived circulars appear when not explicitly selected.
  void setIncludeArchived({required bool includeArchived}) {
    state = state.copyWith(includeArchived: includeArchived);
  }

  /// Updates the active circular sort order.
  void setSortBy(CircularSortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Replaces the entire [CircularFilter] state.
  void setFilter(CircularFilter filter) {
    if (state == filter) return;
    state = filter;
  }

  /// Resets all structured filters back to defaults.
  void reset() {
    state = const CircularFilter();
  }

  static Set<T> _toggleInSet<T>(Set<T> current, T item) {
    final next = Set<T>.from(current);
    if (!next.add(item)) {
      next.remove(item);
    }
    return Set<T>.unmodifiable(next);
  }
}

/// Provides the current structured [CircularFilter].
final circularFilterProvider =
    NotifierProvider<CircularFilterNotifier, CircularFilter>(
  CircularFilterNotifier.new,
);

/// Combines [circularFilterProvider] and [circularSearchQueryProvider] into a
/// single effective [CircularFilter].
final effectiveCircularFilterProvider = Provider<CircularFilter>((ref) {
  final filter = ref.watch(circularFilterProvider);
  final query = ref.watch(circularSearchQueryProvider);
  if (query.isEmpty) return filter;
  return filter.copyWith(searchQuery: query);
});

/// Provides the reactively searched, filtered, and sorted circular list.
final filteredCircularsProvider = Provider<AsyncValue<List<Circular>>>((ref) {
  final circularsAsync = ref.watch(circularsListProvider);
  final filter = ref.watch(effectiveCircularFilterProvider);
  final now = ref.watch(circularNowProvider)();
  return circularsAsync.whenData(
    (circulars) => filter.apply(circulars, now: now),
  );
});

/// Provides quick-captured circulars waiting in the Inbox, sorted newest
/// captured first.
final inboxCircularsProvider = Provider<AsyncValue<List<Circular>>>((ref) {
  final circularsAsync = ref.watch(circularsListProvider);
  return circularsAsync.whenData(
    (circulars) => const CircularFilter(
      workflowStatuses: {CircularWorkflowStatus.inbox},
      sortBy: CircularSortOption.createdDesc,
    ).apply(circulars),
  );
});

/// Live count of quick-captured circulars currently waiting in the Inbox.
final inboxCountProvider = Provider<int>((ref) {
  return ref.watch(inboxCircularsProvider).asData?.value.length ?? 0;
});
