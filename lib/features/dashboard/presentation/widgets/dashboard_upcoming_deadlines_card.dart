import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';

/// Card listing upcoming non-archived circular deadlines with live countdowns
/// and semantic urgency color bands (`green > 7d`, `amber 3-7d`, `red < 3d`).
class DashboardUpcomingDeadlinesCard extends StatelessWidget {
  /// Creates a [DashboardUpcomingDeadlinesCard].
  const DashboardUpcomingDeadlinesCard({
    required this.deadlines,
    super.key,
  });

  /// Chronologically ordered circulars with upcoming deadlines.
  final List<Circular> deadlines;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final router = GoRouter.maybeOf(context);

    return FadeSlideIn(
      index: 6,
      child: GlassCard(
        key: const ValueKey('dashboard-upcoming-deadlines-card'),
        padding: spacing.insetsAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.dashboardUpcomingDeadlinesTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ),
                TextButton(
                  key: const ValueKey('dashboard-view-all-circulars'),
                  onPressed: () => router?.go('/circulars'),
                  child: Text(l10n.dashboardViewAllAction),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            if (deadlines.isEmpty)
              Container(
                key: const ValueKey('dashboard-deadlines-empty'),
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
                      l10n.dashboardUpcomingDeadlinesEmptyTitle,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.dashboardUpcomingDeadlinesEmptyBody,
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
                _DeadlineListRow(
                  circular: deadlines[i],
                  onTap: () => router?.go('/circulars/${deadlines[i].id}'),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _DeadlineListRow extends StatelessWidget {
  const _DeadlineListRow({
    required this.circular,
    required this.onTap,
  });

  final Circular circular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final org = circular.organizationName?.trim();
    final subtitle = (org != null && org.isNotEmpty)
        ? org
        : CircularL10n.sectorLabel(circular.sector, l10n);

    return InkWell(
      key: ValueKey('dashboard-deadline-row-${circular.id}'),
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
