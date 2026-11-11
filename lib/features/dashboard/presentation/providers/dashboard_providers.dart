import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:job_prep/features/dashboard/domain/utils/dashboard_metrics.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

/// Clock callback used for Dashboard deadline/exam windows; inherits
/// [circularNowProvider] by default so tests can freeze a single clock.
final Provider<DateTime Function()> dashboardNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(circularNowProvider));

/// Reactive aggregated summary combining circulars metrics, exam windows,
/// overall preparation progress, and the continue-studying shortcut.
final Provider<AsyncValue<DashboardSummary>> dashboardSummaryProvider =
    Provider<AsyncValue<DashboardSummary>>((ref) {
  final circularsAsync = ref.watch(circularsListProvider);
  final subjectsAsync = ref.watch(subjectsProvider);
  final materialsAsync = ref.watch(allMaterialsProvider);
  final logsAsync = ref.watch(recentProgressLogsProvider);
  final now = ref.watch(dashboardNowProvider)();

  final sources = <AsyncValue<Object?>>[
    circularsAsync,
    subjectsAsync,
    materialsAsync,
    logsAsync,
  ];

  for (final source in sources) {
    if (source is AsyncError<Object?> && !source.hasValue) {
      return AsyncError<DashboardSummary>(source.error, source.stackTrace);
    }
  }

  if (sources.any((s) => s.isLoading && !s.hasValue)) {
    return const AsyncLoading<DashboardSummary>();
  }

  return AsyncData<DashboardSummary>(
    DashboardMetricsCalculator.buildSummary(
      circulars: circularsAsync.asData?.value ?? const <Circular>[],
      subjects: subjectsAsync.asData?.value ?? const <Subject>[],
      materials: materialsAsync.asData?.value ?? const <PrepMaterial>[],
      recentLogs: logsAsync.asData?.value ?? const <ProgressLog>[],
      now: now,
    ),
  );
});
