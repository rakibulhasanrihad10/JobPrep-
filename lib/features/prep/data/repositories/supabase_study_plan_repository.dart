import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/study_plan_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [StudyPlanRepository] backed by
/// `public.study_plans`.
class SupabaseStudyPlanRepository implements StudyPlanRepository {
  /// Creates a [SupabaseStudyPlanRepository].
  const SupabaseStudyPlanRepository(this._client);

  static const String _table = 'study_plans';

  final supabase.SupabaseClient _client;

  @override
  Future<List<StudyPlan>> getPlans() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('target_date', ascending: true)
          .order('created_at', ascending: true);
      return StudyPlanMapper.fromJsonList(rows);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<StudyPlan> savePlan(StudyPlan plan) async {
    _validateForWrite(plan);

    try {
      final trimmedId = plan.id.trim();
      if (trimmedId.isNotEmpty) {
        final updated = await _client
            .from(_table)
            .update(StudyPlanMapper.toUpdateJson(plan))
            .eq('id', trimmedId)
            .select()
            .single();
        return StudyPlanMapper.fromJson(updated);
      }

      // Check for an existing plan in the same scope so users never hit
      // partial-unique conflicts when creating for All Subjects or a subject.
      final existing = await _findExistingInScope(plan.subjectId);
      if (existing != null) {
        final updated = await _client
            .from(_table)
            .update(StudyPlanMapper.toUpdateJson(plan))
            .eq('id', existing.id)
            .select()
            .single();
        return StudyPlanMapper.fromJson(updated);
      }

      final currentUserId = _client.auth.currentUser?.id;
      final payload = StudyPlanMapper.toInsertJson(
        plan,
        userId: plan.userId.trim().isEmpty ? currentUserId : null,
      );
      final inserted =
          await _client.from(_table).insert(payload).select().single();
      return StudyPlanMapper.fromJson(inserted);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const PrepValidationFailure(
        code: 'missing_study_plan_id',
        message: 'Cannot delete a study plan without an id.',
      );
    }

    try {
      await _client.from(_table).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw PrepErrorMapper.map(error);
    }
  }

  Future<StudyPlan?> _findExistingInScope(String? subjectId) async {
    final trimmedSubject = subjectId?.trim();
    final query = _client.from(_table).select();
    final row = (trimmedSubject == null || trimmedSubject.isEmpty)
        ? await query.isFilter('subject_id', null).maybeSingle()
        : await query.eq('subject_id', trimmedSubject).maybeSingle();
    if (row == null) return null;
    return StudyPlanMapper.fromJson(row);
  }

  void _validateForWrite(StudyPlan plan) {
    if (plan.finishBufferDays < 0 || plan.finishBufferDays > 365) {
      throw const PrepValidationFailure(
        code: 'invalid_finish_buffer',
        message: 'Finish buffer days must be between 0 and 365.',
      );
    }
    if (plan.restDaysPerWeek < 0 || plan.restDaysPerWeek > 6) {
      throw const PrepValidationFailure(
        code: 'invalid_rest_days',
        message: 'Rest days per week must be between 0 and 6.',
      );
    }
    if (plan.maxDailyPace != null && plan.maxDailyPace! <= 0) {
      throw const PrepValidationFailure(
        code: 'invalid_max_daily_pace',
        message: 'Maximum daily pace limit must be greater than zero.',
      );
    }
  }
}
