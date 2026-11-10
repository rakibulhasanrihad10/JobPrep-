import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_material_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [MaterialRepository] backed by
/// `public.materials`.
class SupabaseMaterialRepository implements MaterialRepository {
  /// Creates a [SupabaseMaterialRepository].
  const SupabaseMaterialRepository(this._client);

  static const String _table = 'materials';

  final supabase.SupabaseClient _client;

  @override
  Future<List<PrepMaterial>> getAllMaterials() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: true);
      return PrepMaterialMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<PrepMaterial>> getMaterialsForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('subject_id', trimmedId)
          .order('created_at', ascending: true);
      return PrepMaterialMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<PrepMaterial?> getMaterialById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    try {
      final row =
          await _client.from(_table).select().eq('id', trimmedId).maybeSingle();
      if (row == null) return null;
      return PrepMaterialMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<PrepMaterial> createMaterial(PrepMaterial material) async {
    _validateForWrite(material);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = PrepMaterialMapper.toInsertJson(
        material,
        userId: material.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return PrepMaterialMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<PrepMaterial> updateMaterial(PrepMaterial material) async {
    final trimmedId = material.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_id',
        message: 'Cannot update a material without an id.',
      );
    }
    _validateForWrite(material);

    try {
      final row = await _client
          .from(_table)
          .update(PrepMaterialMapper.toUpdateJson(material))
          .eq('id', trimmedId)
          .select()
          .single();
      return PrepMaterialMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteMaterial(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_id',
        message: 'Cannot delete a material without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(PrepMaterial material) {
    if (material.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Material requires a parent subject id.',
      );
    }
    if (material.title.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'empty_material_title',
        message: 'Material title cannot be empty.',
      );
    }
    if (material.totalUnits < 0) {
      throw const PrepValidationFailure(
        code: 'negative_total_units',
        message: 'Total units cannot be negative.',
      );
    }
  }
}
