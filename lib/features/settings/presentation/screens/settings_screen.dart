import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/widgets/appearance_settings_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/data_settings_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/email_reminders_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/guest_settings_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/in_app_notifications_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/language_settings_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/profile_settings_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/study_settings_card.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_security_card.dart';

/// Full Settings screen organizing Profile, Appearance, Language,
/// Notifications, Study defaults, Portal Vault Security, and Data Export.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userSettingsProvider);
    final appMode = ref.watch(appModeProvider);
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return SingleChildScrollView(
      key: const ValueKey('settings-scroll-view'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Text(
              l10n.settingsTitle,
              style: textStyles.headlineMedium,
            ),
          ),
          SizedBox(height: spacing.xs),
          FadeSlideIn(
            index: 1,
            child: Text(
              l10n.settingsSubtitle,
              style: textStyles.bodyMedium,
            ),
          ),
          SizedBox(height: spacing.xl),
          FadeSlideIn(
            index: 2,
            child: appMode == AppMode.guest
                ? const GuestSettingsCard()
                : const ProfileSettingsCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 3,
            child: AppearanceSettingsCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 4,
            child: LanguageSettingsCard(),
          ),
          SizedBox(height: spacing.xl),
          FadeSlideIn(
            index: 5,
            child: Text(
              l10n.settingsNotificationsSectionTitle,
              key: const ValueKey('settings-notifications-heading'),
              style: textStyles.titleLarge,
            ),
          ),
          SizedBox(height: spacing.sm),
          const FadeSlideIn(
            index: 6,
            child: EmailRemindersCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 7,
            child: InAppNotificationsCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 8,
            child: StudySettingsCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 9,
            child: VaultSecurityCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 10,
            child: DataSettingsCard(),
          ),
          SizedBox(height: spacing.xl),
          FadeSlideIn(
            index: 11,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  key: const ValueKey('settings-privacy-link'),
                  onPressed: () => context.go(AppRoutePaths.privacy),
                  child: Text(
                    l10n.legalPrivacyPolicyLink,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                  child: Text(
                    '•',
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('settings-terms-link'),
                  onPressed: () => context.go(AppRoutePaths.terms),
                  child: Text(
                    l10n.legalTermsOfServiceLink,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
