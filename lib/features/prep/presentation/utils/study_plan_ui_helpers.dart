import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_pace_warning_box.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Shared styling, localized copy, and recovery dialogs for Study Plans UI.
abstract final class StudyPlanUiHelpers {
  /// Resolves semantic badge color for [status].
  static Color statusColor(StudyScheduleStatus status, AppThemeTokens tokens) {
    return switch (status) {
      StudyScheduleStatus.ahead => tokens.colors.success,
      StudyScheduleStatus.onTrack => tokens.colors.goldAccent,
      StudyScheduleStatus.behind => tokens.colors.danger,
    };
  }

  /// Resolves localized label for [status].
  static String statusLabel(
    StudyScheduleStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      StudyScheduleStatus.ahead => l10n.prepStudyPlanStatusAhead,
      StudyScheduleStatus.onTrack => l10n.prepStudyPlanStatusOnTrack,
      StudyScheduleStatus.behind => l10n.prepStudyPlanStatusBehind,
    };
  }

  /// Formats catch-up daily delta (`+0.4` / `+১.৫` etc.) cleanly.
  static String formatDecimalPace(
    double value, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final safe = value <= 0 ? 0.0 : value;
    final decimals = safe < 1.0 ? 1 : (safe == safe.roundToDouble() ? 0 : 1);
    return AppFormatters.formatNumber(
      safe,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: decimals,
    );
  }

  /// Prompts confirmation before deleting [plan].
  static Future<bool> confirmDeletePlan(
    BuildContext context,
    WidgetRef ref,
    StudyPlan plan,
  ) async {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (dialogContext) => GlassDialog(
        key: ValueKey('delete-study-plan-dialog-${plan.id}'),
        title: Text(
          l10n.prepStudyPlanDeleteTitle,
          style: tokens.textStyles.titleLarge,
        ),
        content: Text(
          l10n.prepStudyPlanDeleteBody,
          style: tokens.textStyles.bodyMedium,
        ),
        actions: [
          GlassButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.circularFormCancelButton),
          ),
          GlassButton(
            key: ValueKey('confirm-delete-study-plan-${plan.id}'),
            variant: GlassButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.prepDeleteConfirmButton,
              style: TextStyle(color: tokens.colors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return false;
    return await ref
        .read(studyPlanControllerProvider.notifier)
        .deletePlan(plan.id);
  }

  /// Prompts the user to raise the plan's `maxDailyPace` above the current cap.
  static Future<bool> promptRaisePaceLimit(
    BuildContext context,
    WidgetRef ref,
    StudyPlanSnapshot snapshot,
  ) async {
    final currentCap = snapshot.plan.maxDailyPace ?? snapshot.todayTarget;
    final suggested = snapshot.todayTarget > currentCap
        ? snapshot.todayTarget
        : currentCap + 5;

    final newLimit = await showGlassDialog<int?>(
      context: context,
      builder: (_) => RaisePaceLimitDialog(
        planId: snapshot.plan.id,
        suggestedLimit: suggested,
      ),
    );

    if (newLimit == null || !context.mounted) return false;
    return await ref
        .read(studyPlanControllerProvider.notifier)
        .raisePaceLimit(snapshot.plan, newLimit);
  }

  /// Shows unfinished materials ordered by priority suggestion so the user
  /// can exclude one lower-priority item from the study plan.
  static Future<bool> promptPostponeMaterial(
    BuildContext context,
    WidgetRef ref,
    StudyPlanSnapshot snapshot,
  ) async {
    final candidates = snapshot.postponableMaterials;
    if (candidates.isEmpty) return false;

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final chosen = await showGlassDialog<PrepMaterial?>(
      context: context,
      builder: (dialogContext) => GlassDialog(
        key: ValueKey('postpone-material-dialog-${snapshot.plan.id}'),
        title: Text(
          l10n.prepStudyPlanPostponeTitle,
          style: tokens.textStyles.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.prepStudyPlanPostponeSubtitle,
                style: tokens.textStyles.bodySmall,
              ),
              SizedBox(height: spacing.md),
              for (final material in candidates) ...[
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: ValueKey('postpone-candidate-${material.id}'),
                    borderRadius: radii.mdRadius,
                    onTap: () => Navigator.of(dialogContext).pop(material),
                    child: Container(
                      padding: spacing.insetsAllMd,
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: radii.mdRadius,
                        border: Border.all(color: colors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.title,
                                  style: tokens.textStyles.labelLarge,
                                ),
                                SizedBox(height: spacing.xxs),
                                Builder(
                                  builder: (_) {
                                    final kindText = PrepL10n.materialKindLabel(
                                      material.kind,
                                      l10n,
                                    );
                                    final remCount = AppFormatters.formatNumber(
                                      material.totalUnits -
                                          material.completedUnits,
                                      locale: locale,
                                    );
                                    final remText =
                                        l10n.prepStudyPlanUnitsCount(
                                      remCount,
                                    );
                                    return Text(
                                      '$kindText · $remText',
                                      style: tokens.textStyles.bodySmall,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.pause_circle_outline_rounded,
                            color: colors.warning,
                            size: spacing.lg,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing.sm),
              ],
            ],
          ),
        ),
        actions: [
          GlassButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.circularFormCancelButton),
          ),
        ],
      ),
    );

    if (chosen == null || !context.mounted) return false;
    return await ref
        .read(studyPlanControllerProvider.notifier)
        .postponeMaterial(snapshot.plan, chosen.id);
  }
}
