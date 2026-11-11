import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/dashboard_metric_card.dart';

/// Responsive 5-card KPI row/grid displaying all precomputed dashboard metrics
/// with staggered [FadeSlideIn] entrances and replayable counters & ring.
class DashboardMetricsGrid extends StatelessWidget {
  /// Creates a [DashboardMetricsGrid].
  const DashboardMetricsGrid({
    required this.summary,
    required this.visitId,
    super.key,
  });

  /// Precomputed summary metrics rendered by these cards.
  final DashboardSummary summary;

  /// Monotonic visit token forcing replay animations on tab entry.
  final int visitId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final router = GoRouter.maybeOf(context);

    final cards = <Widget>[
      FadeSlideIn(
        child: DashboardCountMetricCard(
          key: const ValueKey('dashboard-metric-deadlines-week'),
          label: l10n.dashboardMetricDeadlinesWeek,
          value: summary.upcomingDeadlinesThisWeekCount,
          replayKey: 'dash-deadlines-week-$visitId',
          icon: Icons.schedule_rounded,
          accentColor: colors.warning,
          onTap: () => router?.go('/circulars'),
        ),
      ),
      FadeSlideIn(
        index: 1,
        child: DashboardCountMetricCard(
          key: const ValueKey('dashboard-metric-inbox'),
          label: l10n.dashboardMetricInbox,
          value: summary.inboxCount,
          replayKey: 'dash-inbox-$visitId',
          icon: Icons.inbox_outlined,
          accentColor: colors.info,
          onTap: () => router?.go('/inbox'),
        ),
      ),
      FadeSlideIn(
        index: 2,
        child: DashboardCountMetricCard(
          key: const ValueKey('dashboard-metric-exams-14d'),
          label: l10n.dashboardMetricExams14Days,
          value: summary.upcomingExamsNext14DaysCount,
          replayKey: 'dash-exams-14d-$visitId',
          icon: Icons.quiz_outlined,
          accentColor: colors.accentSecondary,
          onTap: () => router?.go('/calendar'),
        ),
      ),
      FadeSlideIn(
        index: 3,
        child: DashboardCountMetricCard(
          key: const ValueKey('dashboard-metric-submitted'),
          label: l10n.dashboardMetricSubmitted,
          value: summary.applicationsSubmittedCount,
          replayKey: 'dash-submitted-$visitId',
          icon: Icons.check_circle_outline_rounded,
          accentColor: colors.success,
          onTap: () => router?.go('/circulars'),
        ),
      ),
      FadeSlideIn(
        index: 4,
        child: DashboardPrepProgressMetricCard(
          key: const ValueKey('dashboard-metric-overall-prep'),
          label: l10n.dashboardMetricOverallPrep,
          progress: summary.overallPrepProgress,
          ringReplayKey: 'dash-prep-ring-$visitId',
          counterReplayKey: 'dash-prep-pct-$visitId',
          onTap: () => router?.go('/prep'),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 960) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing.md),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          );
        }

        if (width >= 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) SizedBox(width: spacing.md),
                      Expanded(child: cards[i]),
                    ],
                  ],
                ),
              ),
              SizedBox(height: spacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[3]),
                    SizedBox(width: spacing.md),
                    Expanded(child: cards[4]),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[0]),
                  SizedBox(width: spacing.md),
                  Expanded(child: cards[1]),
                ],
              ),
            ),
            SizedBox(height: spacing.md),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[2]),
                  SizedBox(width: spacing.md),
                  Expanded(child: cards[3]),
                ],
              ),
            ),
            SizedBox(height: spacing.md),
            cards[4],
          ],
        );
      },
    );
  }
}
