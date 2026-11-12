import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_study_plan_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_mutation_state.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [StudyPlanRepository] provider.
final Provider<StudyPlanRepository> studyPlanRepositoryProvider =
    Provider<StudyPlanRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredStudyPlanRepository();
  }
  return SupabaseStudyPlanRepository(client);
});

/// Clock callback used to evaluate study plan day math.
final Provider<DateTime Function()> studyPlanNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(prepNowProvider));

/// Async notifier loading persisted [StudyPlan] records for the active user.
class StudyPlansNotifier extends AsyncNotifier<List<StudyPlan>> {
  @override
  Future<List<StudyPlan>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(studyPlanRepositoryProvider).getPlans();
  }

  /// Reloads study plans from [StudyPlanRepository].
  Future<List<StudyPlan>> refresh() {
    ref.invalidateSelf();
    return future;
  }
}

/// Provides persisted [StudyPlan] configurations for the active user.
final AsyncNotifierProvider<StudyPlansNotifier, List<StudyPlan>>
    studyPlansProvider =
    AsyncNotifierProvider<StudyPlansNotifier, List<StudyPlan>>(
  StudyPlansNotifier.new,
  retry: _noRetry,
);

/// Derives live [StudyPlanSnapshot] view models whenever plans, subjects,
/// materials, progress logs, or linked circulars change.
final Provider<AsyncValue<List<StudyPlanSnapshot>>> studyPlanSnapshotsProvider =
    Provider<AsyncValue<List<StudyPlanSnapshot>>>((ref) {
  final plansAsync = ref.watch(studyPlansProvider);
  final subjectsAsync = ref.watch(subjectsProvider);
  final materialsAsync = ref.watch(allMaterialsProvider);
  final logsAsync = ref.watch(recentProgressLogsProvider);
  final circularsAsync = ref.watch(circularsListProvider);
  final today = ref.watch(studyPlanNowProvider)();

  final criticalSources = <AsyncValue<Object?>>[
    plansAsync,
    subjectsAsync,
    materialsAsync,
    logsAsync,
  ];
  for (final source in criticalSources) {
    if (source is AsyncError<Object?> && !source.hasValue) {
      return AsyncError<List<StudyPlanSnapshot>>(
        source.error,
        source.stackTrace,
      );
    }
  }
  if (criticalSources.any((s) => s.isLoading && !s.hasValue)) {
    return const AsyncLoading<List<StudyPlanSnapshot>>();
  }

  final plans = plansAsync.asData?.value ?? const <StudyPlan>[];
  final subjects = subjectsAsync.asData?.value ?? const <Subject>[];
  final materials = materialsAsync.asData?.value ?? const <PrepMaterial>[];
  final logs = logsAsync.asData?.value ?? const <ProgressLog>[];
  final circulars = circularsAsync.asData?.value ?? const <Circular>[];

  final subjectsById = <String, Subject>{
    for (final s in subjects) s.id: s,
  };
  final circularsById = <String, Circular>{
    for (final c in circulars) c.id: c,
  };

  final snapshots = <StudyPlanSnapshot>[];
  for (final plan in plans) {
    final subject =
        plan.isAllSubjects ? null : subjectsById[plan.subjectId ?? ''];
    if (!plan.isAllSubjects && subject == null) {
      // Skip orphaned plans while subject list catches up cleanly.
      continue;
    }

    final circular =
        plan.circularId != null ? circularsById[plan.circularId!] : null;
    CircularExamDate? examDate;
    if (circular != null && plan.examDateId != null) {
      for (final item in circular.examDates) {
        if (item.id == plan.examDateId) {
          examDate = item;
          break;
        }
      }
    }

    snapshots.add(
      StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: today,
        subject: subject,
        materials: materials,
        recentLogs: logs,
        circular: circular,
        examDate: examDate,
      ),
    );
  }

  snapshots.sort((a, b) {
    if (a.plan.isAllSubjects != b.plan.isAllSubjects) {
      return a.plan.isAllSubjects ? -1 : 1;
    }
    return a.plan.targetDate.compareTo(b.plan.targetDate);
  });

  return AsyncData<List<StudyPlanSnapshot>>(
    List<StudyPlanSnapshot>.unmodifiable(snapshots),
  );
});

/// Combined all-subjects [StudyPlanSnapshot], if one is configured.
final Provider<StudyPlanSnapshot?> combinedStudyPlanSnapshotProvider =
    Provider<StudyPlanSnapshot?>((ref) {
  final snapshots =
      ref.watch(studyPlanSnapshotsProvider).asData?.value ?? const [];
  for (final snapshot in snapshots) {
    if (snapshot.plan.isAllSubjects) return snapshot;
  }
  return null;
});

