import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/language_switcher_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/theme_switcher_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/email_reminders_card.dart';
import 'package:job_prep/features/settings/presentation/widgets/in_app_notifications_card.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_security_card.dart';

/// Screen for managing application settings, theme, and language.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return SingleChildScrollView(
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
          const FadeSlideIn(
            index: 2,
            child: ThemeSwitcherCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 3,
            child: LanguageSwitcherCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 4,
            child: EmailRemindersCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 5,
            child: VaultSecurityCard(),
          ),
          SizedBox(height: spacing.lg),
          const FadeSlideIn(
            index: 6,
            child: InAppNotificationsCard(),
          ),
        ],
      ),
    );
  }
}
