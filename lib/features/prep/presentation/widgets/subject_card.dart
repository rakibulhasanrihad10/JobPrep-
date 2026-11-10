import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';

/// Subject list card with color accent, icon badge, exam track, progress bar,
/// reorder controls, edit, and delete actions (no per-row BackdropFilter).
class SubjectCard extends StatelessWidget {
  /// Creates a [SubjectCard].
  const SubjectCard({
    required this.subject,
    required this.index,
    required this.totalCount,
    required this.materials,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    super.key,
    this.replayKey,
  });

  /// Subject model represented by this row.
  final Subject subject;

  /// Zero-based position inside the ordered subject list.
  final int index;

  /// Total number of subjects in the list.
  final int totalCount;

  /// Materials belonging to [subject].
  final List<PrepMaterial> materials;

  /// Whether this subject is active in the desktop master-detail right pane.
  final bool isSelected;

  /// Optional animation replay key when switching tabs.
  final Object? replayKey;

  /// Opens subject detail / selects in desktop pane.
  final VoidCallback onTap;

  /// Opens subject edit dialog.
  final VoidCallback onEdit;

  /// Opens subject delete confirmation dialog.
  final VoidCallback onDelete;

  /// Moves subject one position earlier in order.
  final VoidCallback? onMoveUp;

  /// Moves subject one position later in order.
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final subjectColor = PrepStyleTokens.resolveSubjectColor(
      subject.color,
      colors,
    );
    final progress = calculateSubjectProgress(materials);
    final percentText = l10n.prepPercentComplete(
      PrepL10n.formatPercent(progress, locale),
    );
    final materialCountText = l10n.prepMaterialCount(
      materials.length,
      PrepL10n.formatInt(materials.length, locale),
    );

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      decoration: BoxDecoration(
        color: isSelected
            ? Color.alphaBlend(colors.goldAccentSubtle, colors.surface)
            : colors.glassFillSolid,
        borderRadius: radii.cardRadius,
        border: Border.all(
          color: isSelected ? colors.goldAccent : colors.glassBorder,
        ),
      ),
      child: InkWell(
        key: ValueKey('subject-card-${subject.id}'),
        borderRadius: radii.cardRadius,
        onTap: onTap,
        child: Padding(
          padding: spacing.insetsAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: spacing.xl + spacing.lg,
                    height: spacing.xl + spacing.lg,
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.20),
                      borderRadius: radii.buttonRadius,
                      border: Border.all(
                        color: subjectColor.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Icon(
                      PrepStyleTokens.resolveSubjectIcon(subject.icon),
                      color: subjectColor,
                      size: spacing.xl,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: tokens.textStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing.xs),
                        Wrap(
                          spacing: spacing.sm,
                          runSpacing: spacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                                subject.examType,
                                style: tokens.textStyles.labelSmall.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              materialCountText,
                              style: tokens.textStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Tooltip(
                      message: l10n.prepDragReorderTooltip,
                      child: Padding(
                        padding: spacing.insetsAllXs,
                        child: Icon(
                          Icons.drag_indicator,
                          color: colors.textMuted,
                          size: spacing.lg + spacing.xs,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              AnimatedProgressBar(
                value: progress,
                replayKey: replayKey,
                progressColor: subjectColor,
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      percentText,
                      style: tokens.textStyles.labelMedium,
                    ),
                  ),
                  IconButton(
                    key: ValueKey('subject-move-up-${subject.id}'),
                    tooltip: l10n.prepMoveUpTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: index > 0 ? onMoveUp : null,
                    icon: Icon(
                      Icons.arrow_upward,
                      size: spacing.lg + spacing.xxs,
                    ),
                  ),
                  IconButton(
                    key: ValueKey('subject-move-down-${subject.id}'),
                    tooltip: l10n.prepMoveDownTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: index < totalCount - 1 ? onMoveDown : null,
                    icon: Icon(
                      Icons.arrow_downward,
                      size: spacing.lg + spacing.xxs,
                    ),
                  ),
                  IconButton(
                    key: ValueKey('subject-edit-${subject.id}'),
                    tooltip: l10n.prepEditAction,
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: spacing.lg + spacing.xxs,
                    ),
                  ),
                  IconButton(
                    key: ValueKey('subject-delete-${subject.id}'),
                    tooltip: l10n.prepDeleteAction,
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: colors.danger,
                      size: spacing.lg + spacing.xxs,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
