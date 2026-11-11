import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/domain/utils/today_summary_calculator.dart';

/// Clock callback powering the Today screen; defaults to [circularNowProvider]
/// so widget & golden tests share a single frozen clock.
final Provider<DateTime Function()> todayNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(circularNowProvider));

/// Optional UTC offset override used to test local-day session splitting.
final Provider<Duration?> todayOffsetProvider =
    Provider<Duration?>((ref) => null);

/// Live aggregated [TodaySummary] recomputed immediately whenever progress is
/// logged, revisions are completed/snoozed, plans change, or timers save.
final Provider<AsyncValue<TodaySummary>> todaySummaryProvider =
    Provider<AsyncValue<TodaySummary>>((ref) {
  final now = ref.watch(todayNowProvider)();
  final localOffset = ref.watch(todayOffsetProvider);

  final circularsAsync = ref.watch(circularsListProvider);
  final subjectsAsync = ref.watch(subjectsProvider);
  final materialsAsync = ref.watch(allMaterialsProvider);
  final logsAsync = ref.watch(recentProgressLogsProvider);
  final planSnapshotsAsync = ref.watch(studyPlanSnapshotsProvider);
  final revisionAsync = ref.watch(revisionItemsProvider);
  final sessionsAsync = ref.watch(studySessionsProvider);

  final sources = <AsyncValue<Object?>>[
    circularsAsync,
    subjectsAsync,
    materialsAsync,
    logsAsync,
    planSnapshotsAsync,
    revisionAsync,
    sessionsAsync,
  ];
  for (final src in sources) {
    if (src is AsyncError<Object?> && !src.hasValue) {
      return AsyncError<TodaySummary>(src.error, src.stackTrace);
    }
  }
  if (sources.any((s) => s.isLoading && !s.hasValue)) {
    return const AsyncLoading<TodaySummary>();
  }

  return AsyncData<TodaySummary>(
    TodaySummaryCalculator.buildSummary(
      circulars: circularsAsync.asData?.value ?? const <Circular>[],
      subjects: subjectsAsync.asData?.value ?? const <Subject>[],
      materials: materialsAsync.asData?.value ?? const <PrepMaterial>[],
      recentLogs: logsAsync.asData?.value ?? const <ProgressLog>[],
      plans: const <StudyPlan>[],
      planSnapshots:
          planSnapshotsAsync.asData?.value ?? const <StudyPlanSnapshot>[],
      revisionItems: revisionAsync.asData?.value ?? const <RevisionItem>[],
      sessions: sessionsAsync.asData?.value ?? const <StudySession>[],
      now: now,
      localOffset: localOffset,
    ),
  );
});
