import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';

/// Header card rendered above the circular add/edit form sections.
class CircularFormHeaderCard extends StatelessWidget {
  /// Creates a [CircularFormHeaderCard].
  const CircularFormHeaderCard({
    required this.isEditMode,
    required this.isSubmitting,
    required this.onBack,
    super.key,
  });

  /// Whether the form is editing an existing circular.
  final bool isEditMode;

  /// Whether save submission is currently running.
  final bool isSubmitting;

  /// Callback invoked when the header back icon is pressed.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('circular-form-back-btn'),
              tooltip: l10n.circularFormCancelButton,
              onPressed: isSubmitting ? null : onBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: tokens.colors.goldAccent,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditMode
                        ? l10n.circularFormEditTitle
                        : l10n.circularFormAddTitle,
                    style: textStyles.headlineMedium,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    isEditMode
                        ? l10n.circularFormEditSubtitle
                        : l10n.circularFormAddSubtitle,
                    style: textStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error banner surfaced when saving a circular fails on submit.
class CircularFormFailureBanner extends StatelessWidget {
  /// Creates a [CircularFormFailureBanner].
  const CircularFormFailureBanner({
    required this.failure,
    super.key,
  });

  /// Repository failure thrown during form submission.
  final CircularFailure failure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Container(
      key: const ValueKey('circular-form-error-banner'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.14),
        borderRadius: tokens.radii.buttonRadius,
        border: Border.all(color: colors.danger.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.danger),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              CircularL10n.circularErrorMessage(failure, l10n),
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty/missing state card shown when editing a circular id that cannot be
/// loaded.
class CircularFormNotFoundCard extends StatelessWidget {
  /// Creates a [CircularFormNotFoundCard].
  const CircularFormNotFoundCard({
    required this.onBack,
    super.key,
  });

  /// Callback returning to the circular directory.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Padding(
      padding: spacing.insetsAllXl,
      child: GlassCard(
        key: const ValueKey('circular-form-not-found'),
        padding: spacing.insetsAllXxl,
        child: FadeSlideIn(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: colors.goldAccent,
                  size: spacing.xxl,
                ),
                SizedBox(height: spacing.lg),
                Text(
                  l10n.circularFormNotFoundTitle,
                  style: tokens.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.circularFormNotFoundMessage,
                  style: tokens.textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.lg),
                GlassButton(
                  variant: GlassButtonVariant.primary,
                  onPressed: onBack,
                  child: Text(l10n.circularFormBackToList),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom action bar providing Cancel and Save/Save changes actions with loading
/// indicator.
class CircularFormFooterActions extends StatelessWidget {
  /// Creates a [CircularFormFooterActions].
  const CircularFormFooterActions({
    required this.isEditMode,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  /// Whether editing an existing circular vs creating a new one.
  final bool isEditMode;

  /// Whether a save request is currently running.
  final bool isSubmitting;

  /// Callback invoked when Cancel is pressed.
  final VoidCallback onCancel;

  /// Callback invoked when Save is pressed.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Wrap(
      spacing: spacing.md,
      runSpacing: spacing.sm,
      alignment: WrapAlignment.end,
      children: [
        GlassButton(
          key: const ValueKey('circular-form-cancel-btn'),
          onPressed: isSubmitting ? null : onCancel,
          child: Text(l10n.circularFormCancelButton),
        ),
        GlassButton(
          key: const ValueKey('circular-form-submit-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: isSubmitting ? null : onSubmit,
          leading: isSubmitting
              ? SizedBox(
                  width: spacing.lg,
                  height: spacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: spacing.xxs,
                    color: tokens.colors.background,
                  ),
                )
              : const Icon(Icons.save_outlined),
          child: Text(
            isEditMode
                ? l10n.circularFormUpdateButton
                : l10n.circularFormSaveButton,
          ),
        ),
      ],
    );
  }
}

/// Shows a glass confirmation dialog before discarding unsaved circular edits.
Future<bool> showDiscardCircularChangesDialog(BuildContext context) async {
  final l10n = context.l10n;
  final confirmed = await showGlassDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return GlassDialog(
        title: Text(l10n.circularDiscardDialogTitle),
        content: Text(l10n.circularDiscardDialogMessage),
        actions: [
          GlassButton(
            key: const ValueKey('circular-discard-keep-btn'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.circularDiscardKeepEditing),
          ),
          GlassButton(
            key: const ValueKey('circular-discard-confirm-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.circularDiscardConfirm),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
