import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_revision_item_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_revision_item_repository.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_state.dart';

export 'revision_controller.dart';
export 'revision_state.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [RevisionItemRepository] provider.
final Provider<RevisionItemRepository> revisionItemRepositoryProvider =
    Provider<RevisionItemRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredRevisionItemRepository();
  }
  return SupabaseRevisionItemRepository(client);
});

/// Injectable clock callback defaulting to [prepNowProvider].
final Provider<DateTime Function()> revisionNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(prepNowProvider));

/// Async notifier loading all [RevisionItem] records for the active user.
class RevisionItemsNotifier extends AsyncNotifier<List<RevisionItem>> {
  @override
  Future<List<RevisionItem>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(revisionItemRepositoryProvider).getRevisionItems();
  }

  /// Reloads revision marks from [RevisionItemRepository].
  Future<List<RevisionItem>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

/// Provides persisted revision marks for the active user.
final AsyncNotifierProvider<RevisionItemsNotifier, List<RevisionItem>>
    revisionItemsProvider =
    AsyncNotifierProvider<RevisionItemsNotifier, List<RevisionItem>>(
  RevisionItemsNotifier.new,
  retry: _noRetry,
);

/// Selected active tab in the Revision Queue view.
class RevisionQueueTabNotifier extends Notifier<RevisionQueueTab> {
  @override
  RevisionQueueTab build() => RevisionQueueTab.dueToday;

  /// Switches the active revision queue tab.
  void selectTab(RevisionQueueTab tab) {
    if (state != tab) {
      state = tab;
    }
  }
}

/// Provides currently selected [RevisionQueueTab].
final NotifierProvider<RevisionQueueTabNotifier, RevisionQueueTab>
    revisionQueueTabProvider =
    NotifierProvider<RevisionQueueTabNotifier, RevisionQueueTab>(
  RevisionQueueTabNotifier.new,
);

/// Subject and material filters applied on the Revision Queue view.
class RevisionFilterNotifier extends Notifier<RevisionFilterState> {
  @override
  RevisionFilterState build() => const RevisionFilterState();

  /// Selects or clears the subject filter (clears material when subject moves).
  void setSubject(String? subjectId) {
    final clean = subjectId?.trim();
    final nextSubject = (clean == null || clean.isEmpty) ? null : clean;
    if (state.subjectId == nextSubject) return;
    state = RevisionFilterState(subjectId: nextSubject);
  }

  /// Selects or clears the material filter cleanly.
  void setMaterial(String? materialId) {
    final clean = materialId?.trim();
    final nextMaterial = (clean == null || clean.isEmpty) ? null : clean;
    if (state.materialId == nextMaterial) return;
    state = state.copyWith(materialId: nextMaterial);
  }

  /// Resets both subject and material filters.
  void clear() {
    if (state.hasActiveFilters) {
      state = const RevisionFilterState();
    }
  }
}

/// Provides subject/material filters for the Revision Queue screen.
final NotifierProvider<RevisionFilterNotifier, RevisionFilterState>
    revisionFilterProvider =
    NotifierProvider<RevisionFilterNotifier, RevisionFilterState>(
  RevisionFilterNotifier.new,
);

/// Queue counts across Due today, Overdue, Upcoming, and Done honoring active
/// subject/material filters.
final Provider<RevisionTabCounts> revisionTabCountsProvider =
    Provider<RevisionTabCounts>((ref) {
  final items =
      ref.watch(revisionItemsProvider).asData?.value ?? const <RevisionItem>[];
  final filter = ref.watch(revisionFilterProvider);
  final today = ref.watch(revisionNowProvider)();
  return RevisionScheduler.countTabs(
    items,
    today: today,
    subjectId: filter.subjectId,
    materialId: filter.materialId,
  );
});

/// Filtered list matching the active queue tab, subject, and material filters.
final Provider<AsyncValue<List<RevisionItem>>> filteredRevisionItemsProvider =
    Provider<AsyncValue<List<RevisionItem>>>((ref) {
  final itemsAsync = ref.watch(revisionItemsProvider);
  final tab = ref.watch(revisionQueueTabProvider);
  final filter = ref.watch(revisionFilterProvider);
  final today = ref.watch(revisionNowProvider)();

  return itemsAsync.whenData(
    (items) => RevisionScheduler.filterItems(
      items,
      today: today,
      tab: tab,
      subjectId: filter.subjectId,
      materialId: filter.materialId,
    ),
  );
});

/// Active (non-done) revision marks matching a specific material ID, used by
/// `BookProgressDialog` to display flag pins at flagged pages.
final ProviderFamily<List<RevisionItem>, String>
    revisionItemsForMaterialProvider =
    Provider.family<List<RevisionItem>, String>((ref, materialId) {
  final items =
      ref.watch(revisionItemsProvider).asData?.value ?? const <RevisionItem>[];
  return List<RevisionItem>.unmodifiable(
    items.where(
      (item) => item.materialId == materialId && item.isActive,
    ),
  );
});
