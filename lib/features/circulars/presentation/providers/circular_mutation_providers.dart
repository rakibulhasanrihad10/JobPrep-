import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

/// Notifier handling circular creation and list/detail cache invalidation.
class CreateCircularNotifier extends Notifier<AsyncValue<Circular?>> {
  @override
  AsyncValue<Circular?> build() => const AsyncData<Circular?>(null);

  /// Creates [circular] via `CircularRepository` and refreshes circular state.
  ///
  /// Returns the persisted [Circular] on success, or `null` on failure while
  /// recording the typed [CircularFailure] in state.
  Future<Circular?> create(Circular circular) async {
    state = const AsyncLoading<Circular?>();
    try {
      final created =
          await ref.read(circularRepositoryProvider).createCircular(circular);
      if (!ref.mounted) return created;
      state = AsyncData<Circular?>(created);
      ref
        ..invalidate(circularsListProvider)
        ..invalidate(circularByIdProvider(created.id));
      return created;
    } on CircularFailure catch (failure, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<Circular?>(failure, stackTrace);
      }
      return null;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<Circular?>(
          UnknownCircularFailure(message: error.toString()),
          stackTrace,
        );
      }
      return null;
    }
  }

  /// Clears any previous creation result or error.
  void reset() {
    state = const AsyncData<Circular?>(null);
  }
}

/// Provides async status and action trigger for creating a circular.
final createCircularProvider =
    NotifierProvider<CreateCircularNotifier, AsyncValue<Circular?>>(
  CreateCircularNotifier.new,
);

/// Notifier handling circular updates and list/detail cache invalidation.
class UpdateCircularNotifier extends Notifier<AsyncValue<Circular?>> {
  @override
  AsyncValue<Circular?> build() => const AsyncData<Circular?>(null);

  /// Updates [circular] via `CircularRepository` and refreshes circular state.
  ///
  /// Returns the updated [Circular] on success, or `null` on failure while
  /// recording the typed [CircularFailure] in state.
  Future<Circular?> updateCircular(Circular circular) async {
    state = const AsyncLoading<Circular?>();
    try {
      final updated =
          await ref.read(circularRepositoryProvider).updateCircular(circular);
      if (!ref.mounted) return updated;
      state = AsyncData<Circular?>(updated);
      ref
        ..invalidate(circularsListProvider)
        ..invalidate(circularByIdProvider(updated.id));
      return updated;
    } on CircularFailure catch (failure, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<Circular?>(failure, stackTrace);
      }
      return null;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<Circular?>(
          UnknownCircularFailure(message: error.toString()),
          stackTrace,
        );
      }
      return null;
    }
  }

  /// Clears any previous update result or error.
  void reset() {
    state = const AsyncData<Circular?>(null);
  }
}

/// Provides async status and action trigger for updating a circular.
final updateCircularProvider =
    NotifierProvider<UpdateCircularNotifier, AsyncValue<Circular?>>(
  UpdateCircularNotifier.new,
);

/// Notifier handling circular deletion and list/detail cache invalidation.
class DeleteCircularNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  /// Deletes circular [id] via `CircularRepository` and invalidates caches.
  ///
  /// Returns `true` when deletion succeeded, or `false` on failure while
  /// recording the typed [CircularFailure] in state.
  Future<bool> delete(String id) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(circularRepositoryProvider).deleteCircular(id);
      if (!ref.mounted) return true;
      state = const AsyncData<void>(null);
      ref
        ..invalidate(circularsListProvider)
        ..invalidate(circularByIdProvider(id));
      return true;
    } on CircularFailure catch (failure, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(failure, stackTrace);
      }
      return false;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError<void>(
          UnknownCircularFailure(message: error.toString()),
          stackTrace,
        );
      }
      return false;
    }
  }

  /// Clears any previous deletion error state.
  void reset() {
    state = const AsyncData<void>(null);
  }
}

/// Provides async status and action trigger for deleting a circular.
final deleteCircularProvider =
    NotifierProvider<DeleteCircularNotifier, AsyncValue<void>>(
  DeleteCircularNotifier.new,
);
