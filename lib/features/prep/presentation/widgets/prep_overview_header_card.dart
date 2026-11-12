import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';

/// Overall preparation dashboard card showing total completion ring,
/// subjects/materials counts, completed unit totals, refresh, and add CTA.
class PrepOverviewHeaderCard extends StatelessWidget {
  /// Creates a [PrepOverviewHeaderCard].
  const PrepOverviewHeaderCard({
    required this.overallProgress,
    required this.subjectCount,
    required this.materialCount,
    required this.completedUnitsTotal,
    required this.plannedUnitsTotal,
    required this.onAddSubject,
    required this.onRefresh,
    super.key,
    this.replayKey,
    this.onOpenTemplates,
    this.onSaveAsTemplate,
    this.onCreateStudyPlan,
  });

  /// Normalized overall progress across all subjects (`0` to `1`).
  final double overallProgress;

  /// Number of user-defined subjects.
  final int subjectCount;

  /// Total number of study materials across all subjects.
  final int materialCount;

  /// Sum of clamped completed units across all materials.
  final int completedUnitsTotal;

  /// Sum of planned total units across all materials.
  final int plannedUnitsTotal;

  /// Optional animation replay key (bumps when entering Prep tab).
  final Object? replayKey;

  /// Callback opening the new-subject dialog.
  final VoidCallback onAddSubject;

  /// Callback refreshing subjects and materials.
  final VoidCallback onRefresh;

  /// Callback opening the starter & personal templates dialog.
  final VoidCallback? onOpenTemplates;

  /// Callback saving current subjects as a reusable personal template.
  final VoidCallback? onSaveAsTemplate;

  /// Callback opening dialog to create or edit a study plan.
  final VoidCallback? onCreateStudyPlan;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final percentFormatted = PrepL10n.formatPercent(overallProgress, locale);

    return GlassCard(
      key: const ValueKey('prep-overall-card'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedProgressRing(
                value: overallProgress,
                replayKey: replayKey ?? 'prep-overall-ring',
                size: spacing.xxxl + spacing.xl,
                progressColor: colors.goldAccent,
                child: Text(
                  '$percentFormatted%',
                  style: tokens.textStyles.titleMedium.copyWith(
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
                    Text(
                      l10n.prepOverallProgressLabel,
                      style: tokens.textStyles.labelLarge.copyWith(
                        color: colors.goldAccent,
                      ),
                    ),
                    SizedBox(height: spacing.xxs),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.xxs,
                      children: [
                        Text(
                          l10n.prepSubjectCount(
                            subjectCount,
                            PrepL10n.formatInt(subjectCount, locale),
                          ),
                          style: tokens.textStyles.bodyMedium,
                        ),
                        Text(
                          l10n.prepMaterialCount(
                            materialCount,
                            PrepL10n.formatInt(materialCount, locale),
                          ),
                          style: tokens.textStyles.bodyMedium,
                        ),
                      ],
                    ),
                    if (plannedUnitsTotal > 0) ...[
                      SizedBox(height: spacing.xxs),
                      Text(
                        l10n.prepOverallUnitsSummary(
                          PrepL10n.formatInt(completedUnitsTotal, locale),
                          PrepL10n.formatInt(plannedUnitsTotal, locale),
                        ),
                        style: tokens.textStyles.bodySmall,
                      ),
                    ],
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
              if (onOpenTemplates != null)
                GlassButton(
                  key: const ValueKey('open-templates-button'),
                  leading: Icon(
                    Icons.library_add_outlined,
                    size: spacing.lg,
                    color: colors.textPrimary,
                  ),
                  onPressed: onOpenTemplates,
                  child: Text(l10n.prepTemplatesOpenButton),
                ),
              if (subjectCount > 0 && onSaveAsTemplate != null)
                GlassButton(
                  key: const ValueKey('save-as-template-button'),
                  leading: Icon(
                    Icons.bookmark_add_outlined,
                    size: spacing.lg,
                    color: colors.textPrimary,
                  ),
                  onPressed: onSaveAsTemplate,
                  child: Text(l10n.prepSaveAsTemplateButton),
                ),
              if (onCreateStudyPlan != null)
                GlassButton(
                  key: const ValueKey('open-study-plan-button'),
                  leading: Icon(
                    Icons.event_note_outlined,
                    size: spacing.lg,
                    color: colors.textPrimary,
                  ),
                  onPressed: onCreateStudyPlan,
                  child: Text(l10n.prepStudyPlanAddButton),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
