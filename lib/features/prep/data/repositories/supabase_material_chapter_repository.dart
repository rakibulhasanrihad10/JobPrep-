import 'package:job_prep/features/prep/data/mappers/material_chapter_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';
import 'package:job_prep/features/prep/domain/repositories/material_chapter_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Supabase PostgREST implementation of [MaterialChapterRepository].
class SupabaseMaterialChapterRepository implements MaterialChapterRepository {
  const SupabaseMaterialChapterRepository(this._client);

  static const String _table = 'material_chapters';

  final supabase.SupabaseClient _client;

  @override
  Future<List<MaterialChapter>> getChaptersForMaterial(
    String materialId,
  ) async {
    final trimmedId = materialId.trim();
    if (trimmedId.isEmpty) return const [];
    try {
      final rows =
          await _client.from(_table).select().eq('material_id', trimmedId);
      return MaterialChapterMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<MaterialChapter>> getMaterialsForChapter(String chapterId) async {
    final trimmedId = chapterId.trim();
    if (trimmedId.isEmpty) return const [];
    try {
      final rows =
          await _client.from(_table).select().eq('chapter_id', trimmedId);
      return MaterialChapterMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> setChaptersForMaterial(
    String materialId,
    List<String> chapterIds,
  ) async {
    final trimmedMaterial = materialId.trim();
    if (trimmedMaterial.isEmpty) return;
    try {
      await _client.from(_table).delete().eq('material_id', trimmedMaterial);
      if (chapterIds.isNotEmpty) {
        final currentUserId = _client.auth.currentUser?.id ?? '';
        final payload = chapterIds.map((cId) {
          return {
            'id': _uuid.v4(),
            'user_id': currentUserId,
            'material_id': trimmedMaterial,
            'chapter_id': cId.trim(),
          };
        }).toList();
        await _client.from(_table).insert(payload);
      }
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<MaterialChapter> linkChapter({
    required String materialId,
    required String chapterId,
    String? id,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id ?? '';
      final linkId = id ?? _uuid.v4();
      final payload = {
        'id': linkId,
        'user_id': currentUserId,
        'material_id': materialId.trim(),
        'chapter_id': chapterId.trim(),
      };
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'material_id,chapter_id')
          .select()
          .single();
      return MaterialChapterMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> unlinkChapter({
    required String materialId,
    required String chapterId,
  }) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('material_id', materialId.trim())
          .eq('chapter_id', chapterId.trim());
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> batchCreate(List<MaterialChapter> links) async {
    if (links.isEmpty) return;
    try {
      final currentUserId = _client.auth.currentUser?.id ?? '';
      final payload = links.map((link) {
        return MaterialChapterMapper.toInsertJson(link, userId: currentUserId);
      }).toList();
      await _client.from(_table).upsert(payload, onConflict: 'id');
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<MaterialChapter>> getAll() async {
    try {
      final rows = await _client.from(_table).select();
      return MaterialChapterMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }
}
