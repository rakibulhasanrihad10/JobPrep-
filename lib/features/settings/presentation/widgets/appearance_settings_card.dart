import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';

/// Appearance settings card controlling theme mode (`system`, `light`, `dark`)
/// and the Reduce visual effects switch.
class AppearanceSettingsCard extends ConsumerStatefulWidget {
  /// Creates an [AppearanceSettingsCard].
  const AppearanceSettingsCard({super.key});

  @override
  ConsumerState<AppearanceSettingsCard> createState() =>
      _AppearanceSettingsCardState();
}

class _AppearanceSettingsCardState
    extends ConsumerState<AppearanceSettingsCard> {
  bool _syncWarning = false;

  Future<void> _setThemeMode(ThemeMode mode) async {
    final synced =
        await ref.read(userSettingsProvider.notifier).updateThemeMode(mode);
    if (!mounted) return;
    setState(() => _syncWarning = !synced);
  }

  Future<void> _setReduceEffects(bool enabled) async {
    final synced = await ref
        .read(userSettingsProvider.notifier)
        .updateReduceEffects(enabled: enabled);
    if (!mounted) return;
    setState(() => _syncWarning = !synced);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final currentThemeMode = ref.watch(themeModeProvider);
    final reduceEffects = ref.watch(reduceEffectsProvider);

    return GlassCard(
      key: const ValueKey('settings-appearance-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsAppearanceTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsAppearanceSubtitle,
            style: tokens.textStyles.bodySmall,
          ),
          SizedBox(height: spacing.sm),
          RadioGroup<ThemeMode>(
            groupValue: currentThemeMode,
            onChanged: (mode) {
              if (mode != null) {
                unawaited(_setThemeMode(mode));
              }
            },
            child: Column(
              children: [
                _ThemeOptionTile(
                  key: const ValueKey('settings-theme-system'),
                  label: l10n.systemTheme,
                  value: ThemeMode.system,
                  onTap: () => unawaited(_setThemeMode(ThemeMode.system)),
                ),
                _ThemeOptionTile(
                  key: const ValueKey('settings-theme-light'),
                  label: l10n.lightTheme,
                  value: ThemeMode.light,
                  onTap: () => unawaited(_setThemeMode(ThemeMode.light)),
                ),
                _ThemeOptionTile(
                  key: const ValueKey('settings-theme-dark'),
                  label: l10n.darkTheme,
                  value: ThemeMode.dark,
                  onTap: () => unawaited(_setThemeMode(ThemeMode.dark)),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          InkWell(
            key: const ValueKey('settings-reduce-effects-row'),
            borderRadius: radii.mdRadius,
            onTap: () => unawaited(_setReduceEffects(!reduceEffects)),
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
                          l10n.settingsReduceEffectsLabel,
                          style: tokens.textStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: spacing.xxs),
                        Text(
                          l10n.settingsReduceEffectsHint,
                          style: tokens.textStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Switch(
                    key: const ValueKey('settings-reduce-effects-switch'),
                    value: reduceEffects,
                    onChanged: (val) => unawaited(_setReduceEffects(val)),
                  ),
                ],
              ),
            ),
          ),
          if (_syncWarning) ...[
            SizedBox(height: spacing.xs),
            Text(
              l10n.settingsSyncWarning,
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.warning,
              ),
            ),
          ],
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
    super.key,
  });

  final String label;
  final ThemeMode value;
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
            Radio<ThemeMode>(
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
