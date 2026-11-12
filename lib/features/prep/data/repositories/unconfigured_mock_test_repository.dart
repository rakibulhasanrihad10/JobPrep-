import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';

/// Fallback [MockTestRepository] used before Supabase credentials are provided.
class UnconfiguredMockTestRepository implements MockTestRepository {
  /// Creates an [UnconfiguredMockTestRepository].
  const UnconfiguredMockTestRepository();

  static const _failure = UnknownPrepFailure(
    code: 'prep_unconfigured',
    message: 'Mock tests storage is not configured.',
  );

  @override
  Future<List<MockTest>> getTests() async => const <MockTest>[];

  @override
  Future<List<MockTest>> getTestsForSubject(String subjectId) async =>
      const <MockTest>[];

  @override
  Future<MockTest> createTest(MockTest test) =>
      Future<MockTest>.error(_failure);

  @override
  Future<MockTest> updateTest(MockTest test) =>
      Future<MockTest>.error(_failure);

  @override
  Future<void> deleteTest(String id) => Future<void>.error(_failure);
}
