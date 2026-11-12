import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';

/// Fallback [RevisionItemRepository] used before Supabase configuration is
/// provided.
class UnconfiguredRevisionItemRepository implements RevisionItemRepository {
  /// Creates an [UnconfiguredRevisionItemRepository].
  const UnconfiguredRevisionItemRepository();

  static const _failure = UnknownPrepFailure(
    code: 'prep_unconfigured',
    message: 'Revision queue storage is not configured.',
  );

  @override
  Future<List<RevisionItem>> getRevisionItems() async => const <RevisionItem>[];

  @override
  Future<RevisionItem> createRevisionItem(RevisionItem item) =>
      Future<RevisionItem>.error(_failure);

  @override
  Future<List<RevisionItem>> createRevisionItems(List<RevisionItem> items) =>
      Future<List<RevisionItem>>.error(_failure);

  @override
  Future<RevisionItem> updateRevisionItem(RevisionItem item) =>
      Future<RevisionItem>.error(_failure);

  @override
  Future<void> deleteRevisionItem(String id) => Future<void>.error(_failure);
}
