import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Card widget demonstrating the language switcher with persistence.
class LanguageSwitcherCard extends ConsumerWidget {
  /// Creates a [LanguageSwitcherCard].
  const LanguageSwitcherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return Container(
      padding: spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: colors.glassFill,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.languageSwitcherTitle,
            style: textStyles.titleMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.languageSwitcherSubtitle,
            style: textStyles.bodySmall,
          ),
          SizedBox(height: spacing.md),
          RadioGroup<String>(
            groupValue: currentLocale.languageCode,
            onChanged: (code) {
              if (code != null) {
                unawaited(
                  ref.read(localeProvider.notifier).setLocale(Locale(code)),
                );
              }
            },
            child: Column(
              children: [
                _LanguageOptionTile(
                  label: l10n.languageEnglish,
                  value: 'en',
                  onTap: () => unawaited(
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en')),
                  ),
                ),
                _LanguageOptionTile(
                  label: l10n.languageBangla,
                  value: 'bn',
                  onTap: () => unawaited(
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('bn')),
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

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final textStyles = context.textStyles;

    return InkWell(
      onTap: onTap,
      borderRadius: context.radii.mdRadius,
      child: Padding(
        padding: spacing.insetsVerticalSm + spacing.insetsHorizontalSm,
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
                style: textStyles.bodyMedium.copyWith(
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
