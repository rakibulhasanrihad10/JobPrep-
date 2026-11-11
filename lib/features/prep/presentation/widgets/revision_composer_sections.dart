import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_chip.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/presentation/utils/revision_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_composer_chips.dart';

export 'package:job_prep/features/prep/presentation/widgets/revision_composer_chips.dart';

/// Header row inside `RevisionFlagComposer` showing the flag title and optional
/// close/done button when embedded inline inside another dialog.
class RevisionComposerHeader extends StatelessWidget {
  /// Creates a [RevisionComposerHeader].
  const RevisionComposerHeader({
    required this.isBusy,
    super.key,
    this.onClose,
  });

  /// Disables close while a write is running.
  final bool isBusy;

  /// Optional callback collapsing the inline composer.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Row(
      children: [
        Icon(
          Icons.flag_outlined,
          size: spacing.lg,
          color: colors.goldAccent,
        ),
        SizedBox(width: spacing.xs),
        Expanded(
          child: Text(
            l10n.prepRevisionMarkAction,
            style: tokens.textStyles.titleMedium,
          ),
        ),
        if (onClose != null)
          TextButton(
            key: const ValueKey('revision-composer-hide-button'),
            onPressed: isBusy ? null : onClose,
            child: Text(l10n.prepRevisionDoneFlaggingButton),
          ),
      ],
    );
  }
}

/// Selector row choosing why an item is flagged for revision.
class RevisionReasonSelector extends StatelessWidget {
  /// Creates a [RevisionReasonSelector].
  const RevisionReasonSelector({
    required this.selectedReason,
    required this.isBusy,
    required this.onSelectReason,
    super.key,
  });

  /// Active selected reason.
  final RevisionReason selectedReason;

  /// Disables selection while saving.
  final bool isBusy;

  /// Invoked when the user chooses a reason pill.
  final ValueChanged<RevisionReason> onSelectReason;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.prepRevisionReasonLabel,
          style: tokens.textStyles.labelMedium,
        ),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (final reason in RevisionReason.values)
              GlassChip(
                key: ValueKey('revision-reason-${reason.value}'),
                label: Text(RevisionL10n.reasonLabel(reason, l10n)),
                isSelected: selectedReason == reason,
                onTap: isBusy ? null : () => onSelectReason(reason),
              ),
          ],
        ),
      ],
    );
  }
}

/// Submit button paired with the live session added badge and chip summary.
class RevisionComposerSubmitBar extends StatelessWidget {
  /// Creates a [RevisionComposerSubmitBar].
  const RevisionComposerSubmitBar({
    required this.addedItems,
    required this.isBusy,
    required this.locale,
    required this.useBanglaDigits,
    required this.onSubmit,
    super.key,
  });

  /// Flags created during this dialog session.
  final List<RevisionItem> addedItems;

  /// Disables submission while saving.
  final bool isBusy;

  /// Active UI locale.
  final Locale locale;

  /// Whether Bangla numerals are active.
  final bool useBanglaDigits;

  /// Submits the current draft flag.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassButton(
              key: const ValueKey('revision-add-flag-button'),
              variant: GlassButtonVariant.primary,
              onPressed: isBusy ? null : onSubmit,
              leading: Icon(
                Icons.add_circle_outline,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              child: Text(l10n.prepRevisionAddAnotherButton),
            ),
            if (addedItems.isNotEmpty)
              Container(
                key: const ValueKey('revision-session-added-badge'),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                  border: Border.all(
                    color: colors.success.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  l10n.prepRevisionAddedCountChip(
                    addedItems.length,
                    AppFormatters.formatNumber(
                      addedItems.length,
                      locale: locale,
                      useBanglaDigits: useBanglaDigits,
                    ),
                  ),
                  style: tokens.textStyles.labelMedium.copyWith(
                    color: colors.success,
                  ),
                ),
              ),
          ],
        ),
        if (addedItems.isNotEmpty) ...[
          SizedBox(height: spacing.xs),
          RevisionSessionAddedSummary(
            addedItems: addedItems,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
        ],
      ],
    );
  }
}
