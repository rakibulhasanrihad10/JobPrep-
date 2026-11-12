import 'package:job_prep/features/prep/domain/entities/mock_test.dart';

/// Repository contract for managing logged mock tests (`public.mock_tests`).
abstract interface class MockTestRepository {
  /// Fetches all mock tests owned by the active user, newest first.
  Future<List<MockTest>> getTests();

  /// Fetches mock tests belonging to [subjectId], newest first.
  Future<List<MockTest>> getTestsForSubject(String subjectId);

  /// Inserts a new [test] and returns the persisted record.
  Future<MockTest> createTest(MockTest test);

  /// Updates an existing [test] and returns the persisted record.
  Future<MockTest> updateTest(MockTest test);

  /// Permanently deletes the mock test identified by [id].
  Future<void> deleteTest(String id);
}
