import 'package:job_prep/features/prep/domain/entities/revision_item.dart';

/// Contract for persisting and updating spaced revision marks
/// (`public.revision_items`).
abstract interface class RevisionItemRepository {
  /// Fetches all revision items owned by the authenticated user.
  Future<List<RevisionItem>> getRevisionItems();

  /// Creates and returns a single persisted [RevisionItem].
  Future<RevisionItem> createRevisionItem(RevisionItem item);

  /// Creates and returns multiple persisted [RevisionItem] records.
  Future<List<RevisionItem>> createRevisionItems(List<RevisionItem> items);

  /// Updates an existing [RevisionItem] (status, schedule, note, reason, etc.).
  Future<RevisionItem> updateRevisionItem(RevisionItem item);

  /// Permanently deletes a revision item identified by [id].
  Future<void> deleteRevisionItem(String id);
}
