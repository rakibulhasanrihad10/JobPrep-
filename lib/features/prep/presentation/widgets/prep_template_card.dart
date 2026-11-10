import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';

/// Card displaying a starter or personal [PrepTemplate] with subject preview
/// chips, already-applied indicator, Customize units CTA, and Apply CTA.
class PrepTemplateCard extends StatelessWidget {
  /// Creates a [PrepTemplateCard].
  const PrepTemplateCard({
    required this.template,
    required this.isAlreadyApplied,
    required this.isBusy,
    required this.isActive,
    required this.onApply,
    required this.onCustomize,
    this.onDelete,
    super.key,
  });

  /// Template pack rendered by this card.
  final PrepTemplate template;

  /// Whether all template subjects & materials already exist in user data.
  final bool isAlreadyApplied;

  /// Disables actions while another template mutation runs.
  final bool isBusy;

  /// Whether this specific template is actively applying/deleting.
  final bool isActive;

  /// Copies subjects & materials directly (with deduplication protection).
  final VoidCallback onApply;

  /// Opens customization dialog allowing user to edit unit counts first.
  final VoidCallback onCustomize;

  /// Optional callback deleting a personal template (`isSystem == false`).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final keyId = template.stableKey;
    final groups = template.groupedSubjects;
    final title = PrepL10n.templateTitle(template, l10n);
    final description = PrepL10n.templateDescription(template, l10n);
    final subjectCountText = l10n.prepSubjectCount(
      template.subjectCount,
      PrepL10n.formatInt(template.subjectCount, locale),
    );
    final materialCountText = l10n.prepMaterialCount(
      template.materialCount,
      PrepL10n.formatInt(template.materialCount, locale),
    );

    return Container(
      key: ValueKey('prep-template-card-$keyId'),
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(
          color: isAlreadyApplied ? colors.success : colors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: tokens.textStyles.titleMedium,
                        ),
                        _TemplateBadge(
                          label: template.isSystem
                              ? l10n.prepTemplateSystemBadge
                              : l10n.prepTemplatePersonalBadge,
                          accentColor: template.isSystem
                              ? colors.goldAccent
                              : colors.info,
                        ),
                        if (isAlreadyApplied)
                          _TemplateBadge(
                            key: ValueKey('template-applied-badge-$keyId'),
                            label: l10n.prepTemplateAppliedBadge,
                            accentColor: colors.success,
                          ),
                      ],
                    ),
                    if (description.trim().isNotEmpty) ...[
                      SizedBox(height: spacing.xxs),
                      Text(
                        description,
                        style: tokens.textStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (!template.isSystem && onDelete != null)
                IconButton(
                  key: ValueKey('delete-template-$keyId'),
                  tooltip: l10n.prepDeleteConfirmButton,
                  onPressed: isBusy ? null : onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: spacing.lg,
                    color: colors.danger,
                  ),
                ),
            ],
          ),
          if (groups.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: [
                for (final group in groups)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: PrepStyleTokens.resolveSubjectColor(
                        group.subjectColor,
                        colors,
                      ).withValues(alpha: 0.12),
                      borderRadius: radii.smRadius,
                      border: Border.all(
                        color: PrepStyleTokens.resolveSubjectColor(
                          group.subjectColor,
                          colors,
                        ).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PrepStyleTokens.resolveSubjectIcon(group.subjectIcon),
                          size: spacing.md,
                          color: PrepStyleTokens.resolveSubjectColor(
                            group.subjectColor,
                            colors,
                          ),
                        ),
                        SizedBox(width: spacing.xxs),
                        Flexible(
                          child: Text(
                            group.subjectName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.textStyles.labelSmall.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.xxs,
                  children: [
                    Text(
                      subjectCountText,
                      style: tokens.textStyles.labelSmall.copyWith(
                        color: colors.goldAccent,
                      ),
                    ),
                    Text(
                      materialCountText,
                      style: tokens.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            alignment: WrapAlignment.end,
            children: [
              if (template.materialCount > 0)
                GlassButton(
                  key: ValueKey('customize-template-$keyId'),
                  onPressed: isBusy ? null : onCustomize,
                  child: Text(l10n.prepTemplateCustomizeButton),
                ),
              GlassButton(
                key: ValueKey('apply-template-$keyId'),
                variant: isAlreadyApplied
                    ? GlassButtonVariant.standard
                    : GlassButtonVariant.primary,
                onPressed: isBusy ? null : onApply,
                child: isActive
                    ? SizedBox(
                        width: spacing.lg,
                        height: spacing.lg,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isAlreadyApplied
                            ? l10n.prepTemplateApplyAgainButton
                            : l10n.prepApplyTemplateButton,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateBadge extends StatelessWidget {
  const _TemplateBadge({
    required this.label,
    required this.accentColor,
    super.key,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: radii.smRadius,
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: tokens.textStyles.labelSmall.copyWith(
          color: tokens.colors.textPrimary,
        ),
      ),
    );
  }
}
