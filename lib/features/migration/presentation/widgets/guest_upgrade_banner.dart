import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';

/// Gentle card rendered on the Today screen in guest mode inviting the user
/// to create an account to back up and sync their progress.
class GuestUpgradeBanner extends ConsumerWidget {
  /// Creates a [GuestUpgradeBanner].
  const GuestUpgradeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    if (mode?.isGuest != true) return const SizedBox.shrink();

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassCard(
      key: const ValueKey('today-guest-upgrade-banner'),
      padding: spacing.insetsAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_sync_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.todayGuestUpgradeTitle,
                  style: textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.todayGuestUpgradeSubtitle,
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: GlassButton(
              key: const ValueKey('today-guest-upgrade-btn'),
              variant: GlassButtonVariant.primary,
              onPressed: () => context.go(AppRoutePaths.login),
              leading: Icon(Icons.person_add_alt_1_outlined, size: spacing.md),
              child: Text(l10n.todayGuestUpgradeButton),
            ),
          ),
        ],
      ),
    );
  }
}
