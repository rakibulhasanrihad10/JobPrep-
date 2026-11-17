import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';
import 'package:job_prep/features/prep/domain/repositories/material_chapter_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Local Drift SQLite implementation of [MaterialChapterRepository].
class LocalMaterialChapterRepository implements MaterialChapterRepository {
  const LocalMaterialChapterRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<MaterialChapter>> getChaptersForMaterial(
    String materialId,
  ) async {
    final rows = await (_db.select(_db.localMaterialChapters)
          ..where((t) => t.materialId.equals(materialId)))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<MaterialChapter>> getMaterialsForChapter(
    String chapterId,
  ) async {
    final rows = await (_db.select(_db.localMaterialChapters)
          ..where((t) => t.chapterId.equals(chapterId)))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> setChaptersForMaterial(
    String materialId,
    List<String> chapterIds,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.localMaterialChapters)
            ..where((t) => t.materialId.equals(materialId)))
          .go();
      final now = DateTime.now().toUtc();
      for (final chapterId in chapterIds) {
        await _db.into(_db.localMaterialChapters).insert(
              LocalMaterialChapter(
                id: _uuid.v4(),
                materialId: materialId,
                chapterId: chapterId,
                createdAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<MaterialChapter> linkChapter({
    required String materialId,
    required String chapterId,
    String? id,
  }) async {
    final existing = await (_db.select(_db.localMaterialChapters)
          ..where(
            (t) =>
                t.materialId.equals(materialId) & t.chapterId.equals(chapterId),
          ))
        .getSingleOrNull();
    if (existing != null) {
      return _toEntity(existing);
    }
    final now = DateTime.now().toUtc();
    final link = LocalMaterialChapter(
      id: id ?? _uuid.v4(),
      materialId: materialId,
      chapterId: chapterId,
      createdAt: now,
    );
    await _db.into(_db.localMaterialChapters).insert(link);
    return _toEntity(link);
  }

  @override
  Future<void> unlinkChapter({
    required String materialId,
    required String chapterId,
  }) async {
    await (_db.delete(_db.localMaterialChapters)
          ..where(
            (t) =>
                t.materialId.equals(materialId) & t.chapterId.equals(chapterId),
          ))
        .go();
  }

  @override
  Future<void> batchCreate(List<MaterialChapter> links) async {
    await _db.transaction(() async {
      for (final link in links) {
        final existing = await (_db.select(_db.localMaterialChapters)
              ..where(
                (t) =>
                    t.materialId.equals(link.materialId) &
                    t.chapterId.equals(link.chapterId),
              ))
            .getSingleOrNull();
        if (existing == null) {
          await _db.into(_db.localMaterialChapters).insert(
                LocalMaterialChapter(
                  id: link.id.trim().isNotEmpty ? link.id : _uuid.v4(),
                  materialId: link.materialId,
                  chapterId: link.chapterId,
                  createdAt: link.createdAt ?? DateTime.now().toUtc(),
                ),
              );
        }
      }
    });
  }

  @override
  Future<List<MaterialChapter>> getAll() async {
    final rows = await _db.select(_db.localMaterialChapters).get();
    return rows.map(_toEntity).toList();
  }

  MaterialChapter _toEntity(LocalMaterialChapter row) {
    return MaterialChapter(
      id: row.id,
      userId: '',
      materialId: row.materialId,
      chapterId: row.chapterId,
      createdAt: row.createdAt,
    );
  }
}
