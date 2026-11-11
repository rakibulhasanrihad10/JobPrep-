import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_mock_test_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/utils/mock_test_analytics.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_mutation_state.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Preset date range filters available on the Mock Tests tab.
enum MockDateFilterPreset {
  /// Show mock tests across all recorded dates.
  all,

  /// Restrict to tests taken within the last 7 days.
  last7Days,

  /// Restrict to tests taken within the last 30 days.
  last30Days,

  /// Restrict to tests taken within the last 90 days.
  last90Days,
}

/// Filter criteria for the Mock Tests list and chart preview.
@immutable
class MockTestFilterState {
  /// Creates a [MockTestFilterState].
  const MockTestFilterState({
    this.subjectId,
    this.datePreset = MockDateFilterPreset.all,
  });

  static const Object _unset = Object();

  /// Optional selected subject ID (`null` means all subjects).
  final String? subjectId;

  /// Selected date range preset.
  final MockDateFilterPreset datePreset;

  /// Returns a copy with specified fields overridden.
  MockTestFilterState copyWith({
    Object? subjectId = _unset,
    MockDateFilterPreset? datePreset,
  }) {
    return MockTestFilterState(
      subjectId:
          identical(subjectId, _unset) ? this.subjectId : subjectId as String?,
      datePreset: datePreset ?? this.datePreset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockTestFilterState &&
        other.subjectId == subjectId &&
        other.datePreset == datePreset;
  }

  @override
  int get hashCode => Object.hash(subjectId, datePreset);
}

/// Dependency-injected [MockTestRepository] provider.
final Provider<MockTestRepository> mockTestRepositoryProvider =
    Provider<MockTestRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredMockTestRepository();
  }
  return SupabaseMockTestRepository(client);
});

/// Async notifier loading all logged mock tests for the signed-in user.
class MockTestsNotifier extends AsyncNotifier<List<MockTest>> {
  @override
  Future<List<MockTest>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(mockTestRepositoryProvider).getTests();
  }

  /// Reloads mock tests from [MockTestRepository].
  Future<List<MockTest>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

/// Provides all logged mock tests for the signed-in user.
final AsyncNotifierProvider<MockTestsNotifier, List<MockTest>>
    mockTestsProvider =
    AsyncNotifierProvider<MockTestsNotifier, List<MockTest>>(
  MockTestsNotifier.new,
  retry: _noRetry,
);

/// Manages subject and date range filters on the Mock Tests tab.
class MockTestFilterNotifier extends Notifier<MockTestFilterState> {
  @override
  MockTestFilterState build() => const MockTestFilterState();

  /// Filters tests to `subjectId`, or clears subject filter when `null`.
  void setSubject(String? subjectId) {
    final clean = subjectId?.trim();
    state = state.copyWith(
      subjectId: (clean == null || clean.isEmpty) ? null : clean,
    );
  }

  /// Selects a preset date range window.
  void setDatePreset(MockDateFilterPreset preset) {
    state = state.copyWith(datePreset: preset);
  }

  /// Resets all active mock test filters.
  void clear() {
    state = const MockTestFilterState();
  }
}

/// Provides active filter criteria for the Mock Tests tab.
final NotifierProvider<MockTestFilterNotifier, MockTestFilterState>
    mockTestFilterProvider =
    NotifierProvider<MockTestFilterNotifier, MockTestFilterState>(
  MockTestFilterNotifier.new,
);

/// Derives filtered mock tests sorted newest first according to
/// [mockTestFilterProvider].
final Provider<AsyncValue<List<MockTest>>> filteredMockTestsProvider =
    Provider<AsyncValue<List<MockTest>>>((ref) {
  final testsAsync = ref.watch(mockTestsProvider);
  final filter = ref.watch(mockTestFilterProvider);
  final now = ref.watch(prepNowProvider)();
  final today = DateTime.utc(now.year, now.month, now.day);

  final startDate = switch (filter.datePreset) {
    MockDateFilterPreset.all => null,
    MockDateFilterPreset.last7Days => today.subtract(const Duration(days: 7)),
    MockDateFilterPreset.last30Days => today.subtract(const Duration(days: 30)),
    MockDateFilterPreset.last90Days => today.subtract(const Duration(days: 90)),
  };

  return testsAsync.whenData(
    (tests) => MockTestAnalytics.filterMockTests(
      tests,
      subjectId: filter.subjectId,
      startDate: startDate,
      endDate: startDate != null ? today : null,
    ),
  );
});

/// Summarizes filtered mock tests currently shown on the Mock Tests tab.
final Provider<MockTestSummary> filteredMockTestSummaryProvider =
    Provider<MockTestSummary>((ref) {
  final filtered =
      ref.watch(filteredMockTestsProvider).asData?.value ?? const <MockTest>[];
  return MockTestAnalytics.summarizeTests(filtered);
});

/// Filters mock tests belonging to `subjectId` cleanly.
final ProviderFamily<AsyncValue<List<MockTest>>, String>
    subjectMockTestsProvider =
    Provider.family<AsyncValue<List<MockTest>>, String>((ref, subjectId) {
  final testsAsync = ref.watch(mockTestsProvider);
  return testsAsync.whenData(
    (tests) => MockTestAnalytics.filterMockTests(tests, subjectId: subjectId),
  );
});

/// Computes [MockTestSummary] (latest, best, average, improvement, trend
/// points) for a single `subjectId`.
final ProviderFamily<MockTestSummary, String> subjectMockTestSummaryProvider =
    Provider.family<MockTestSummary, String>((ref, subjectId) {
  final tests =
      ref.watch(mockTestsProvider).asData?.value ?? const <MockTest>[];
  return MockTestAnalytics.summarizeTests(tests, subjectId: subjectId);
});

/// Controller handling create, update, and delete mutations for [MockTest]s.
class MockTestController extends Notifier<PrepMutationState> {
  @override
  PrepMutationState build() => const PrepMutationState();

  /// Clears any previously surfaced mutation error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Creates or updates [test] cleanly and refreshes mock test providers.
  Future<MockTest?> saveTest(MockTest test) async {
    state = state.copyWith(isSubmitting: true, activeId: test.id, error: null);
    try {
      final repo = ref.read(mockTestRepositoryProvider);
      final saved = test.id.trim().isEmpty
          ? await repo.createTest(test)
          : await repo.updateTest(test);
      await ref.read(mockTestsProvider.notifier).refresh();
      state = state.copyWith(isSubmitting: false, activeId: null);
      return saved;
    } on Object catch (error) {
      state = state.copyWith(isSubmitting: false, activeId: null, error: error);
      return null;
    }
  }

  /// Deletes the mock test identified by [id] cleanly.
  Future<bool> deleteTest(String id) async {
    state = state.copyWith(isSubmitting: true, activeId: id, error: null);
    try {
      await ref.read(mockTestRepositoryProvider).deleteTest(id);
      await ref.read(mockTestsProvider.notifier).refresh();
      state = state.copyWith(isSubmitting: false, activeId: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(isSubmitting: false, activeId: null, error: error);
      return false;
    }
  }
}

/// Provides [MockTestController] for mock test mutations.
final NotifierProvider<MockTestController, PrepMutationState>
    mockTestControllerProvider =
    NotifierProvider<MockTestController, PrepMutationState>(
  MockTestController.new,
);
