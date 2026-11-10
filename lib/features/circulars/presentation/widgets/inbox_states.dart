import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';

/// Error banner shown when skipping or deleting an Inbox item fails.
class InboxFailureBanner extends StatelessWidget {
  /// Creates an [InboxFailureBanner].
  const InboxFailureBanner({
    required this.failure,
    required this.onDismiss,
    super.key,
  });

  /// Failure returned by repository or mutation notifier.
  final CircularFailure failure;

  /// Callback clearing the error banner.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return Container(
      key: const ValueKey('inbox-action-error-banner'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.14),
        borderRadius: tokens.radii.buttonRadius,
        border: Border.all(color: colors.danger.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colors.danger,
            size: spacing.lg,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              CircularL10n.circularErrorMessage(failure, context.l10n),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, color: colors.danger),
          ),
        ],
      ),
    );
  }
}

/// Empty state card shown when no quick-captured items await triage in Inbox.
class InboxEmptyState extends StatelessWidget {
  /// Creates an [InboxEmptyState].
  const InboxEmptyState({
    required this.onQuickCapture,
    super.key,
  });

  /// Callback opening the Quick Capture dialog.
  final VoidCallback onQuickCapture;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('inbox-empty-state'),
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
                  Icons.inbox_outlined,
                  color: colors.goldAccent,
                  size: spacing.xxl,
                ),
              ),
              SizedBox(height: spacing.lg),
              Text(
                l10n.inboxEmptyTitle,
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              Text(
                l10n.inboxEmptyMessage,
                style: textStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.lg),
              GlassButton(
                key: const ValueKey('inbox-empty-capture-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: onQuickCapture,
                leading: Icon(Icons.add_link_rounded, size: spacing.lg),
                child: Text(l10n.quickCaptureButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
