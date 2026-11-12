import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';

/// Fallback [StudyPlanRepository] used before Supabase config is provided.
class UnconfiguredStudyPlanRepository implements StudyPlanRepository {
  /// Creates an [UnconfiguredStudyPlanRepository].
  const UnconfiguredStudyPlanRepository();

  static const _failure = UnknownPrepFailure(
    code: 'prep_unconfigured',
    message: 'Study plans storage is not configured.',
  );

  @override
  Future<List<StudyPlan>> getPlans() async => const <StudyPlan>[];

  @override
  Future<StudyPlan> savePlan(StudyPlan plan) =>
      Future<StudyPlan>.error(_failure);

  @override
  Future<void> deletePlan(String id) => Future<void>.error(_failure);
}
