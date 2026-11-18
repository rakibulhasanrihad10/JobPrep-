import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [RevisionItemRepository].
class LocalRevisionItemRepository implements RevisionItemRepository {
  /// Creates a [LocalRevisionItemRepository].
  const LocalRevisionItemRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<RevisionItem>> getRevisionItems() async {
    final query = _db.select(_db.localRevisionItems)
      ..orderBy([
        (t) => OrderingTerm.asc(t.dueOn),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<RevisionItem> createRevisionItem(RevisionItem item) async {
    _validateForWrite(item);

    final id = item.id.trim().isEmpty ? const Uuid().v4() : item.id.trim();
    final now = DateTime.now().toUtc();
    final entry = _toCompanion(item, id: id, now: now);

    await _db.into(_db.localRevisionItems).insertOnConflictUpdate(entry);
    return item.copyWith(
      id: id,
      createdAt: item.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<List<RevisionItem>> createRevisionItems(
    List<RevisionItem> items,
  ) async {
    if (items.isEmpty) return const <RevisionItem>[];
    items.forEach(_validateForWrite);

    final now = DateTime.now().toUtc();
    final companions = <LocalRevisionItemsCompanion>[];
    final createdItems = <RevisionItem>[];

    for (final item in items) {
      final id = item.id.trim().isEmpty ? const Uuid().v4() : item.id.trim();
      companions.add(_toCompanion(item, id: id, now: now));
      createdItems.add(
        item.copyWith(
          id: id,
          createdAt: item.createdAt ?? now,
          updatedAt: now,
        ),
      );
    }

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.localRevisionItems, companions);
    });

    return List.unmodifiable(createdItems);
  }

  @override
  Future<RevisionItem> updateRevisionItem(RevisionItem item) async {
    final trimmedId = item.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_revision_item_id',
        message: 'Cannot update a revision item without an id.',
      );
    }
    _validateForWrite(item);

    final existing = await (_db.select(_db.localRevisionItems)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'revision_item_not_found',
        message: 'Revision item not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final entry = _toCompanion(
      item,
      id: trimmedId,
      now: now,
      createdAt: existing.createdAt,
    );

    await _db.update(_db.localRevisionItems).replace(entry);
    return item.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteRevisionItem(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_revision_item_id',
        message: 'Cannot delete a revision item without an id.',
      );
    }

    await (_db.delete(_db.localRevisionItems)
          ..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  void _validateForWrite(RevisionItem item) {
    if (item.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'A revision item must be associated with a subject.',
      );
    }
    if (item.referenceLabel.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_reference_label',
        message: 'A revision item must have a reference label.',
      );
    }
  }

  LocalRevisionItemsCompanion _toCompanion(
    RevisionItem item, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
  }) {
    return LocalRevisionItemsCompanion(
      id: Value(id),
      subjectId: Value(item.subjectId.trim()),
      materialId: Value(item.materialId?.trim()),
      topicId: Value(item.topicId?.trim()),
      referenceLabel: Value(item.referenceLabel.trim()),
      pageNumber: Value(item.pageNumber),
      note: Value(item.note),
      reason: Value(item.reason.value),
      source: Value(item.source.value),
      progressLogId: Value(item.progressLogId?.trim()),
      mockTestId: Value(item.mockTestId?.trim()),
      status: Value(item.status.value),
      dueOn: Value(item.dueOn.toUtc()),
      reviewCount: Value(item.reviewCount < 0 ? 0 : item.reviewCount),
      lastReviewedOn: Value(item.lastReviewedOn?.toUtc()),
      createdAt: Value(item.createdAt ?? createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  RevisionItem _mapRow(LocalRevisionItem row) {
    return RevisionItem(
      id: row.id,
      subjectId: row.subjectId,
      materialId: row.materialId,
      topicId: row.topicId,
      referenceLabel: row.referenceLabel,
      pageNumber: row.pageNumber,
      note: row.note,
      reason: RevisionReason.fromValue(row.reason),
      source: RevisionSource.fromValue(row.source),
      progressLogId: row.progressLogId,
      mockTestId: row.mockTestId,
      status: RevisionStatus.fromValue(row.status),
      dueOn: row.dueOn,
      reviewCount: row.reviewCount,
      lastReviewedOn: row.lastReviewedOn,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
