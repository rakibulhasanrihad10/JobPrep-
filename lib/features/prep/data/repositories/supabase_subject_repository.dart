import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/data/mappers/subject_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [SubjectRepository] backed by
/// `public.subjects` and `public.circular_subjects`.
class SupabaseSubjectRepository implements SubjectRepository {
  /// Creates a [SupabaseSubjectRepository].
  const SupabaseSubjectRepository(this._client);

  static const String _table = 'subjects';
  static const String _linkTable = 'circular_subjects';

  final supabase.SupabaseClient _client;

  @override
  Future<List<Subject>> getSubjects() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);
      return SubjectMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return null;

    try {
      final row =
          await _client.from(_table).select().eq('id', trimmedId).maybeSingle();
      if (row == null) return null;
      return SubjectMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    _validateForWrite(subject);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = SubjectMapper.toInsertJson(
        subject,
        userId: subject.userId.trim().isEmpty ? currentUserId : null,
      );
      final row = await _client.from(_table).insert(payload).select().single();
      return SubjectMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    final trimmedId = subject.id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Cannot update a subject without an id.',
      );
    }
    _validateForWrite(subject);

    try {
      final row = await _client
          .from(_table)
          .update(SubjectMapper.toUpdateJson(subject))
          .eq('id', trimmedId)
          .select()
          .single();
      return SubjectMapper.fromJson(row);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteSubject(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_subject_id',
        message: 'Cannot delete a subject without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<List<String>> getSubjectIdsForCircular(String circularId) async {
    final trimmedCircularId = circularId.trim();
    if (trimmedCircularId.isEmpty) return const [];

    try {
      final rows = await _client
          .from(_linkTable)
          .select('subject_id')
          .eq('circular_id', trimmedCircularId);
      final ids = rows
          .map((row) => PrepJsonHelpers.readRequiredString(row, 'subject_id'))
          .where((id) => id.trim().isNotEmpty)
          .toList(growable: false);
      return List<String>.unmodifiable(ids);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> linkSubjectToCircular({
    required String circularId,
    required String subjectId,
  }) async {
    final trimmedCircularId = circularId.trim();
    final trimmedSubjectId = subjectId.trim();
    if (trimmedCircularId.isEmpty || trimmedSubjectId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_link_ids',
        message: 'Circular and subject identifiers are required to link.',
      );
    }

    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from(_linkTable).upsert(
        <String, dynamic>{
          'circular_id': trimmedCircularId,
          'subject_id': trimmedSubjectId,
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
        },
        onConflict: 'circular_id,subject_id',
      );
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> unlinkSubjectFromCircular({
    required String circularId,
    required String subjectId,
  }) async {
    final trimmedCircularId = circularId.trim();
    final trimmedSubjectId = subjectId.trim();
    if (trimmedCircularId.isEmpty || trimmedSubjectId.isEmpty) {
      return;
    }

    try {
      await _client
          .from(_linkTable)
          .delete()
          .eq('circular_id', trimmedCircularId)
          .eq('subject_id', trimmedSubjectId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  void _validateForWrite(Subject subject) {
    if (subject.name.trim().isEmpty) {
      throw const PrepValidationFailure(
        code: 'empty_subject_name',
        message: 'Subject name cannot be empty.',
      );
    }
    if (subject.sortOrder < 0) {
      throw const PrepValidationFailure(
        code: 'negative_sort_order',
        message: 'Subject sort order cannot be negative.',
      );
    }
  }
}
