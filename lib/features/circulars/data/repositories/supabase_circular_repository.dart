import 'package:job_prep/features/circulars/data/mappers/circular_error_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_mapper.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [CircularRepository].
class SupabaseCircularRepository implements CircularRepository {
  /// Creates a [SupabaseCircularRepository].
  const SupabaseCircularRepository(this._client);

  static const String _table = 'circulars';
  static const String _selectWithRelations =
      '*, circular_exam_dates(*), circular_files(*)';

  final supabase.SupabaseClient _client;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async {
    try {
      final rows = await _client
          .from(_table)
          .select(_selectWithRelations)
          .order('deadline', ascending: true, nullsFirst: false)
          .order('updated_at', ascending: false);

      final circulars = rows.map(CircularMapper.fromJson).toList();
      if (filter != null) {
        return filter.apply(circulars);
      }
      return List.unmodifiable(circulars);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<Circular?> getCircularById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    try {
      final row = await _client
          .from(_table)
          .select(_selectWithRelations)
          .eq('id', trimmedId)
          .maybeSingle();

      if (row == null) return null;
      return CircularMapper.fromJson(row);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<Circular> createCircular(Circular circular) async {
    _validateForWrite(circular);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = CircularMapper.toInsertJson(
        circular,
        userId: circular.userId.trim().isEmpty ? currentUserId : null,
      );

      final row = await _client
          .from(_table)
          .insert(payload)
          .select(_selectWithRelations)
          .single();

      return CircularMapper.fromJson(row);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<Circular> updateCircular(Circular circular) async {
    if (circular.id.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Cannot update a circular without an id.',
      );
    }
    _validateForWrite(circular);

    try {
      final row = await _client
          .from(_table)
          .update(CircularMapper.toUpdateJson(circular))
          .eq('id', circular.id.trim())
          .select(_selectWithRelations)
          .single();

      return CircularMapper.fromJson(row);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteCircular(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Cannot delete a circular without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  void _validateForWrite(Circular circular) {
    if (circular.title.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'empty_title',
        message: 'Circular title cannot be empty.',
      );
    }
    if (circular.salaryMin != null &&
        circular.salaryMax != null &&
        circular.salaryMax! < circular.salaryMin!) {
      throw const CircularValidationFailure(
        code: 'invalid_salary_range',
        message: 'Maximum salary cannot be lower than minimum salary.',
      );
    }
  }
}
