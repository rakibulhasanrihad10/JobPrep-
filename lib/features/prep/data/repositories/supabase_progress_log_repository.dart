import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/progress_log_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [ProgressLogRepository] backed by
/// `public.progress_logs`.
class SupabaseProgressLogRepository implements ProgressLogRepository {
  /// Creates a [SupabaseProgressLogRepository].
  const SupabaseProgressLogRepository(this._client);

  static const String _table = 'progress_logs';

  final supabase.SupabaseClient _client;

  @override
  Future<List<ProgressLog>> getLogsForMaterial(String materialId) async {
    final trimmedId = materialId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('material_id', trimmedId)
          .order('logged_on', ascending: false)
          .order('created_at', ascending: false);
      return ProgressLogMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<ProgressLog>> getRecentLogs({int limit = 50}) async {
    final safeLimit = limit <= 0 ? 1 : limit;
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('logged_on', ascending: false)
          .order('created_at', ascending: false)
          .limit(safeLimit);
      return ProgressLogMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<ProgressLog> createLog(ProgressLog log) async {
    _validateForWrite(log);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = ProgressLogMapper.toInsertJson(
        log,
        userId: log.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return ProgressLogMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<ProgressLog> updateLog(ProgressLog log) async {
    final trimmedId = log.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_log_id',
        message: 'Cannot update a progress log without an id.',
      );
    }
    _validateForWrite(log);

    try {
      final row = await _client
          .from(_table)
          .update(ProgressLogMapper.toUpdateJson(log))
          .eq('id', trimmedId)
          .select()
          .single();
      return ProgressLogMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_log_id',
        message: 'Cannot delete a progress log without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(ProgressLog log) {
    if (log.materialId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_material_id',
        message: 'Progress log requires a material id.',
      );
    }
    if (log.isStudy && log.unitsDone < 0) {
      throw const PrepValidationFailure(
        code: 'negative_study_units',
        message: 'Study logs cannot record negative units.',
      );
    }
  }
}
