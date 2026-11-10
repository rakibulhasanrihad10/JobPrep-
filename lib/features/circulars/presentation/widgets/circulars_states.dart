import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';

/// Glass loading indicator card shown while circular data is fetched.
class CircularsLoadingState extends StatelessWidget {
  /// Creates a [CircularsLoadingState].
  const CircularsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('circulars-loading-state'),
      padding: spacing.insetsAllXxl,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.goldAccent),
            SizedBox(height: spacing.lg),
            Text(
              l10n.circularsLoadingMessage,
              style: textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass empty state card for initial zero-items or filtered-out states.
class CircularsEmptyState extends StatelessWidget {
  /// Creates a [CircularsEmptyState].
  const CircularsEmptyState({
    required this.isFiltered,
    super.key,
    this.onClearFilters,
  });

  /// Whether results are empty due to active search/filter criteria.
  final bool isFiltered;

  /// Optional callback clearing filters when [isFiltered] is `true`.
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('circulars-empty-state'),
      padding: spacing.insetsAllXxl,
      child: FadeSlideIn(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.goldAccentSubtle,
                  borderRadius: tokens.radii.buttonRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Icon(
                  isFiltered ? Icons.search_off_rounded : Icons.work_outline,
                  color: colors.goldAccent,
                  size: spacing.xxl,
                ),
              ),
              SizedBox(height: spacing.lg),
              Text(
                isFiltered
                    ? l10n.circularsFilteredEmptyTitle
                    : l10n.circularsEmptyTitle,
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              Text(
                isFiltered
                    ? l10n.circularsFilteredEmptyMessage
                    : l10n.circularsEmptyMessage,
                style: textStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (isFiltered && onClearFilters != null) ...[
                SizedBox(height: spacing.lg),
                GlassButton(
                  key: const ValueKey('circulars-empty-clear-btn'),
                  variant: GlassButtonVariant.primary,
                  onPressed: onClearFilters,
                  child: Text(l10n.circularsClearFilters),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass error card with localized failure messaging and a retry action.
class CircularsErrorState extends StatelessWidget {
  /// Creates a [CircularsErrorState].
  const CircularsErrorState({
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// Failure thrown while fetching circulars.
  final Object error;

  /// Callback triggered when the user presses retry.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('circulars-error-state'),
      padding: spacing.insetsAllXxl,
      borderColor: colors.danger.withValues(alpha: 0.45),
      child: FadeSlideIn(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.14),
                  borderRadius: tokens.radii.buttonRadius,
                  border: Border.all(
                    color: colors.danger.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: colors.danger,
                  size: spacing.xxl,
                ),
              ),
              SizedBox(height: spacing.lg),
              Text(
                l10n.circularsErrorTitle,
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              Text(
                CircularL10n.circularErrorMessage(error, l10n),
                style: textStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.lg),
              GlassButton(
                key: const ValueKey('circulars-retry-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: onRetry,
                leading: const Icon(Icons.refresh_rounded),
                child: Text(l10n.circularsRetryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
