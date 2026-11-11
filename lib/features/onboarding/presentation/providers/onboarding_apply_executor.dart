import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';

/// Idempotently applies the completed [OnboardingDraft] into user-owned
/// `subjects`, `materials`, `study_plans`, and Inbox `circulars`, ensuring
/// repeated setup runs never duplicate existing items.
Future<void> applyOnboardingDraftSafely({
  required Ref ref,
  required OnboardingDraft draft,
  required DateTime today,
}) async {
  final subjectRepo = ref.read(subjectRepositoryProvider);
  final materialRepo = ref.read(materialRepositoryProvider);
  final planRepo = ref.read(studyPlanRepositoryProvider);
  final circularRepo = ref.read(circularRepositoryProvider);

  final template = OnboardingPlanner.buildTemplateFromDraft(draft.subjects);
  final existingSubjects = await subjectRepo.getSubjects();
  final existingMaterials = await materialRepo.getAllMaterials();

  final copyPlan = PrepTemplatePlanner.buildPlan(
    template: template,
    existingSubjects: existingSubjects,
    existingMaterials: existingMaterials,
  );

  final touchedSubjectIds = <String>{};
  for (final op in copyPlan.operations) {
    final String subjectId;
    if (op.subjectToCreate != null) {
      final created = await subjectRepo.createSubject(op.subjectToCreate!);
      subjectId = created.id;
    } else {
      subjectId = op.existingSubjectId!;
    }
    touchedSubjectIds.add(subjectId);

    for (final mat in op.materialsToCreate) {
      await materialRepo.createMaterial(
        mat.copyWith(subjectId: subjectId),
      );
    }
  }

  final plan = OnboardingPlanner.buildStudyPlanFromDraft(
    draft: draft,
    today: today,
  );
  if (plan != null) {
    await planRepo.savePlan(plan);
  }

  if (draft.circularLink.trim().isNotEmpty) {
    final existingCirculars = await circularRepo.getCirculars();
    final circular = OnboardingPlanner.buildFirstCircularFromDraft(
      draft: draft,
      existingCirculars: existingCirculars,
    );
    if (circular != null) {
      await circularRepo.createCircular(circular);
    }
  }

  for (final subjectId in touchedSubjectIds) {
    ref.invalidate(materialsForSubjectProvider(subjectId));
  }
  await Future.wait(<Future<Object?>>[
    ref.read(subjectsProvider.notifier).refresh(),
    ref.refresh(allMaterialsProvider.future),
    ref.read(studyPlansProvider.notifier).refresh(),
    ref.read(circularsListProvider.notifier).refresh(),
  ]);
}