/// Per-subject [StudyPlanSnapshot] for `subjectId`, if configured.
final ProviderFamily<StudyPlanSnapshot?, String> studyPlanForSubjectProvider =
    Provider.family<StudyPlanSnapshot?, String>((ref, subjectId) {
  final snapshots =
      ref.watch(studyPlanSnapshotsProvider).asData?.value ?? const [];
  for (final snapshot in snapshots) {
    if (snapshot.plan.subjectId == subjectId) return snapshot;
  }
  return null;
});

/// Controller handling study plan creation, updates, deletions, and pace-limit
/// recovery actions (converting rest days, raising pace, postponing materials).
class StudyPlanController extends Notifier<PrepMutationState> {
  @override
  PrepMutationState build() => const PrepMutationState();

  /// Clears any last surfaced study plan mutation error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Creates or updates [plan], automatically snapping baseline completed units
  /// for new plans starting today or later so progress tracking starts clean.
  Future<StudyPlan?> savePlan(StudyPlan plan) async {
    state = state.copyWith(isSubmitting: true, activeId: plan.id, error: null);
    try {
      var candidate = plan;
      if (candidate.id.trim().isEmpty && candidate.initialCompletedUnits == 0) {
        final todayDay = StudyPlanCalculator.normalizeUtcDate(
          ref.read(studyPlanNowProvider)(),
        );
        final startDay = StudyPlanCalculator.normalizeUtcDate(
          candidate.startDate,
        );
        if (!startDay.isBefore(todayDay)) {
          final materials =
              ref.read(allMaterialsProvider).asData?.value ?? const [];
          candidate = candidate.copyWith(
            initialCompletedUnits: _sumCompletedInScope(
              materials,
              subjectId: candidate.isAllSubjects ? null : candidate.subjectId,
            ),
          );
        }
      }

      final saved =
          await ref.read(studyPlanRepositoryProvider).savePlan(candidate);
      await ref.read(studyPlansProvider.notifier).refresh();
      state = state.copyWith(isSubmitting: false, activeId: null);
      return saved;
    } on Object catch (error) {
      state = state.copyWith(isSubmitting: false, activeId: null, error: error);
      return null;
    }
  }

  /// Deletes the study plan identified by [planId].
  Future<bool> deletePlan(String planId) async {
    state = state.copyWith(isSubmitting: true, activeId: planId, error: null);
    try {
      await ref.read(studyPlanRepositoryProvider).deletePlan(planId);
      await ref.read(studyPlansProvider.notifier).refresh();
      state = state.copyWith(isSubmitting: false, activeId: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(isSubmitting: false, activeId: null, error: error);
      return false;
    }
  }

  /// Converts one scheduled weekly rest day into an extra study day cleanly.
  Future<bool> convertRestDayToStudyDay(StudyPlanSnapshot snapshot) async {
    if (!snapshot.hasConvertibleRestDays) return false;
    final updated = snapshot.plan.copyWith(
      extraStudyDays: snapshot.plan.extraStudyDays + 1,
    );
    return (await savePlan(updated)) != null;
  }

  /// Raises [plan]'s daily pace cap to [newLimit].
  Future<bool> raisePaceLimit(StudyPlan plan, int newLimit) async {
    if (newLimit <= 0) return false;
    final updated = plan.copyWith(maxDailyPace: newLimit);
    return (await savePlan(updated)) != null;
  }

  /// Excludes [materialId] from [plan] until manually restored.
  Future<bool> postponeMaterial(StudyPlan plan, String materialId) async {
    final trimmed = materialId.trim();
    if (trimmed.isEmpty || plan.postponedMaterialIds.contains(trimmed)) {
      return false;
    }
    final updated = plan.copyWith(
      postponedMaterialIds: <String>[...plan.postponedMaterialIds, trimmed],
    );
    return (await savePlan(updated)) != null;
  }

  /// Restores a previously postponed [materialId] back into [plan].
  Future<bool> restoreMaterial(StudyPlan plan, String materialId) async {
    final nextIds = plan.postponedMaterialIds
        .where((id) => id != materialId)
        .toList(growable: false);
    if (nextIds.length == plan.postponedMaterialIds.length) return false;
    final updated = plan.copyWith(postponedMaterialIds: nextIds);
    return (await savePlan(updated)) != null;
  }

  static int _sumCompletedInScope(
    Iterable<PrepMaterial> materials, {
    required String? subjectId,
  }) {
    var sum = 0;
    for (final m in materials) {
      if (subjectId != null && m.subjectId != subjectId) continue;
      if (m.totalUnits > 0 && m.completedUnits > 0) {
        sum +=
            m.completedUnits > m.totalUnits ? m.totalUnits : m.completedUnits;
      }
    }
    return sum;
  }
}

/// Provides [StudyPlanController] for saving/updating/deleting study plans
/// and applying pace-warning recovery options.
final NotifierProvider<StudyPlanController, PrepMutationState>
    studyPlanControllerProvider =
    NotifierProvider<StudyPlanController, PrepMutationState>(
  StudyPlanController.new,
);
