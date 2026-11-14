import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';

/// Account-only features gated from guest mode.
enum AccountOnlyFeature {
  /// Multi-device cloud sync and PostgreSQL remote backup.
  cloudSync,

  /// Automated daily circular and exam reminder emails.
  emailReminders,

  /// Private document uploads and attachments.
  fileAttachments,

  /// Permanent account record deletion.
  deleteAccount,
}

/// Feature gate displaying a locked placeholder with a "Create an account"
/// button when the application is running in guest mode, or rendering [child]
/// directly when authenticated.
class AccountFeatureGate extends ConsumerWidget {
  /// Creates an [AccountFeatureGate].
  const AccountFeatureGate({
    required this.feature,
    required this.child,
    super.key,
    this.customTitle,
    this.customDescription,
    this.compact = false,
  });

  /// Feature category determining the locked explanation copy.
  final AccountOnlyFeature feature;

  /// Underlying widget rendered when signed in.
  final Widget child;

  /// Optional title override.
  final String? customTitle;

  /// Optional description override.
  final String? customDescription;

  /// When true, renders a more compact inline locked row.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appMode = ref.watch(appModeProvider);
    if (appMode != AppMode.guest) {
      return child;
    }

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final title = customTitle ??
        switch (feature) {
          AccountOnlyFeature.cloudSync => l10n.accountGateCloudSyncTitle,
          AccountOnlyFeature.emailReminders =>
            l10n.accountGateEmailRemindersTitle,
          AccountOnlyFeature.fileAttachments =>
            l10n.accountGateFileAttachmentsTitle,
          AccountOnlyFeature.deleteAccount =>
            l10n.accountGateDeleteAccountTitle,
        };

    final description = customDescription ?? l10n.accountGateDescription;

    if (compact) {
      return Container(
        key: const ValueKey('account_feature_gate_locked_compact'),
        padding: spacing.insetsAllMd,
        decoration: BoxDecoration(
          color: colors.glassFill,
          borderRadius: tokens.radii.cardRadius,
          border: Border.all(color: colors.glassBorder),
        ),
        child: Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: colors.goldAccent,
                  size: spacing.lg,
                ),
                SizedBox(width: spacing.sm),
                Flexible(
                  child: Text(
                    title,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            GlassButton(
              key: const ValueKey('account_gate_create_account_button'),
              variant: GlassButtonVariant.primary,
              onPressed: () {
                final router = GoRouter.maybeOf(context);
                if (router != null) {
                  router.go(AppRoutePaths.login);
                }
              },
              child: Text(l10n.accountGateCreateAccountButton),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      key: const ValueKey('account_feature_gate_locked_card'),
      padding: spacing.insetsAllXl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: spacing.insetsAllMd,
            decoration: BoxDecoration(
              color: colors.goldAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: spacing.xl,
              color: colors.goldAccent,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            title,
            style: textStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xs),
          Text(
            description,
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.lg),
          GlassButton(
            key: const ValueKey('account_gate_create_account_button'),
            variant: GlassButtonVariant.primary,
            onPressed: () {
              final router = GoRouter.maybeOf(context);
              if (router != null) {
                router.go(AppRoutePaths.login);
              }
            },
            child: Text(l10n.accountGateCreateAccountButton),
          ),
        ],
      ),
    );
  }
}
