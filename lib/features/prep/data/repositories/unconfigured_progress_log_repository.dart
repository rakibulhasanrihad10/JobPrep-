import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';

/// Safe fallback [ProgressLogRepository] used when Supabase is unconfigured.
class UnconfiguredProgressLogRepository implements ProgressLogRepository {
  /// Creates an [UnconfiguredProgressLogRepository].
  const UnconfiguredProgressLogRepository();

  static const _failure = UnknownPrepFailure(
    code: 'supabase_not_configured',
    message: 'Supabase environment variables are not configured.',
  );

  @override
  Future<List<ProgressLog>> getLogsForMaterial(String materialId) async =>
      const [];

  @override
  Future<List<ProgressLog>> getRecentLogs({int limit = 50}) async => const [];

  @override
  Future<ProgressLog> createLog(ProgressLog log) => Future.error(_failure);

  @override
  Future<ProgressLog> updateLog(ProgressLog log) => Future.error(_failure);

  @override
  Future<void> deleteLog(String id) => Future.error(_failure);
}
