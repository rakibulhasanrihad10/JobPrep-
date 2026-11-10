import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';

/// Contract for persisting and querying job circulars.
abstract interface class CircularRepository {
  /// Fetches all circulars belonging to the current user, optionally filtered
  /// and sorted according to [filter].
  Future<List<Circular>> getCirculars({CircularFilter? filter});

  /// Fetches a single circular by [id], including its exam dates and files.
  ///
  /// Returns `null` when no accessible circular exists with [id].
  Future<Circular?> getCircularById(String id);

  /// Persists a new [circular] and returns the stored record with generated
  /// server metadata (`id`, `userId`, `createdAt`, `updatedAt`).
  Future<Circular> createCircular(Circular circular);

  /// Updates an existing [circular] and returns the updated server record.
  Future<Circular> updateCircular(Circular circular);

  /// Deletes the circular identified by [id] (cascading to child rows).
  Future<void> deleteCircular(String id);
}
