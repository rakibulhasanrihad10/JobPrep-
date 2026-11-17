import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_chapter_repository.dart';

/// Fallback repository throwing [UnknownPrepFailure].
class UnconfiguredMaterialChapterRepository
    implements MaterialChapterRepository {
  const UnconfiguredMaterialChapterRepository();

  static const _failure = UnknownPrepFailure(
    code: 'prep_unconfigured',
    message: 'Material chapters storage is not configured.',
  );

  Never _fail() => throw _failure;

  @override
  Future<List<MaterialChapter>> getChaptersForMaterial(
    String materialId,
  ) async =>
      const <MaterialChapter>[];

  @override
  Future<List<MaterialChapter>> getMaterialsForChapter(
    String chapterId,
  ) async =>
      const <MaterialChapter>[];

  @override
  Future<void> setChaptersForMaterial(
    String materialId,
    List<String> chapterIds,
  ) async =>
      _fail();

  @override
  Future<MaterialChapter> linkChapter({
    required String materialId,
    required String chapterId,
    String? id,
  }) async =>
      _fail();

  @override
  Future<void> unlinkChapter({
    required String materialId,
    required String chapterId,
  }) async =>
      _fail();

  @override
  Future<void> batchCreate(List<MaterialChapter> links) async => _fail();

  @override
  Future<List<MaterialChapter>> getAll() async => const <MaterialChapter>[];
}
