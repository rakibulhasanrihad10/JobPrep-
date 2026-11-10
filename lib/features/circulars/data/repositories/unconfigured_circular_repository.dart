import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';

/// Safe fallback [CircularRepository] used when Supabase environment keys
/// (`SUPABASE_URL` / `SUPABASE_ANON_KEY`) have not been configured.
class UnconfiguredCircularRepository implements CircularRepository {
  /// Creates an [UnconfiguredCircularRepository].
  const UnconfiguredCircularRepository();

  static const _notConfiguredError = UnknownCircularFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async =>
      const [];

  @override
  Future<Circular?> getCircularById(String id) async => null;

  @override
  Future<Circular> createCircular(Circular circular) =>
      Future.error(_notConfiguredError);

  @override
  Future<Circular> updateCircular(Circular circular) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> deleteCircular(String id) => Future.error(_notConfiguredError);
}
