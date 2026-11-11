import 'package:job_prep/features/prep/data/mappers/mock_test_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [MockTestRepository] backed by
/// `public.mock_tests`.
class SupabaseMockTestRepository implements MockTestRepository {
  /// Creates a [SupabaseMockTestRepository].
  const SupabaseMockTestRepository(this._client);

  static const String _table = 'mock_tests';

  final supabase.SupabaseClient _client;

  @override
  Future<List<MockTest>> getTests() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('taken_on', ascending: false)
          .order('created_at', ascending: false);
      return MockTestMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<MockTest>> getTestsForSubject(String subjectId) async {
    final trimmedId = subjectId.trim();
    if (trimmedId.isEmpty) return const <MockTest>[];

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('subject_id', trimmedId)
          .order('taken_on', ascending: false)
          .order('created_at', ascending: false);
      return MockTestMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<MockTest> createTest(MockTest test) async {
    _validateForWrite(test);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = MockTestMapper.toInsertJson(
        test,
        userId: test.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return MockTestMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<MockTest> updateTest(MockTest test) async {
    final trimmedId = test.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_mock_test_id',
        message: 'Cannot update a mock test without an id.',
      );
    }
    _validateForWrite(test);

    try {
      final row = await _client
          .from(_table)
          .update(MockTestMapper.toUpdateJson(test))
          .eq('id', trimmedId)
          .select()
          .single();
      return MockTestMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteTest(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_mock_test_id',
        message: 'Cannot delete a mock test without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(MockTest test) {
    if (test.subjectId.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Mock test must belong to a subject.',
      );
    }
    if (test.title.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'empty_mock_test_title',
        message: 'Mock test title cannot be empty.',
      );
    }
    if (!test.totalMarks.isFinite || test.totalMarks <= 0) {
      throw const PrepValidationFailure(
        code: 'invalid_total_marks',
        message: 'Total marks must be greater than zero.',
      );
    }
    if (!test.marksObtained.isFinite ||
        test.marksObtained < 0 ||
        test.marksObtained > test.totalMarks) {
      throw const PrepValidationFailure(
        code: 'invalid_marks_obtained',
        message: 'Marks obtained must be between 0 and total marks.',
      );
    }
    if (test.negativeMarks != null &&
        (!test.negativeMarks!.isFinite ||
            test.negativeMarks! < 0 ||
            test.negativeMarks! > test.totalMarks)) {
      throw const PrepValidationFailure(
        code: 'invalid_negative_marks',
        message: 'Negative marks must be between 0 and total marks.',
      );
    }
    if (test.timeTakenMinutes != null && test.timeTakenMinutes! < 0) {
      throw const PrepValidationFailure(
        code: 'invalid_time_taken',
        message: 'Time taken cannot be negative.',
      );
    }
    if (test.timeLimitMinutes != null && test.timeLimitMinutes! <= 0) {
      throw const PrepValidationFailure(
        code: 'invalid_time_limit',
        message: 'Time limit must be greater than zero.',
      );
    }
  }
}
