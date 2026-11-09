import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/theme_controller.dart';

/// Card widget demonstrating the theme switcher with persistence.
class ThemeSwitcherCard extends ConsumerWidget {
  /// Creates a [ThemeSwitcherCard].
  const ThemeSwitcherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
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
            l10n.themeSwitcherTitle,
            style: textStyles.titleMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.themeSwitcherSubtitle,
            style: textStyles.bodySmall,
          ),
          SizedBox(height: spacing.md),
          RadioGroup<ThemeMode>(
            groupValue: currentThemeMode,
            onChanged: (mode) {
              if (mode != null) {
                unawaited(
                  ref.read(themeModeProvider.notifier).setThemeMode(mode),
                );
              }
            },
            child: Column(
              children: [
                _ThemeOptionTile(
                  label: l10n.systemTheme,
                  value: ThemeMode.system,
                  onTap: () => unawaited(
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                ),
                _ThemeOptionTile(
                  label: l10n.lightTheme,
                  value: ThemeMode.light,
                  onTap: () => unawaited(
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                ),
                _ThemeOptionTile(
                  label: l10n.darkTheme,
                  value: ThemeMode.dark,
                  onTap: () => unawaited(
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
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

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final ThemeMode value;
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
            Radio<ThemeMode>(
              value: value,
              activeColor: colors.goldAccent,
            ),
            SizedBox(width: spacing.sm),
            Text(
              label,
              style: textStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
