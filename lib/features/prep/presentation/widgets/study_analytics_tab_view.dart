import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_analytics_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_daily_bar_chart.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_daily_hours_chart.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_filter_bar.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_heatmap_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_metrics_grid.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_subject_breakdown_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_subject_hours_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_target_banner.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_analytics_weekly_chart.dart';

/// Main Study Analytics view combining filter controls, streak/consistency
/// counters, target warning banner, and `fl_chart` visualizations.
class StudyAnalyticsTabView extends ConsumerWidget {
  /// Creates a [StudyAnalyticsTabView].
  const StudyAnalyticsTabView({
    required this.visitId,
    this.onOpenSubjects,
    super.key,
  });

  /// Monotonic counter incremented when returning to the Analytics tab so
  /// counters and charts replay cleanly from zero.
  final int visitId;

  /// Optional CTA callback switching to the Subjects view when empty.
  final VoidCallback? onOpenSubjects;

  void _refreshSources(WidgetRef ref) {
    ref.invalidate(analyticsProgressLogsProvider);
    unawaited(ref.read(subjectsProvider.notifier).refresh());
    unawaited(ref.read(allMaterialsProvider.notifier).refresh());
    unawaited(ref.read(studyPlansProvider.notifier).refresh());
    unawaited(ref.read(mockTestsProvider.notifier).refresh());
    unawaited(ref.read(studySessionsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final range = ref.watch(studyAnalyticsRangeProvider);
    final subjectFilter = ref.watch(studyAnalyticsSubjectFilterProvider);
    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final summaryAsync = ref.watch(studyAnalyticsSummaryProvider);

    final replayKey =
        'analytics-visit-$visitId-${range.name}-${subjectFilter ?? "all"}';

    return FadeSlideIn(
      child: Column(
        key: const ValueKey('study-analytics-tab-view'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: spacing.insetsAllXl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.prepAnalyticsTitle,
                        style: tokens.textStyles.headlineMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        l10n.prepAnalyticsSubtitle,
                        style: tokens.textStyles.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                IconButton(
                  tooltip: l10n.prepRefreshTooltip,
                  onPressed: () => _refreshSources(ref),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),
          StudyAnalyticsFilterBar(
            range: range,
            subjects: subjects,
            selectedSubjectId: subjectFilter,
            onRangeChanged: (next) => ref
                .read(studyAnalyticsRangeProvider.notifier)
                .selectRange(next),
            onSubjectChanged: (nextId) => ref
                .read(studyAnalyticsSubjectFilterProvider.notifier)
                .setSubject(nextId),
            onClear: () {
              ref
                  .read(studyAnalyticsRangeProvider.notifier)
                  .selectRange(StudyAnalyticsRange.days7);
              ref.read(studyAnalyticsSubjectFilterProvider.notifier).clear();
            },
          ),
          SizedBox(height: spacing.lg),
          summaryAsync.when(
            loading: () => GlassCard(
              key: const ValueKey('analytics-loading'),
              padding: spacing.insetsAllXl,
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: spacing.sm),
                  Text(
                    l10n.prepAnalyticsLoadingLabel,
                    style: tokens.textStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            error: (error, _) => GlassCard(
              key: const ValueKey('analytics-error'),
              padding: spacing.insetsAllLg,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.prepAnalyticsLoadErrorTitle,
                          style: tokens.textStyles.titleMedium.copyWith(
                            color: colors.danger,
                          ),
                        ),
                        SizedBox(height: spacing.xxs),
                        Text(
                          PrepL10n.failureMessage(error, l10n),
                          style: tokens.textStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  GlassButton(
                    key: const ValueKey('analytics-retry-button'),
                    onPressed: () => _refreshSources(ref),
                    child: Text(l10n.calendarRetry),
                  ),
                ],
              ),
            ),
            data: (summary) {
              if (!summary.hasAnyActivity) {
                return GlassCard(
                  key: const ValueKey('analytics-empty'),
                  padding: spacing.insetsAllXl,
                  child: Column(
                    children: [
                      Icon(
                        Icons.query_stats_rounded,
                        size: spacing.xxl,
                        color: colors.goldAccent,
                      ),
                      SizedBox(height: spacing.md),
                      Text(
                        l10n.prepAnalyticsEmptyTitle,
                        style: tokens.textStyles.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        l10n.prepAnalyticsEmptyBody,
                        style: tokens.textStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (onOpenSubjects != null) ...[
                        SizedBox(height: spacing.lg),
                        GlassButton(
                          key: const ValueKey('analytics-empty-open-subjects'),
                          variant: GlassButtonVariant.primary,
                          onPressed: onOpenSubjects,
                          child: Text(l10n.prepAnalyticsEmptyAction),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudyAnalyticsTargetBanner(summary: summary),
                  if (summary.dailyTarget != null &&
                      summary.dailyTarget! > 0 &&
                      summary.targetAlertStatus !=
                          StudyDayTargetStatus.onTrackOrNoTarget)
                    SizedBox(height: spacing.md),
                  StudyAnalyticsMetricsGrid(
                    summary: summary,
                    replayKey: replayKey,
                  ),
                  SizedBox(height: spacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final dailyChart = StudyAnalyticsDailyBarChart(
                        summary: summary,
                        replayKey: replayKey,
                      );
                      final weeklyChart = StudyAnalyticsWeeklyChart(
                        summary: summary,
                        replayKey: replayKey,
                      );
                      if (constraints.maxWidth >= 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: dailyChart),
                            SizedBox(width: spacing.lg),
                            Expanded(flex: 2, child: weeklyChart),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          dailyChart,
                          SizedBox(height: spacing.lg),
                          weeklyChart,
                        ],
                      );
                    },
                  ),
                  SizedBox(height: spacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final hoursDaily = StudyAnalyticsDailyHoursChart(
                        summary: summary,
                        replayKey: replayKey,
                      );
                      final hoursSubject = StudyAnalyticsSubjectHoursCard(
                        summary: summary,
                        replayKey: replayKey,
                      );
                      if (constraints.maxWidth >= 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: hoursDaily),
                            SizedBox(width: spacing.lg),
                            Expanded(flex: 2, child: hoursSubject),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          hoursDaily,
                          SizedBox(height: spacing.lg),
                          hoursSubject,
                        ],
                      );
                    },
                  ),
                  SizedBox(height: spacing.lg),
                  StudyAnalyticsSubjectBreakdownCard(
                    summary: summary,
                    replayKey: replayKey,
                  ),
                  SizedBox(height: spacing.lg),
                  StudyAnalyticsHeatmapCard(
                    summary: summary,
                    replayKey: replayKey,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
