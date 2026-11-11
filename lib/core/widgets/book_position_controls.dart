import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Validates whole-number page input against `[0, totalUnits]` cleanly.
({int? page, String? error}) validateBookPageInput({
  required String raw,
  required int totalUnits,
  required AppLocalizations l10n,
  required Locale locale,
}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return (page: null, error: l10n.bookProgressErrorEmpty);
  }
  final normalized = AppFormatters.toEnglishDigits(trimmed);
  final parsed = int.tryParse(normalized);
  if (parsed == null) {
    return (page: null, error: l10n.bookProgressErrorWholeNumber);
  }
  if (parsed < 0) {
    return (page: null, error: l10n.bookProgressErrorBelowZero);
  }
  if (parsed > totalUnits) {
    return (
      page: null,
      error: l10n.bookProgressErrorExceedsTotal(
        AppFormatters.formatNumber(totalUnits, locale: locale),
      ),
    );
  }
  return (page: parsed, error: null);
}

/// Prompts the user to confirm recording a downward book position correction.
Future<bool> showBookPositionCorrectionConfirmDialog(
  BuildContext context, {
  required int currentPage,
  required int targetPage,
  required String unitLabel,
}) async {
  final delta = (targetPage - currentPage).abs();
  final confirmed = await showGlassDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final tokens = dialogContext.tokens;
      final colors = tokens.colors;
      final spacing = tokens.spacing;
      final dL10n = dialogContext.l10n;
      final dLocale = Localizations.localeOf(dialogContext);

      return GlassDialog(
        key: const ValueKey('book-correction-confirm-dialog'),
        title: Text(
          dL10n.bookProgressConfirmCorrectionTitle,
          style: tokens.textStyles.titleLarge,
        ),
        content: Text(
          dL10n.bookProgressConfirmCorrectionBody(
            AppFormatters.formatNumber(currentPage, locale: dLocale),
            AppFormatters.formatNumber(targetPage, locale: dLocale),
            AppFormatters.formatNumber(delta, locale: dLocale),
            unitLabel,
          ),
          style: tokens.textStyles.bodyMedium,
        ),
        actions: [
          GlassButton(
            key: const ValueKey('book-correction-cancel-button'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dL10n.prepCancelButton),
          ),
          GlassButton(
            key: const ValueKey('book-correction-confirm-button'),
            variant: GlassButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            leading: Icon(
              Icons.history,
              size: spacing.lg,
              color: colors.warning,
            ),
            child: Text(dL10n.bookProgressConfirmCorrectionAction),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Side controls column accompanying the 3D book inside `BookProgressView`.
class BookPositionControlsPanel extends StatelessWidget {
  /// Creates a [BookPositionControlsPanel].
  const BookPositionControlsPanel({
    required this.title,
    required this.shownPage,
    required this.totalUnits,
    required this.unitLabel,
    required this.fraction,
    required this.pageController,
    required this.isBusy,
    required this.onInputChanged,
    required this.onSubmit,
    super.key,
    this.lastUpdatedAt,
    this.replayKey,
    this.errorMessage,
    this.statusMessage,
    this.trailingAction,
  });

  /// Book title heading.
  final String title;

  /// Active page displayed (live drag preview or saved page).
  final int shownPage;

  /// Total book pages/units.
  final int totalUnits;

  /// Book unit label (`pages`, etc.).
  final String unitLabel;

  /// Normalized `[0..1]` completion fraction.
  final double fraction;

  /// Text controller backing the quick position input field.
  final TextEditingController pageController;

  /// Whether a save call is active.
  final bool isBusy;

  /// Invoked on input change to clear transient validation banners.
  final VoidCallback onInputChanged;

  /// Triggers validation and commit of [pageController].
  final VoidCallback onSubmit;

  /// Optional last update timestamp.
  final DateTime? lastUpdatedAt;

  /// Replay key driving [AnimatedProgressBar].
  final Object? replayKey;

  /// Optional validation or repository error text.
  final String? errorMessage;

  /// Optional confirmation/success banner text.
  final String? statusMessage;

  /// Optional secondary action button shown beside Save page.
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: tokens.textStyles.titleLarge,
        ),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.bookProgressUnitSummary(
                AppFormatters.formatNumber(shownPage, locale: locale),
                AppFormatters.formatNumber(totalUnits, locale: locale),
                unitLabel,
              ),
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (lastUpdatedAt != null)
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
                  l10n.bookProgressUpdatedOn(
                    AppFormatters.formatDate(
                      lastUpdatedAt!,
                      locale: locale,
                      pattern: 'yMMMd',
                    ),
                  ),
                  style: tokens.textStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        AnimatedProgressBar(
          value: fraction,
          replayKey: replayKey,
          height: spacing.sm,
          progressColor: colors.goldAccent,
        ),
        SizedBox(height: spacing.lg),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.bookProgressPositionPrefix,
              style: tokens.textStyles.bodyMedium,
            ),
            SizedBox(
              width: 88,
              child: GlassTextField(
                key: const ValueKey('book-position-input'),
                controller: pageController,
                enabled: !isBusy,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                onChanged: (_) => onInputChanged(),
              ),
            ),
            Text(
              l10n.bookProgressPositionSuffix(
                AppFormatters.formatNumber(totalUnits, locale: locale),
              ),
              style: tokens.textStyles.bodyMedium,
            ),
          ],
        ),
        SizedBox(height: spacing.xs),
        Text(
          l10n.bookProgressDragHint,
          style: tokens.textStyles.bodySmall.copyWith(
            color: colors.textMuted,
          ),
        ),
        if (errorMessage != null) ...[
          SizedBox(height: spacing.sm),
          Text(
            errorMessage!,
            key: const ValueKey('book-position-validation-error'),
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.danger,
            ),
          ),
        ],
        if (statusMessage != null) ...[
          SizedBox(height: spacing.sm),
          Text(
            statusMessage!,
            key: const ValueKey('book-position-status-message'),
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.success,
            ),
          ),
        ],
        SizedBox(height: spacing.md),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            GlassButton(
              key: const ValueKey('book-position-save-button'),
              variant: GlassButtonVariant.primary,
              leading: isBusy
                  ? SizedBox(
                      width: spacing.lg,
                      height: spacing.lg,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.goldAccent,
                      ),
                    )
                  : null,
              onPressed: isBusy ? null : onSubmit,
              child: Text(l10n.bookProgressSavePosition),
            ),
            if (trailingAction != null) trailingAction!,
          ],
        ),
      ],
    );
  }
}
