import 'package:job_prep/features/prep/domain/entities/chapter.dart';

/// Contract for managing syllabus chapters (`public.chapters`).
abstract interface class ChapterRepository {
  /// Fetches all syllabus chapters for [subjectId] ordered by `sortOrder`.
  Future<List<Chapter>> getChaptersForSubject(String subjectId);

  /// Retrieves a single chapter by its [id], or `null` if not found.
  Future<Chapter?> getChapterById(String id);

  /// Inserts a new [chapter] and returns the persisted record.
  Future<Chapter> createChapter(Chapter chapter);

  /// Updates an existing [chapter] and returns the persisted record.
  Future<Chapter> updateChapter(Chapter chapter);

  /// Permanently deletes the chapter identified by [id].
  Future<void> deleteChapter(String id);

  /// Persists new sequential sort order indices for [orderedChapterIds].
  Future<void> reorderChapters(List<String> orderedChapterIds);
}
