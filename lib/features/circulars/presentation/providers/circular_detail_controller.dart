import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_mutation_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

const Object _unset = Object();

/// Immutable mutation state for circular detail quick actions, checklist
/// toggles, and delete confirmation.
@immutable
class CircularDetailActionState {
  /// Creates a [CircularDetailActionState].
  const CircularDetailActionState({
    this.isUpdating = false,
    this.isDeleting = false,
    this.actionFailure,
  });

  /// Whether a status or checklist mutation is currently running.
  final bool isUpdating;

  /// Whether deletion of the active circular is running.
  final bool isDeleting;

  /// Latest failure surfaced on a detail action, if any.
  final CircularFailure? actionFailure;

  /// Returns an updated copy of this [CircularDetailActionState].
  CircularDetailActionState copyWith({
    bool? isUpdating,
    bool? isDeleting,
    Object? actionFailure = _unset,
  }) {
    return CircularDetailActionState(
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      actionFailure: identical(actionFailure, _unset)
          ? this.actionFailure
          : actionFailure as CircularFailure?,
    );
  }
}

/// Resolves the freshest available `Circular` for `id`, preferring the live
/// [circularsListProvider] cache (for instant master-detail sync) and falling
/// back to [circularByIdProvider].
final ProviderFamily<AsyncValue<Circular?>, String> circularDetailProvider =
    Provider.family<AsyncValue<Circular?>, String>((ref, id) {
  final listAsync = ref.watch(circularsListProvider);
  final listItems = listAsync.asData?.value;
  if (listItems != null) {
    for (final item in listItems) {
      if (item.id == id) {
        return AsyncData<Circular?>(item);
      }
    }
  }
  return ref.watch(circularByIdProvider(id));
});

/// Controller handling quick status updates, checklist toggles, and deletion
/// from the circular detail screen/pane.
class CircularDetailController extends Notifier<CircularDetailActionState> {
  @override
  CircularDetailActionState build() => const CircularDetailActionState();

  /// Updates workflow status immediately.
  Future<Circular?> updateWorkflowStatus(
    Circular circular,
    CircularWorkflowStatus status,
  ) {
    if (circular.workflowStatus == status) {
      return Future<Circular?>.value(circular);
    }
    return _persistCircularUpdate(circular.copyWith(workflowStatus: status));
  }

  /// Updates application progression status immediately.
  Future<Circular?> updateApplicationStatus(
    Circular circular,
    ApplicationStatus status,
  ) {
    if (circular.applicationStatus == status) {
      return Future<Circular?>.value(circular);
    }
    return _persistCircularUpdate(circular.copyWith(applicationStatus: status));
  }

  /// Updates admit card status immediately.
  Future<Circular?> updateAdmitCardStatus(
    Circular circular,
    AdmitCardStatus status,
  ) {
    if (circular.admitCardStatus == status) {
      return Future<Circular?>.value(circular);
    }
    return _persistCircularUpdate(circular.copyWith(admitCardStatus: status));
  }

  /// Toggles an [ApplicationChecklistItem] checkbox and persists it.
  Future<Circular?> toggleChecklistItem(
    Circular circular,
    ApplicationChecklistItem item,
  ) {
    return _persistCircularUpdate(
      circular.copyWith(checklist: circular.checklist.toggle(item)),
    );
  }

  /// Permanently deletes [circular] and refreshes circular caches.
  Future<bool> deleteCircular(Circular circular) async {
    if (state.isDeleting || state.isUpdating) return false;
    state = state.copyWith(isDeleting: true, actionFailure: null);

    final ok =
        await ref.read(deleteCircularProvider.notifier).delete(circular.id);
    if (!ref.mounted) return ok;

    if (ok) {
      state = state.copyWith(isDeleting: false, actionFailure: null);
      return true;
    }

    final mutationError = ref.read(deleteCircularProvider).error;
    state = state.copyWith(
      isDeleting: false,
      actionFailure: mutationError is CircularFailure
          ? mutationError
          : const UnknownCircularFailure(),
    );
    return false;
  }

  /// Dismisses any visible detail action error banner.
  void clearError() {
    if (state.actionFailure != null) {
      state = state.copyWith(actionFailure: null);
    }
  }

  Future<Circular?> _persistCircularUpdate(Circular next) async {
    if (state.isUpdating || state.isDeleting) return null;
    state = state.copyWith(isUpdating: true, actionFailure: null);

    final updated =
        await ref.read(updateCircularProvider.notifier).updateCircular(next);
    if (!ref.mounted) return updated;

    if (updated != null) {
      state = state.copyWith(isUpdating: false, actionFailure: null);
      return updated;
    }

    final mutationError = ref.read(updateCircularProvider).error;
    state = state.copyWith(
      isUpdating: false,
      actionFailure: mutationError is CircularFailure
          ? mutationError
          : const UnknownCircularFailure(),
    );
    return null;
  }
}

/// Provides reactive quick-action mutations for circular details.
final NotifierProvider<CircularDetailController, CircularDetailActionState>
    circularDetailControllerProvider = NotifierProvider.autoDispose<
        CircularDetailController, CircularDetailActionState>(
  CircularDetailController.new,
);
