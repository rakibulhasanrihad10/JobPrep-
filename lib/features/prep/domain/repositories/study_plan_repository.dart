import 'package:job_prep/features/prep/domain/entities/study_plan.dart';

/// Repository contract for persisting per-subject and all-subjects study plans
/// (`public.study_plans`).
abstract interface class StudyPlanRepository {
  /// Fetches all study plans owned by the active user ordered by exam date.
  Future<List<StudyPlan>> getPlans();

  /// Creates or updates [plan] and returns the persisted record.
  Future<StudyPlan> savePlan(StudyPlan plan);

  /// Deletes the study plan identified by [id].
  Future<void> deletePlan(String id);
}
