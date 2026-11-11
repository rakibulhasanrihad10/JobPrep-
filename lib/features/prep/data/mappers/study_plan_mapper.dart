import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';

/// Maps between PostgreSQL `public.study_plans` JSON payloads and [StudyPlan].
abstract final class StudyPlanMapper {
  /// Parses a single JSON row returned by PostgREST into [StudyPlan].
  static StudyPlan fromJson(Map<String, dynamic> json) {
    final postponedRaw = json['postponed_material_ids'];
    final postponedIds = postponedRaw is List
        ? postponedRaw
            .map((e) => e?.toString().trim() ?? '')
            .where((id) => id.isNotEmpty)
            .toList(growable: false)
        : const <String>[];

    return StudyPlan(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readOptionalString(
        json,
        'subject_id',
        trimEmptyToNull: true,
      ),
      circularId: PrepJsonHelpers.readOptionalString(
        json,
        'circular_id',
        trimEmptyToNull: true,
      ),
      examDateId: PrepJsonHelpers.readOptionalString(
        json,
        'exam_date_id',
        trimEmptyToNull: true,
      ),
      startDate: PrepJsonHelpers.readRequiredDateOnly(json, 'start_date'),
      targetDate: PrepJsonHelpers.readRequiredDateOnly(json, 'target_date'),
      finishBufferDays: PrepJsonHelpers.readRequiredInt(
        json,
        'finish_buffer_days',
        fallback: 7,
      ).clamp(0, 365),
      restDaysPerWeek: PrepJsonHelpers.readRequiredInt(
        json,
        'rest_days_per_week',
      ).clamp(0, 6),
      extraStudyDays: PrepJsonHelpers.readRequiredInt(
        json,
        'extra_study_days',
      ).clamp(0, 3650),
      maxDailyPace: PrepJsonHelpers.readOptionalInt(json, 'max_daily_pace'),
      initialCompletedUnits: PrepJsonHelpers.readRequiredInt(
        json,
        'initial_completed_units',
      ).clamp(0, 100000000),
      postponedMaterialIds: postponedIds,
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Parses a JSON list returned by PostgREST into immutable [StudyPlan] list.
  static List<StudyPlan> fromJsonList(List<dynamic> rows) {
    return rows
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  /// Converts [plan] into an insert JSON map, letting DB generate `id`.
  static Map<String, dynamic> toInsertJson(
    StudyPlan plan, {
    String? userId,
  }) {
    final resolvedUserId =
        userId?.trim().isNotEmpty == true ? userId!.trim() : plan.userId.trim();
    return <String, dynamic>{
      if (resolvedUserId.isNotEmpty) 'user_id': resolvedUserId,
      ...toUpdateJson(plan),
    };
  }

  /// Converts mutable fields of [plan] into an update JSON map.
  static Map<String, dynamic> toUpdateJson(StudyPlan plan) {
    final normalizedSubject = plan.subjectId?.trim().isNotEmpty == true
        ? plan.subjectId!.trim()
        : null;
    final normalizedCircular = plan.circularId?.trim().isNotEmpty == true
        ? plan.circularId!.trim()
        : null;
    final normalizedExamDate = plan.examDateId?.trim().isNotEmpty == true
        ? plan.examDateId!.trim()
        : null;
    final cleanPostponed = plan.postponedMaterialIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return <String, dynamic>{
      'subject_id': normalizedSubject,
      'circular_id': normalizedCircular,
      'exam_date_id': normalizedExamDate,
      'start_date': PrepJsonHelpers.formatDateOnly(plan.startDate),
      'target_date': PrepJsonHelpers.formatDateOnly(plan.targetDate),
      'finish_buffer_days': plan.finishBufferDays.clamp(0, 365),
      'rest_days_per_week': plan.restDaysPerWeek.clamp(0, 6),
      'extra_study_days': plan.extraStudyDays.clamp(0, 3650),
      'max_daily_pace': (plan.maxDailyPace != null && plan.maxDailyPace! > 0)
          ? plan.maxDailyPace
          : null,
      'initial_completed_units': plan.initialCompletedUnits.clamp(0, 100000000),
      'postponed_material_ids': cleanPostponed,
    };
  }
}
