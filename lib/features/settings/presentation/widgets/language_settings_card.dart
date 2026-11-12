import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';

/// Language settings card selecting English or Bangla and toggling Bangla
/// digits (`০১২৩...`).
class LanguageSettingsCard extends ConsumerWidget {
  /// Creates a [LanguageSettingsCard].
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final currentLocale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return GlassCard(
      key: const ValueKey('settings-language-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsLanguageTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsLanguageSubtitle,
            style: tokens.textStyles.bodySmall,
          ),
          SizedBox(height: spacing.sm),
          RadioGroup<String>(
            groupValue: currentLocale.languageCode,
            onChanged: (code) {
              if (code != null) {
                unawaited(notifier.updateLocale(Locale(code)));
              }
            },
            child: Column(
              children: [
                _LanguageOptionTile(
                  key: const ValueKey('settings-lang-en'),
                  label: l10n.languageEnglish,
                  value: 'en',
                  onTap: () => unawaited(
                    notifier.updateLocale(const Locale('en')),
                  ),
                ),
                _LanguageOptionTile(
                  key: const ValueKey('settings-lang-bn'),
                  label: l10n.languageBangla,
                  value: 'bn',
                  onTap: () => unawaited(
                    notifier.updateLocale(const Locale('bn')),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          InkWell(
            key: const ValueKey('settings-bangla-digits-row'),
            borderRadius: radii.mdRadius,
            onTap: () => unawaited(
              notifier.updateBanglaDigits(enabled: !useBanglaDigits),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsBanglaDigitsLabel,
                          style: tokens.textStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: spacing.xxs),
                        Text(
                          l10n.settingsBanglaDigitsHint,
                          style: tokens.textStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Switch(
                    key: const ValueKey('settings-bangla-digits-switch'),
                    value: useBanglaDigits,
                    onChanged: (val) => unawaited(
                      notifier.updateBanglaDigits(enabled: val),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return InkWell(
      onTap: onTap,
      borderRadius: tokens.radii.mdRadius,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              activeColor: colors.goldAccent,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                label,
                style: tokens.textStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
