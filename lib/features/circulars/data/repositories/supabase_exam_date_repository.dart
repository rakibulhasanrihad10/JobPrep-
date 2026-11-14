import 'package:job_prep/features/circulars/data/mappers/circular_error_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_exam_date_mapper.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

/// Supabase PostgREST implementation of [ExamDateRepository] backed by
/// `public.circular_exam_dates`.
class SupabaseExamDateRepository implements ExamDateRepository {
  /// Creates a [SupabaseExamDateRepository].
  const SupabaseExamDateRepository(this._client);

  static const String _table = 'circular_exam_dates';

  final supabase.SupabaseClient _client;

  @override
  Future<List<CircularExamDate>> getExamDatesForCircular(
    String circularId,
  ) async {
    final trimmedId = circularId.trim();
    if (trimmedId.isEmpty) {
      return const [];
    }

    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('circular_id', trimmedId)
          .order('exam_date', ascending: true);

      return CircularExamDateMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<CircularExamDate> createExamDate(CircularExamDate examDate) async {
    _validateForWrite(examDate);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final dateWithId = examDate.id.trim().isEmpty
          ? examDate.copyWith(id: const Uuid().v4())
          : examDate;
      final payload = CircularExamDateMapper.toInsertJson(
        dateWithId,
        userId: dateWithId.userId.trim().isEmpty ? currentUserId : null,
      );

      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'id')
          .select()
          .single();
      return CircularExamDateMapper.fromJson(row);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<CircularExamDate> updateExamDate(CircularExamDate examDate) async {
    if (examDate.id.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_exam_date_id',
        message: 'Cannot update an exam date without an id.',
      );
    }
    _validateForWrite(examDate);

    try {
      final row = await _client
          .from(_table)
          .update(CircularExamDateMapper.toUpdateJson(examDate))
          .eq('id', examDate.id.trim())
          .select()
          .single();

      return CircularExamDateMapper.fromJson(row);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteExamDate(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_exam_date_id',
        message: 'Cannot delete an exam date without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw CircularErrorMapper.map(error);
    }
  }

  void _validateForWrite(CircularExamDate examDate) {
    if (examDate.circularId.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'missing_circular_id',
        message: 'Exam date requires a parent circular id.',
      );
    }
    if (examDate.stage.trim().isEmpty) {
      throw const CircularValidationFailure(
        code: 'empty_stage',
        message: 'Exam stage cannot be empty.',
      );
    }
  }
}
