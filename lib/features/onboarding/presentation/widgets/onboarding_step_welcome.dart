import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/glass_card.dart';

/// Step 1: Welcomes the new user and lets them choose Language & Theme live
/// before setting up subjects and schedules.
class OnboardingStepWelcome extends ConsumerWidget {
  /// Creates an [OnboardingStepWelcome].
  const OnboardingStepWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Column(
      key: const ValueKey('onboarding-step-1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: spacing.insetsAllXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: spacing.insetsAllSm,
                decoration: BoxDecoration(
                  color: colors.goldAccentSubtle,
                  borderRadius: radii.buttonRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: colors.goldAccent,
                  size: tokens.textStyles.headlineMedium.fontSize,
                ),
              ),
              SizedBox(height: spacing.md),
              Text(
                l10n.onboardingWelcomeTitle,
                style: tokens.textStyles.headlineMedium,
              ),
              SizedBox(height: spacing.xs),
              Text(
                l10n.onboardingWelcomeSubtitle,
                style: tokens.textStyles.bodyMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.lg),
        GlassCard(
          padding: spacing.insetsAllXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.onboardingLanguageHeading,
                style: tokens.textStyles.titleMedium,
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.sm,
                children: [
                  _ChoiceTile(
                    key: const ValueKey('onboarding-lang-en'),
                    icon: Icons.translate_rounded,
                    label: l10n.languageEnglish,
                    selected: locale.languageCode == 'en',
                    onTap: () => unawaited(
                      ref.read(localeProvider.notifier).setLocale(
                            const Locale('en'),
                          ),
                    ),
                  ),
                  _ChoiceTile(
                    key: const ValueKey('onboarding-lang-bn'),
                    icon: Icons.language_rounded,
                    label: l10n.languageBangla,
                    selected: locale.languageCode == 'bn',
                    onTap: () => unawaited(
                      ref.read(localeProvider.notifier).setLocale(
                            const Locale('bn'),
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.xl),
              Text(
                l10n.onboardingThemeHeading,
                style: tokens.textStyles.titleMedium,
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.sm,
                children: [
                  _ChoiceTile(
                    key: const ValueKey('onboarding-theme-dark'),
                    icon: Icons.dark_mode_outlined,
                    label: l10n.darkTheme,
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => unawaited(
                      ref.read(themeModeProvider.notifier).setThemeMode(
                            ThemeMode.dark,
                          ),
                    ),
                  ),
                  _ChoiceTile(
                    key: const ValueKey('onboarding-theme-light'),
                    icon: Icons.light_mode_outlined,
                    label: l10n.lightTheme,
                    selected: themeMode == ThemeMode.light,
                    onTap: () => unawaited(
                      ref.read(themeModeProvider.notifier).setThemeMode(
                            ThemeMode.light,
                          ),
                    ),
                  ),
                  _ChoiceTile(
                    key: const ValueKey('onboarding-theme-system'),
                    icon: Icons.brightness_auto_outlined,
                    label: l10n.systemTheme,
                    selected: themeMode == ThemeMode.system,
                    onTap: () => unawaited(
                      ref.read(themeModeProvider.notifier).setThemeMode(
                            ThemeMode.system,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Material(
      color: selected ? colors.goldAccentSubtle : colors.surfaceElevated,
      borderRadius: radii.buttonRadius,
      child: InkWell(
        borderRadius: radii.buttonRadius,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: radii.buttonRadius,
            border: Border.all(
              color: selected ? colors.goldAccent : colors.glassBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: tokens.textStyles.titleMedium.fontSize,
                color: selected ? colors.goldAccent : colors.textSecondary,
              ),
              SizedBox(width: spacing.sm),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.textStyles.labelLarge.copyWith(
                    color: selected ? colors.goldAccent : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
