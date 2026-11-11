import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';

/// Vertical study material cover card displaying portrait cover art (or tinted
/// glass initial badge), title, thin gold [AnimatedProgressBar], unit stats,
/// edit/delete icons, and quick `+10`/`+20`/`+50`/custom log controls.
class MaterialCard extends StatelessWidget {
  /// Creates a [MaterialCard].
  const MaterialCard({
    required this.material,
    required this.subjectColor,
    required this.onEdit,
    required this.onDelete,
    required this.onQuickLog,
    required this.onOpenLogs,
    super.key,
    this.isLogging = false,
    this.replayKey,
    this.onOpenBookView,
  });

  /// Material entity rendered by this cover card.
  final PrepMaterial material;

  /// Resolved subject accent color used behind cover placeholders.
  final Color subjectColor;

  /// Whether a log request is active for [material].
  final bool isLogging;

  /// Optional animation replay key when switching tabs or subjects.
  final Object? replayKey;

  /// Opens material edit dialog.
  final VoidCallback onEdit;

  /// Opens material delete confirmation dialog.
  final VoidCallback onDelete;

  /// Records a fixed quick increment (`10`, `20`, or `50`).
  final ValueChanged<int> onQuickLog;

  /// Opens custom progress log & history dialog.
  final VoidCallback onOpenLogs;

  /// Optional callback opening interactive 3D book view for books.
  final VoidCallback? onOpenBookView;

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
    final percentText = '${PrepL10n.formatPercent(progress, locale)}%';

    return Container(
      key: ValueKey('material-card-${material.id}'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.glassFillSolid,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: radii.buttonRadius,
            onTap: onOpenLogs,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.80,
                  child: MaterialCoverThumbnail(
                    title: material.title,
                    subjectColor: subjectColor,
                    coverImagePath: material.coverImagePath,
                    coverImageUrl: material.coverImageUrl,
                    expand: true,
                  ),
                ),
                Positioned(
                  top: spacing.xs,
                  right: spacing.xs,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.background.withValues(alpha: 0.78),
                      borderRadius: radii.buttonRadius,
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: l10n.prepEditAction,
                          child: InkWell(
                            key: ValueKey('material-edit-${material.id}'),
                            borderRadius: radii.buttonRadius,
                            onTap: onEdit,
                            child: Padding(
                              padding: spacing.insetsAllXs,
                              child: Icon(
                                Icons.edit_outlined,
                                size: spacing.lg,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: l10n.prepDeleteAction,
                          child: InkWell(
                            key: ValueKey('material-delete-${material.id}'),
                            borderRadius: radii.buttonRadius,
                            onTap: onDelete,
                            child: Padding(
                              padding: spacing.insetsAllXs,
                              child: Icon(
                                Icons.delete_outline,
                                size: spacing.lg,
                                color: colors.danger,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            material.title,
            style: tokens.textStyles.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.sm),
          AnimatedProgressBar(
            value: progress,
            replayKey: replayKey,
            height: spacing.xs,
            progressColor: colors.goldAccent,
          ),
          SizedBox(height: spacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  summary,
                  style: tokens.textStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: spacing.xs),
              Text(
                percentText,
                style: tokens.textStyles.labelMedium.copyWith(
                  color: colors.goldAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final delta in const [10, 20, 50])
                InkWell(
                  key: ValueKey('material-quick-log-$delta-${material.id}'),
                  borderRadius: radii.buttonRadius,
                  onTap: isLogging ? null : () => onQuickLog(delta),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: radii.buttonRadius,
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Text(
                      l10n.prepQuickLogPlus(PrepL10n.formatInt(delta, locale)),
                      style: tokens.textStyles.labelMedium.copyWith(
                        color: colors.goldAccent,
                      ),
                    ),
                  ),
                ),
              InkWell(
                key: ValueKey('material-custom-log-${material.id}'),
                borderRadius: radii.buttonRadius,
                onTap: isLogging ? null : onOpenLogs,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.goldAccentSubtle,
                    borderRadius: radii.buttonRadius,
                    border: Border.all(color: colors.goldAccent),
                  ),
                  child: Text(
                    l10n.prepLogButton,
                    style: tokens.textStyles.labelMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (onOpenBookView != null)
                InkWell(
                  key: ValueKey('material-book-view-${material.id}'),
                  borderRadius: radii.buttonRadius,
                  onTap: isLogging ? null : onOpenBookView,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: radii.buttonRadius,
                      border: Border.all(
                        color: colors.goldAccent.withValues(alpha: 0.60),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: spacing.md,
                          color: colors.goldAccent,
                        ),
                        SizedBox(width: spacing.xs),
                        Flexible(
                          child: Text(
                            l10n.prepOpenBookView,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.textStyles.labelMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
