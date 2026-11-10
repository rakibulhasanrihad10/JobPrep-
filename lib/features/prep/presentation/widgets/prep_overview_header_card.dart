import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';

/// Top summary card showing overall preparation progress, subject count,
/// refresh button, and primary add-subject button.
class PrepOverviewHeaderCard extends StatelessWidget {
  /// Creates a [PrepOverviewHeaderCard].
  const PrepOverviewHeaderCard({
    required this.overallProgress,
    required this.subjectCount,
    required this.onAddSubject,
    required this.onRefresh,
    super.key,
  });

  /// Normalized overall progress across all subjects (`0` to `1`).
  final double overallProgress;

  /// Number of user-defined subjects.
  final int subjectCount;

  /// Callback opening the new-subject dialog.
  final VoidCallback onAddSubject;

  /// Callback refreshing subjects and materials.
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return GlassCard(
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedProgressRing(
                value: overallProgress,
                replayKey: 'prep-overall-ring',
                size: spacing.xxxl + spacing.md,
                child: Text(
                  '${PrepL10n.formatPercent(overallProgress, locale)}%',
                  style: tokens.textStyles.labelMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prepTitle,
                      style: tokens.textStyles.headlineMedium,
                    ),
                    SizedBox(height: spacing.xs),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.xxs,
                      children: [
                        Text(
                          l10n.prepOverallProgressLabel,
                          style: tokens.textStyles.bodyMedium,
                        ),
                        Text(
                          l10n.prepSubjectCount(
                            subjectCount,
                            PrepL10n.formatInt(subjectCount, locale),
                          ),
                          style: tokens.textStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.prepRefreshTooltip,
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              GlassButton(
                key: const ValueKey('add-subject-button'),
                variant: GlassButtonVariant.primary,
                leading: Icon(
                  Icons.add,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                onPressed: onAddSubject,
                child: Text(l10n.prepAddSubjectButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
