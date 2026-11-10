import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';

/// Prompts the user to confirm permanent deletion of [circular].
Future<bool> showDeleteCircularDialog(
  BuildContext context, {
  required Circular circular,
}) async {
  final result = await showGlassDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final tokens = dialogContext.tokens;
      final colors = tokens.colors;
      final l10n = dialogContext.l10n;

      return GlassDialog(
        key: const ValueKey('circular-delete-dialog'),
        title: Text(l10n.circularDetailDeleteTitle),
        content: Text(l10n.circularDetailDeleteMessage(circular.title)),
        actions: [
          GlassButton(
            key: const ValueKey('circular-delete-cancel-btn'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.circularFormCancelButton),
          ),
          GlassButton(
            key: const ValueKey('circular-delete-confirm-btn'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            leading: Icon(
              Icons.delete_outline_rounded,
              size: tokens.spacing.lg,
              color: colors.danger,
            ),
            child: Text(
              l10n.circularDetailDeleteAction,
              style:
                  tokens.textStyles.labelLarge.copyWith(color: colors.danger),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Top glass header card for circular detail displaying title, sector,
/// live deadline countdown, navigation button, Edit, and Delete actions.
class CircularDetailHeaderCard extends StatelessWidget {
  /// Creates a [CircularDetailHeaderCard].
  const CircularDetailHeaderCard({
    required this.circular,
    required this.isPane,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
    this.onBackOrClose,
    super.key,
  });

  /// Active circular being viewed.
  final Circular circular;

  /// True when rendered inside the desktop right master-detail pane.
  final bool isPane;

  /// Disables actions while delete/update is running.
  final bool isBusy;

  /// Callback opening the Phase 3D edit form.
  final VoidCallback onEdit;

  /// Callback requesting permanent circular deletion.
  final VoidCallback onDelete;

  /// Callback closing the desktop pane or popping full-screen mobile view.
  final VoidCallback? onBackOrClose;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final orgText = circular.organizationName?.trim().isNotEmpty ?? false
        ? circular.organizationName!.trim()
        : l10n.circularsOrganizationUnspecified;

    return GlassCard(
      key: const ValueKey('circular-detail-header-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onBackOrClose != null) ...[
                  IconButton(
                    key: ValueKey(
                      isPane
                          ? 'circular-detail-close-btn'
                          : 'circular-detail-back-btn',
                    ),
                    tooltip: isPane
                        ? l10n.circularDetailCloseTooltip
                        : l10n.circularDetailBackTooltip,
                    onPressed: isBusy ? null : onBackOrClose,
                    icon: Icon(
                      isPane ? Icons.close_rounded : Icons.arrow_back_rounded,
                      color: colors.goldAccent,
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circular.title,
                        style: textStyles.headlineMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        orgText,
                        style: textStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircularSectorChip(sector: circular.sector),
                if (circular.isQuickCapture)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.goldAccentSubtle,
                      borderRadius: tokens.radii.smRadius,
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Text(
                      l10n.circularDetailQuickCaptureBadge,
                      style: textStyles.labelSmall.copyWith(
                        color: colors.goldAccent,
                      ),
                    ),
                  ),
                CircularDeadlineCountdownBadge(deadline: circular.deadline),
              ],
            ),
            SizedBox(height: spacing.md),
            Divider(color: colors.glassBorder, height: spacing.md),
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              alignment: WrapAlignment.end,
              children: [
                GlassButton(
                  key: const ValueKey('circular-detail-delete-btn'),
                  onPressed: isBusy ? null : onDelete,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    size: spacing.lg,
                    color: isBusy ? colors.textMuted : colors.danger,
                  ),
                  child: Text(
                    l10n.circularDetailDeleteAction,
                    style: textStyles.labelLarge.copyWith(
                      color: isBusy ? colors.textMuted : colors.danger,
                    ),
                  ),
                ),
                GlassButton(
                  key: const ValueKey('circular-detail-edit-btn'),
                  variant: GlassButtonVariant.primary,
                  onPressed: isBusy ? null : onEdit,
                  leading: Icon(Icons.edit_outlined, size: spacing.lg),
                  child: Text(l10n.circularDetailEditAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
