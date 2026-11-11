import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/widgets/today_section_header.dart';

/// Lists non-archived circular deadlines closing in the next 7 days with
/// live countdowns and color-coded urgency bands.
class TodayDeadlinesCard extends StatelessWidget {
  /// Creates a [TodayDeadlinesCard].
  const TodayDeadlinesCard({
    required this.deadlines,
    super.key,
  });

  /// Chronologically ordered 7-day deadlines from [TodaySummary].
  final List<TodayDeadlineEntry> deadlines;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final router = GoRouter.maybeOf(context);

    return GlassCard(
      key: const ValueKey('today-deadlines-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodaySectionHeader(
            icon: Icons.event_available_outlined,
            title: l10n.todayDeadlinesTitle,
            action: TextButton(
              key: const ValueKey('today-view-all-circulars-btn'),
              onPressed: () => router?.go('/circulars'),
              child: Text(l10n.dashboardViewAllAction),
            ),
          ),
          SizedBox(height: spacing.md),
          if (deadlines.isEmpty)
            Container(
              key: const ValueKey('today-deadlines-empty'),
              padding: spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: radii.cardRadius,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.todayDeadlinesEmptyTitle,
                    style: tokens.textStyles.labelLarge,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.todayDeadlinesEmptyBody,
                    style: tokens.textStyles.bodySmall,
                  ),
                  SizedBox(height: spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GlassButton(
                      onPressed: () => router?.go('/circulars/new'),
                      child: Text(l10n.dashboardWelcomeAddCircular),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < deadlines.length; i++) ...[
              if (i > 0) SizedBox(height: spacing.sm),
              _TodayDeadlineRow(
                entry: deadlines[i],
                onTap: () =>
                    router?.go('/circulars/${deadlines[i].circular.id}'),
              ),
            ],
        ],
      ),
    );
  }
}

class _TodayDeadlineRow extends StatelessWidget {
  const _TodayDeadlineRow({
    required this.entry,
    required this.onTap,
  });

  final TodayDeadlineEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final circular = entry.circular;
    final org = circular.organizationName?.trim();
    final subtitle = (org != null && org.isNotEmpty)
        ? org
        : CircularL10n.sectorLabel(circular.sector, l10n);

    return InkWell(
      key: ValueKey('today-deadline-row-${circular.id}'),
      borderRadius: radii.cardRadius,
      onTap: onTap,
      child: Container(
        padding: spacing.insetsAllMd,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radii.cardRadius,
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circular.title,
                    style: tokens.textStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    subtitle,
                    style: tokens.textStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            CircularDeadlineCountdownBadge(deadline: circular.deadline),
          ],
        ),
      ),
    );
  }
}
