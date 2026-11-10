import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_badges.dart';

/// Solid translucent row card representing a quick-captured [Circular] awaiting
/// triage in Inbox (no per-row blur for smooth scrolling performance).
class InboxItemCard extends ConsumerWidget {
  /// Creates an [InboxItemCard].
  const InboxItemCard({
    required this.circular,
    required this.index,
    required this.isBusy,
    required this.onCompleteDetails,
    required this.onSkip,
    required this.onDelete,
    super.key,
  });

  /// Quick-captured circular item.
  final Circular circular;

  /// List index controlling entrance stagger.
  final int index;

  /// Disables row actions while Skip or Delete is in flight.
  final bool isBusy;

  /// Opens the full circular form from Phase 3D.
  final VoidCallback onCompleteDetails;

  /// Skips the item by moving it out of Inbox to archived.
  final VoidCallback onSkip;

  /// Permanently deletes the item.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final capturedTimestamp = circular.createdAt ?? circular.updatedAt;
    final capturedLabel = capturedTimestamp != null
        ? l10n.inboxCapturedOn(
            AppFormatters.formatDate(
              capturedTimestamp.toLocal(),
              locale: locale,
              pattern: 'd MMM yyyy',
              useBanglaDigits: useBanglaDigits,
            ),
          )
        : null;

    final linkText = circular.circularUrl?.trim();

    return Container(
      key: ValueKey('inbox-item-${circular.id}'),
      padding: spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: colors.glassFillSolid,
        borderRadius: tokens.radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: FadeSlideIn(
        index: index.clamp(0, 8),
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
                        circular.title,
                        style: textStyles.titleMedium,
                      ),
                      if (linkText != null && linkText.isNotEmpty) ...[
                        SizedBox(height: spacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: spacing.xxs / 2),
                              child: Icon(
                                Icons.link_rounded,
                                size: spacing.lg,
                                color: colors.goldAccent,
                              ),
                            ),
                            SizedBox(width: spacing.xs),
                            Expanded(
                              child: Text(
                                linkText,
                                style: textStyles.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBusy) ...[
                  SizedBox(width: spacing.sm),
                  SizedBox(
                    width: spacing.lg,
                    height: spacing.lg,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.goldAccent,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.lg,
              runSpacing: spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircularDeadlineCountdownBadge(
                  deadline: circular.deadline,
                ),
                if (capturedLabel != null)
                  Text(
                    capturedLabel,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
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
                  key: ValueKey('inbox-delete-btn-${circular.id}'),
                  onPressed: isBusy ? null : onDelete,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    size: spacing.lg,
                    color: isBusy ? colors.textMuted : colors.danger,
                  ),
                  child: Text(
                    l10n.inboxDeleteAction,
                    style: textStyles.labelLarge.copyWith(
                      color: isBusy ? colors.textMuted : colors.danger,
                    ),
                  ),
                ),
                GlassButton(
                  key: ValueKey('inbox-skip-btn-${circular.id}'),
                  onPressed: isBusy ? null : onSkip,
                  leading: Icon(
                    Icons.archive_outlined,
                    size: spacing.lg,
                  ),
                  child: Text(l10n.inboxSkipAction),
                ),
                GlassButton(
                  key: ValueKey('inbox-complete-btn-${circular.id}'),
                  variant: GlassButtonVariant.primary,
                  onPressed: isBusy ? null : onCompleteDetails,
                  leading: Icon(
                    Icons.edit_note_rounded,
                    size: spacing.lg,
                  ),
                  child: Text(l10n.inboxCompleteDetailsAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
