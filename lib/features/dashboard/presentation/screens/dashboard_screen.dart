import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/dashboard_continue_studying_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/dashboard_metrics_grid.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/dashboard_upcoming_deadlines_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/dashboard_upcoming_exams_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/dashboard_welcome_card.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

/// Home Dashboard summarizing deadlines, inbox items, upcoming exams,
/// submitted applications, overall prep progress, and recent study focus.
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static int _nextVisitId = 0;
  late final int _visitId;

  @override
  void initState() {
    super.initState();
    _visitId = ++_nextVisitId;
  }

  void _refreshAll() {
    unawaited(ref.read(circularsListProvider.notifier).refresh());
    unawaited(ref.read(subjectsProvider.notifier).refresh());
    unawaited(ref.read(allMaterialsProvider.notifier).refresh());
    ref.invalidate(recentProgressLogsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;

    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPad =
        breakpoints.isCompact(viewportWidth) ? spacing.lg : spacing.xl;
    final isWideLayout = viewportWidth >= 900;
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return SingleChildScrollView(
      key: const ValueKey('dashboard-scroll-view'),
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardTitle,
                        style: tokens.textStyles.headlineMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        l10n.dashboardHomeSubtitle,
                        style: tokens.textStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.md),
                IconButton(
                  key: const ValueKey('dashboard-refresh-button'),
                  tooltip: l10n.dashboardRefreshTooltip,
                  onPressed: _refreshAll,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),
          summaryAsync.when(
            loading: () => Padding(
              padding: spacing.insetsAllXl,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => GlassCard(
              key: const ValueKey('dashboard-error-card'),
              padding: spacing.insetsAllXl,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.dashboardLoadError,
                      style: tokens.textStyles.bodyMedium,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  GlassButton(
                    onPressed: _refreshAll,
                    child: Text(l10n.calendarRetry),
                  ),
                ],
              ),
            ),
            data: (summary) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (summary.isBrandNewUser) ...[
                  const DashboardWelcomeCard(),
                  SizedBox(height: spacing.lg),
                ],
                DashboardMetricsGrid(
                  summary: summary,
                  visitId: _visitId,
                ),
                SizedBox(height: spacing.lg),
                if (isWideLayout)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DashboardUpcomingDeadlinesCard(
                              deadlines: summary.upcomingDeadlines,
                            ),
                            SizedBox(height: spacing.lg),
                            DashboardUpcomingExamsCard(
                              exams: summary.upcomingExams,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.lg),
                      Expanded(
                        flex: 5,
                        child: DashboardContinueStudyingCard(
                          target: summary.continueStudying,
                          visitId: _visitId,
                        ),
                      ),
                    ],
                  )
                else ...[
                  DashboardContinueStudyingCard(
                    target: summary.continueStudying,
                    visitId: _visitId,
                  ),
                  SizedBox(height: spacing.lg),
                  DashboardUpcomingDeadlinesCard(
                    deadlines: summary.upcomingDeadlines,
                  ),
                  SizedBox(height: spacing.lg),
                  DashboardUpcomingExamsCard(
                    exams: summary.upcomingExams,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
