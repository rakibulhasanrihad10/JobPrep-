import 'package:flutter/foundation.dart' show immutable, setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_mutation_providers.dart';

const Object _unset = Object();

/// Immutable state tracking per-item in-flight mutations and errors on Inbox.
@immutable
class InboxActionState {
  /// Creates an [InboxActionState].
  const InboxActionState({
    this.busyIds = const {},
    this.lastFailure,
  });

  /// Circular IDs currently undergoing a skip or delete operation.
  final Set<String> busyIds;

  /// Latest failure encountered during an Inbox action, if any.
  final CircularFailure? lastFailure;

  /// Whether [circularId] is currently locked for an active operation.
  bool isBusy(String circularId) => busyIds.contains(circularId);

  /// Returns an updated copy of this [InboxActionState].
  InboxActionState copyWith({
    Set<String>? busyIds,
    Object? lastFailure = _unset,
  }) {
    return InboxActionState(
      busyIds: busyIds != null ? Set.unmodifiable(busyIds) : this.busyIds,
      lastFailure: identical(lastFailure, _unset)
          ? this.lastFailure
          : lastFailure as CircularFailure?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InboxActionState &&
        setEquals(other.busyIds, busyIds) &&
        other.lastFailure == lastFailure;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAllUnordered(busyIds), lastFailure);
}

/// Controller encapsulating Inbox triage mutations (`Skip` and `Delete`).
class InboxController extends Notifier<InboxActionState> {
  @override
  InboxActionState build() => const InboxActionState();

  /// Archives [circular] out of Inbox while retaining its URL in history for
  /// future duplicate link detection.
  Future<bool> skip(Circular circular) async {
    if (circular.id.isEmpty || state.isBusy(circular.id)) return false;

    _markBusy(circular.id);
    final updated = await ref
        .read(updateCircularProvider.notifier)
        .updateCircular(
          circular.copyWith(workflowStatus: CircularWorkflowStatus.archived),
        );

    if (!ref.mounted) return updated != null;
    if (updated != null) {
      _clearBusy(circular.id);
      return true;
    }

    final mutationError = ref.read(updateCircularProvider).error;
    _clearBusy(
      circular.id,
      failure: mutationError is CircularFailure
          ? mutationError
          : const UnknownCircularFailure(),
    );
    return false;
  }

  /// Permanently removes [circular] from storage.
  Future<bool> delete(Circular circular) async {
    if (circular.id.isEmpty || state.isBusy(circular.id)) return false;

    _markBusy(circular.id);
    final deleted =
        await ref.read(deleteCircularProvider.notifier).delete(circular.id);

    if (!ref.mounted) return deleted;
    if (deleted) {
      _clearBusy(circular.id);
      return true;
    }

    final mutationError = ref.read(deleteCircularProvider).error;
    _clearBusy(
      circular.id,
      failure: mutationError is CircularFailure
          ? mutationError
          : const UnknownCircularFailure(),
    );
    return false;
  }

  /// Clears any displayed failure banner.
  void clearError() {
    if (state.lastFailure != null) {
      state = state.copyWith(lastFailure: null);
    }
  }

  void _markBusy(String id) {
    final next = Set<String>.from(state.busyIds)..add(id);
    state = state.copyWith(busyIds: next, lastFailure: null);
  }

  void _clearBusy(String id, {CircularFailure? failure}) {
    final next = Set<String>.from(state.busyIds)..remove(id);
    state = state.copyWith(busyIds: next, lastFailure: failure);
  }
}

/// Provides Inbox triage actions (`Skip` and `Delete`) and per-item busy state.
final NotifierProvider<InboxController, InboxActionState>
    inboxControllerProvider =
    NotifierProvider.autoDispose<InboxController, InboxActionState>(
  InboxController.new,
);
