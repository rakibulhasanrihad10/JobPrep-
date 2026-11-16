import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';

/// Safe fallback [ChapterRepository] used when Supabase is unconfigured.
class UnconfiguredChapterRepository implements ChapterRepository {
  /// Creates an [UnconfiguredChapterRepository].
  const UnconfiguredChapterRepository();

  static const _failure = UnknownPrepFailure(
    code: 'supabase_not_configured',
    message: 'Supabase environment variables are not configured.',
  );

  @override
  Future<List<Chapter>> getChaptersForSubject(String subjectId) async =>
      const [];

  @override
  Future<Chapter?> getChapterById(String id) async => null;

  @override
  Future<Chapter> createChapter(Chapter chapter) => Future.error(_failure);

  @override
  Future<Chapter> updateChapter(Chapter chapter) => Future.error(_failure);

  @override
  Future<void> deleteChapter(String id) => Future.error(_failure);

  @override
  Future<void> reorderChapters(List<String> orderedChapterIds) =>
      Future.error(_failure);
}
