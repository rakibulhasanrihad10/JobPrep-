import 'package:job_prep/features/prep/data/mappers/chapter_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/chapter_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

/// Supabase PostgREST implementation of [ChapterRepository] backed by
/// `public.chapters`.
class SupabaseChapterRepository implements ChapterRepository {
  /// Creates a [SupabaseChapterRepository].
  const SupabaseChapterRepository(this._client);

  static const String _table = 'chapters';

  final supabase.SupabaseClient _client;

  @override
  Future<List<Chapter>> getChaptersForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('subject_id', trimmedId)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);
      return ChapterMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Chapter?> getChapterById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    try {
      final row =
          await _client.from(_table).select().eq('id', trimmedId).maybeSingle();
      if (row == null) return null;
      return ChapterMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Chapter> createChapter(Chapter chapter) async {
    _validateForWrite(chapter);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final chapterWithId = chapter.id.trim().isEmpty
          ? chapter.copyWith(id: const Uuid().v4())
          : chapter;
      final payload = ChapterMapper.toInsertJson(
        chapterWithId,
        userId: chapterWithId.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'id')
          .select()
          .single();
      return ChapterMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
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

    try {
      final payload = ChapterMapper.toUpdateJson(chapter);
      final row = await _client
          .from(_table)
          .update(payload)
          .eq('id', trimmedId)
          .select()
          .single();
      return ChapterMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
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

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> reorderChapters(List<String> orderedChapterIds) async {
    if (orderedChapterIds.isEmpty) return;

    try {
      for (var i = 0; i < orderedChapterIds.length; i++) {
        final id = orderedChapterIds[i].trim();
        if (id.isEmpty) continue;
        await _client.from(_table).update({'sort_order': i}).eq('id', id);
      }
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(Chapter chapter) {
    if (chapter.title.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_chapter_title',
        message: 'A chapter must have a non-empty title.',
      );
    }
  }
}
