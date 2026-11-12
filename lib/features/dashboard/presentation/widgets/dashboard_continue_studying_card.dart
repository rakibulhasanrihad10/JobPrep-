import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';

/// Shortcut card jumping directly to the study material logged most recently
/// (or guiding new users to start logging in Prep).
class DashboardContinueStudyingCard extends ConsumerWidget {
  /// Creates a [DashboardContinueStudyingCard].
  const DashboardContinueStudyingCard({
    required this.target,
    required this.visitId,
    super.key,
  });

  /// Resolved shortcut target, or `null` when no matching logs exist yet.
  final DashboardContinueStudying? target;

  /// Monotonic visit token replaying the progress bar on tab switches.
  final int visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final router = GoRouter.maybeOf(context);

    final activeTarget = target;
    if (activeTarget == null) {
      return FadeSlideIn(
        index: 5,
        child: GlassCard(
          key: const ValueKey('dashboard-continue-studying-card'),
          padding: spacing.insetsAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.dashboardContinueStudyingTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              Container(
                key: const ValueKey('dashboard-continue-empty'),
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
                      l10n.dashboardContinueStudyingEmptyTitle,
                      style: tokens.textStyles.labelLarge,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.dashboardContinueStudyingEmptyBody,
                      style: tokens.textStyles.bodySmall,
                    ),
                    SizedBox(height: spacing.md),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: GlassButton(
                        key: const ValueKey('dashboard-start-studying-button'),
                        onPressed: () => router?.go('/prep'),
                        child: Text(l10n.dashboardContinueStudyingEmptyAction),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final material = activeTarget.material;
    final subject = activeTarget.subject;
    final log = activeTarget.latestLog;
    final subjectColor = PrepStyleTokens.resolveSubjectColor(
      subject.color,
      colors,
    );
    final targetRoute = '/prep/${subject.id}?material=${material.id}';
    final progressSummary = l10n.dashboardMaterialProgressLine(
      AppFormatters.formatNumber(
        material.completedUnits,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
      AppFormatters.formatNumber(
        material.totalUnits,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
      material.unitLabel,
      PrepL10n.formatPercent(activeTarget.materialProgress, locale),
    );
    final lastLoggedText = l10n.dashboardContinueStudyingLastLogged(
      AppFormatters.formatNumber(
        log.unitsDone,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
      material.unitLabel,
      AppFormatters.formatDate(
        log.loggedOn,
        locale: locale,
        pattern: 'd MMM yyyy',
        useBanglaDigits: useBanglaDigits,
      ),
    );

    return FadeSlideIn(
      index: 5,
      child: GlassCard(
        key: const ValueKey('dashboard-continue-studying-card'),
        padding: spacing.insetsAllLg,
        onTap: () => router?.go(targetRoute),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.dashboardContinueStudyingTitle,
                    style: tokens.textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: spacing.xxxl + spacing.sm,
                  height: spacing.xxxl + spacing.lg,
                  child: MaterialCoverThumbnail(
                    title: material.title,
                    subjectColor: subjectColor,
                    coverImagePath: material.coverImagePath,
                    coverImageUrl: material.coverImageUrl,
                    expand: true,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.sm,
                          vertical: spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.14),
                          borderRadius: radii.smRadius,
                          border: Border.all(
                            color: subjectColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          subject.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tokens.textStyles.labelSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        material.title,
                        style: tokens.textStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        lastLoggedText,
                        style: tokens.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            AnimatedProgressBar(
              value: activeTarget.materialProgress,
              replayKey: 'dash-continue-bar-$visitId',
              height: spacing.xs,
              progressColor: colors.goldAccent,
            ),
            SizedBox(height: spacing.xs),
            Text(
              progressSummary,
              style: tokens.textStyles.labelMedium.copyWith(
                color: colors.goldAccent,
              ),
            ),
            SizedBox(height: spacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GlassButton(
                key: const ValueKey('dashboard-continue-studying-button'),
                variant: GlassButtonVariant.primary,
                onPressed: () => router?.go(targetRoute),
                child: Text(l10n.dashboardContinueStudyingAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
