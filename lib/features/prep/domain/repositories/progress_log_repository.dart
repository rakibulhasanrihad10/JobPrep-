import 'package:job_prep/features/prep/domain/entities/progress_log.dart';

/// Contract for managing study progress logs (`public.progress_logs`).
abstract interface class ProgressLogRepository {
  /// Fetches all progress logs recorded for [materialId], newest first.
  Future<List<ProgressLog>> getLogsForMaterial(String materialId);

  /// Fetches the most recent progress logs across all materials.
  Future<List<ProgressLog>> getRecentLogs({int limit = 50});

  /// Inserts [log], allowing PostgreSQL's trigger to recalculate
  /// `materials.completed_units`.
  Future<ProgressLog> createLog(ProgressLog log);

  /// Updates an existing [log], recalculating affected materials via trigger.
  Future<ProgressLog> updateLog(ProgressLog log);

  /// Deletes the log identified by [id], recalculating parent material units.
  Future<void> deleteLog(String id);
}
