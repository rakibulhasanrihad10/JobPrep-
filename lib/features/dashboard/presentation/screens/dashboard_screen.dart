import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/theme_controller.dart';

/// Placeholder dashboard screen demonstrating design tokens and theme switcher.
class DashboardScreen extends ConsumerWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: spacing.insetsAllXl,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'JobPrep Dashboard',
                  style: textStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Job Circular Tracker & Exam Prep Foundations',
                  style: textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.xl),

                // Glassmorphic showcase card
                Container(
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
                        'Theme Mode Switcher',
                        style: textStyles.titleMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        'Choose an appearance mode (persisted with '
                        'SharedPreferences)',
                        style: textStyles.bodySmall,
                      ),
                      SizedBox(height: spacing.md),
                      RadioGroup<ThemeMode>(
                        groupValue: currentThemeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            unawaited(
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(mode),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            _ThemeOptionTile(
                              label: 'System Theme',
                              value: ThemeMode.system,
                              onTap: () => unawaited(
                                ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(ThemeMode.system),
                              ),
                            ),
                            _ThemeOptionTile(
                              label: 'Light Theme (Navy & Gold)',
                              value: ThemeMode.light,
                              onTap: () => unawaited(
                                ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(ThemeMode.light),
                              ),
                            ),
                            _ThemeOptionTile(
                              label: 'Dark Theme (Deep Navy & Gold)',
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
                ),
                SizedBox(height: spacing.lg),

                // Design tokens demonstration card
                Container(
                  padding: spacing.insetsAllLg,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: radii.cardRadius,
                    border: Border.all(color: colors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design Tokens Preview',
                        style: textStyles.titleMedium,
                      ),
                      SizedBox(height: spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Gold Accent Button'),
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Outlined Button'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatusBadge(
                            label: 'Success',
                            color: colors.success,
                          ),
                          _StatusBadge(
                            label: 'Warning',
                            color: colors.warning,
                          ),
                          _StatusBadge(
                            label: 'Danger',
                            color: colors.danger,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return Container(
      padding: spacing.insetsHorizontalMd + spacing.insetsVerticalSm,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: radii.buttonRadius,
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: textStyles.labelSmall.copyWith(
          color: color,
        ),
      ),
    );
  }
}
