import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';

/// Displays a study material with cover photo (or glass initial placeholder),
/// kind label, unit breakdown, progress bar, edit, and delete controls.
class MaterialCard extends StatelessWidget {
  /// Creates a [MaterialCard].
  const MaterialCard({
    required this.material,
    required this.subjectColor,
    required this.onEdit,
    required this.onDelete,
    super.key,
    this.replayKey,
  });

  /// Material entity rendered by this card.
  final PrepMaterial material;

  /// Resolved subject accent color used behind cover placeholders and bars.
  final Color subjectColor;

  /// Optional animation replay key when switching tabs or subjects.
  final Object? replayKey;

  /// Opens material edit dialog.
  final VoidCallback onEdit;

  /// Opens material delete confirmation dialog.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final progress = calculateMaterialProgress(material);
    final summary = l10n.prepMaterialProgressSummary(
      PrepL10n.formatInt(material.completedUnits, locale),
      PrepL10n.formatInt(material.totalUnits, locale),
      material.unitLabel,
    );
    final percentText = l10n.prepPercentComplete(
      PrepL10n.formatPercent(progress, locale),
    );

    return Container(
      key: ValueKey('material-card-${material.id}'),
      padding: spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: colors.glassFillSolid,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MaterialCoverThumbnail(
            title: material.title,
            subjectColor: subjectColor,
            coverImagePath: material.coverImagePath,
            coverImageUrl: material.coverImageUrl,
          ),
          SizedBox(width: spacing.md),
          Expanded(
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
                          Text(
                            material.title,
                            style: tokens.textStyles.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: spacing.xs),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.sm,
                              vertical: spacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              borderRadius: radii.smRadius,
                              border: Border.all(color: colors.glassBorder),
                            ),
                            child: Text(
                              PrepL10n.materialKindLabel(material.kind, l10n),
                              style: tokens.textStyles.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: ValueKey('material-edit-${material.id}'),
                      tooltip: l10n.prepEditAction,
                      visualDensity: VisualDensity.compact,
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: spacing.lg + spacing.xxs,
                      ),
                    ),
                    IconButton(
                      key: ValueKey('material-delete-${material.id}'),
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
                SizedBox(height: spacing.md),
                AnimatedProgressBar(
                  value: progress,
                  replayKey: replayKey,
                  progressColor: subjectColor,
                ),
                SizedBox(height: spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        summary,
                        style: tokens.textStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      percentText,
                      style: tokens.textStyles.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
