import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';

/// Injectable clock for Study Analytics evaluations.
final Provider<DateTime Function()> studyAnalyticsNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(prepNowProvider));

/// Optional explicit UTC offset override used in deterministic timezone tests.
final Provider<Duration?> studyAnalyticsOffsetProvider =
    Provider<Duration?>((ref) => null);

/// Manages the selected lookback window (`7 / 30 / 90` days) on Study
/// Analytics.
class StudyAnalyticsRangeNotifier extends Notifier<StudyAnalyticsRange> {
  @override
  StudyAnalyticsRange build() => StudyAnalyticsRange.days7;

  /// Updates the active date window.
  void selectRange(StudyAnalyticsRange range) {
    if (state != range) {
      state = range;
    }
  }
}

/// Provides the selected [StudyAnalyticsRange] (`7`, `30`, or `90` days).
final NotifierProvider<StudyAnalyticsRangeNotifier, StudyAnalyticsRange>
    studyAnalyticsRangeProvider =
    NotifierProvider<StudyAnalyticsRangeNotifier, StudyAnalyticsRange>(
  StudyAnalyticsRangeNotifier.new,
);

/// Manages the optional subject filter on Study Analytics (`null` = all).
class StudyAnalyticsSubjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Sets the selected [subjectId], or clears when `null` or blank.
  void setSubject(String? subjectId) {
    final clean = subjectId?.trim();
    state = (clean == null || clean.isEmpty) ? null : clean;
  }

  /// Clears subject selection back to All subjects.
  void clear() {
    state = null;
  }
}

/// Provides optional selected subject ID for Study Analytics.
final NotifierProvider<StudyAnalyticsSubjectFilterNotifier, String?>
    studyAnalyticsSubjectFilterProvider =
    NotifierProvider<StudyAnalyticsSubjectFilterNotifier, String?>(
  StudyAnalyticsSubjectFilterNotifier.new,
);

/// Derives live [StudyAnalyticsSummary] from `progress_logs`, study plans,
/// subjects, materials, and mock test history.
final Provider<AsyncValue<StudyAnalyticsSummary>>
    studyAnalyticsSummaryProvider = Provider<AsyncValue<StudyAnalyticsSummary>>(
  (ref) {
    final range = ref.watch(studyAnalyticsRangeProvider);
    final subjectFilter = ref.watch(studyAnalyticsSubjectFilterProvider);
    final now = ref.watch(studyAnalyticsNowProvider)();
    final localOffset = ref.watch(studyAnalyticsOffsetProvider);

    final subjectsAsync = ref.watch(subjectsProvider);
    final materialsAsync = ref.watch(allMaterialsProvider);
    final logsAsync = ref.watch(analyticsProgressLogsProvider);
    final plansAsync = ref.watch(studyPlanSnapshotsProvider);
    final mocksAsync = ref.watch(mockTestsProvider);
    final sessionsAsync = ref.watch(studySessionsProvider);

    final sources = <AsyncValue<Object?>>[
      subjectsAsync,
      materialsAsync,
      logsAsync,
      plansAsync,
      mocksAsync,
      sessionsAsync,
    ];
    for (final src in sources) {
      if (src is AsyncError<Object?> && !src.hasValue) {
        return AsyncError<StudyAnalyticsSummary>(src.error, src.stackTrace);
      }
    }
    if (sources.any((s) => s.isLoading && !s.hasValue)) {
      return const AsyncLoading<StudyAnalyticsSummary>();
    }

    final subjects = subjectsAsync.asData?.value ?? const <Subject>[];
    final materials = materialsAsync.asData?.value ?? const <PrepMaterial>[];
    final logs = logsAsync.asData?.value ?? const <ProgressLog>[];
    final planSnapshots =
        plansAsync.asData?.value ?? const <StudyPlanSnapshot>[];
    final mockTests = mocksAsync.asData?.value ?? const <MockTest>[];
    final sessions = sessionsAsync.asData?.value ?? const <StudySession>[];

    final effectiveSubjectFilter =
        (subjectFilter != null && subjects.any((s) => s.id == subjectFilter))
            ? subjectFilter
            : null;

    return AsyncData<StudyAnalyticsSummary>(
      StudyAnalyticsCalculator.buildSummary(
        range: range,
        subjects: subjects,
        materials: materials,
        logs: logs,
        planSnapshots: planSnapshots,
        mockTests: mockTests,
        sessions: sessions,
        now: now,
        localOffset: localOffset,
        subjectId: effectiveSubjectFilter,
      ),
    );
  },
);
