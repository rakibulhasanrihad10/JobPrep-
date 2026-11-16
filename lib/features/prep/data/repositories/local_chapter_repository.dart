import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [ChapterRepository].
class LocalChapterRepository implements ChapterRepository {
  /// Creates a [LocalChapterRepository].
  const LocalChapterRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Chapter>> getChaptersForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localChapters)
      ..where((c) => c.subjectId.equals(trimmedId))
      ..orderBy([
        (c) => OrderingTerm.asc(c.sortOrder),
        (c) => OrderingTerm.asc(c.createdAt),
      ]);

    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<Chapter?> getChapterById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    final query = _db.select(_db.localChapters)
      ..where((c) => c.id.equals(trimmedId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<Chapter> createChapter(Chapter chapter) async {
    _validateForWrite(chapter);

    final id =
        chapter.id.trim().isEmpty ? const Uuid().v4() : chapter.id.trim();
    final now = DateTime.now().toUtc();
    final entry = LocalChaptersCompanion(
      id: Value(id),
      subjectId: Value(chapter.subjectId.trim()),
      title: Value(chapter.title.trim()),
      sortOrder: Value(chapter.sortOrder < 0 ? 0 : chapter.sortOrder),
      createdAt: Value(chapter.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localChapters).insertOnConflictUpdate(entry);
    return chapter.copyWith(
      id: id,
      createdAt: chapter.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<Chapter> updateChapter(Chapter chapter) async {
    final trimmedId = chapter.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_chapter_id',
        message: 'Cannot update a chapter without an id.',
      );
    }
    _validateForWrite(chapter);

    final existing = await (_db.select(_db.localChapters)
          ..where((c) => c.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const PrepNotFoundFailure(
        code: 'chapter_not_found',
        message: 'Chapter not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final entry = LocalChaptersCompanion(
      id: Value(trimmedId),
      subjectId: Value(chapter.subjectId.trim()),
      title: Value(chapter.title.trim()),
      sortOrder: Value(chapter.sortOrder < 0 ? 0 : chapter.sortOrder),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
    );

    await _db.update(_db.localChapters).replace(entry);
    return chapter.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteChapter(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_chapter_id',
        message: 'Cannot delete a chapter without an id.',
      );
    }

    await (_db.delete(_db.localChapters)..where((c) => c.id.equals(trimmedId)))
        .go();
  }

  @override
  Future<void> reorderChapters(List<String> orderedChapterIds) async {
    if (orderedChapterIds.isEmpty) return;

    await _db.transaction(() async {
      for (var i = 0; i < orderedChapterIds.length; i++) {
        final id = orderedChapterIds[i].trim();
        if (id.isEmpty) continue;
        await (_db.update(_db.localChapters)..where((c) => c.id.equals(id)))
            .write(LocalChaptersCompanion(sortOrder: Value(i)));
      }
    });
  }

  void _validateForWrite(Chapter chapter) {
    if (chapter.title.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_chapter_title',
        message: 'A chapter must have a non-empty title.',
      );
    }
  }

  Chapter _mapRow(LocalChapter row) {
    return Chapter(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
