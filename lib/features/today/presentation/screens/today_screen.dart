import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';
import 'package:job_prep/features/today/presentation/widgets/today_catch_up_card.dart';
import 'package:job_prep/features/today/presentation/widgets/today_deadlines_card.dart';
import 'package:job_prep/features/today/presentation/widgets/today_do_next_card.dart';
import 'package:job_prep/features/today/presentation/widgets/today_exams_card.dart';
import 'package:job_prep/features/today/presentation/widgets/today_header_card.dart';
import 'package:job_prep/features/today/presentation/widgets/today_inbox_time_cards.dart';
import 'package:job_prep/features/today/presentation/widgets/today_revision_card.dart';
import 'package:job_prep/features/today/presentation/widgets/today_study_targets_card.dart';

/// Focused daily command center displayed as the first navigation destination
/// and default post-sign-in landing screen (`/today`).
class TodayScreen extends ConsumerStatefulWidget {
  /// Creates a [TodayScreen].
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
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
    unawaited(ref.read(studyPlansProvider.notifier).refresh());
    unawaited(ref.read(revisionItemsProvider.notifier).refresh());
    unawaited(ref.read(studySessionsProvider.notifier).refresh());
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

    final summaryAsync = ref.watch(todaySummaryProvider);

    return SingleChildScrollView(
      key: const ValueKey('today-scroll-view'),
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: summaryAsync.when(
        loading: () => Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.xxxl),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => GlassCard(
          key: const ValueKey('today-error-card'),
          padding: spacing.insetsAllXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.todayLoadError,
                style: tokens.textStyles.titleMedium,
              ),
              SizedBox(height: spacing.md),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GlassButton(
                  onPressed: _refreshAll,
                  child: Text(l10n.circularsRetryButton),
                ),
              ),
            ],
          ),
        ),
        data: (summary) => _TodayOrderedBody(
          summary: summary,
          visitId: _visitId,
          onRefresh: _refreshAll,
        ),
      ),
    );
  }
}

class _TodayOrderedBody extends StatelessWidget {
  const _TodayOrderedBody({
    required this.summary,
    required this.visitId,
    required this.onRefresh,
  });

  final TodaySummary summary;
  final int visitId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          child: TodayHeaderCard(
            summary: summary,
            visitId: visitId,
            onRefresh: onRefresh,
          ),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 1,
          child: TodayDoNextCard(summary: summary),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 2,
          child: TodayStudyTargetsCard(
            targets: summary.studyTargets,
            visitId: visitId,
          ),
        ),
        if (summary.catchUpNotices.isNotEmpty) ...[
          SizedBox(height: spacing.lg),
          FadeSlideIn(
            index: 3,
            child: TodayCatchUpCard(notices: summary.catchUpNotices),
          ),
        ],
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 4,
          child: TodayRevisionCard(
            summary: summary.revision,
            referenceNow: summary.date,
          ),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 5,
          child: TodayDeadlinesCard(deadlines: summary.deadlinesNext7Days),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 6,
          child: TodayExamsCard(
            exams: summary.examsNext14Days,
            isUtcReference: summary.date.isUtc,
          ),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 7,
          child: TodayInboxCard(inboxCount: summary.inboxCount),
        ),
        SizedBox(height: spacing.lg),
        FadeSlideIn(
          index: 8,
          child: TodayTimeStudiedCard(
            studiedSecondsToday: summary.studiedSecondsToday,
            sessionsTodayCount: summary.sessionsTodayCount,
            hasActiveSessionToday: summary.hasActiveSessionToday,
          ),
        ),
      ],
    );
  }
}
