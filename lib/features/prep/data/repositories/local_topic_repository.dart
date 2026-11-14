import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [TopicRepository].
class LocalTopicRepository implements TopicRepository {
  /// Creates a [LocalTopicRepository].
  const LocalTopicRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Topic>> getTopicsForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localTopics)
      ..where((t) => t.subjectId.equals(trimmedId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<Topic> createTopic(Topic topic) async {
    _validateForWrite(topic);

    final id = topic.id.trim().isEmpty ? const Uuid().v4() : topic.id.trim();
    final now = DateTime.now().toUtc();
    final entry = LocalTopicsCompanion(
      id: Value(id),
      subjectId: Value(topic.subjectId.trim()),
      name: Value(topic.name.trim()),
      createdAt: Value(topic.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localTopics).insertOnConflictUpdate(entry);
    return topic.copyWith(
      id: id,
      createdAt: topic.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<Topic> updateTopic(Topic topic) async {
    final trimmedId = topic.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_topic_id',
        message: 'Cannot update a topic without an id.',
      );
    }
    _validateForWrite(topic);

    final existing = await (_db.select(_db.localTopics)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'topic_not_found',
        message: 'Topic not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final entry = LocalTopicsCompanion(
      id: Value(trimmedId),
      subjectId: Value(topic.subjectId.trim()),
      name: Value(topic.name.trim()),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
    );

    await _db.update(_db.localTopics).replace(entry);
    return topic.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteTopic(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_topic_id',
        message: 'Cannot delete a topic without an id.',
      );
    }

    await (_db.delete(_db.localTopics)..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  void _validateForWrite(Topic topic) {
    if (topic.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'A topic must belong to a subject.',
      );
    }
    if (topic.name.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_topic_name',
        message: 'A topic must have a non-empty name.',
      );
    }
  }

  Topic _mapRow(LocalTopic row) {
    return Topic(
      id: row.id,
      subjectId: row.subjectId,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
