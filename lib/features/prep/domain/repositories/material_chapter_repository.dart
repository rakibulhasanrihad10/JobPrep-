import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';

/// Repository interface for study material to syllabus chapter associations.
abstract interface class MaterialChapterRepository {
  /// Fetches all chapter links for a given [materialId].
  Future<List<MaterialChapter>> getChaptersForMaterial(String materialId);

  /// Fetches all material links for a given [chapterId].
  Future<List<MaterialChapter>> getMaterialsForChapter(String chapterId);

  /// Replaces the set of linked chapters for [materialId].
  Future<void> setChaptersForMaterial(
    String materialId,
    List<String> chapterIds,
  );

  /// Creates a single link between [materialId] and [chapterId].
  Future<MaterialChapter> linkChapter({
    required String materialId,
    required String chapterId,
    String? id,
  });

  /// Removes link between [materialId] and [chapterId].
  Future<void> unlinkChapter({
    required String materialId,
    required String chapterId,
  });

  /// Inserts multiple links in batch (idempotent upsert).
  Future<void> batchCreate(List<MaterialChapter> links);

  /// Fetches all links for the current user.
  Future<List<MaterialChapter>> getAll();
}
