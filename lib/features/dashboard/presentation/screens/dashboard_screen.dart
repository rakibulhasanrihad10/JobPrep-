import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/formatters_preview_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/language_switcher_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/theme_switcher_card.dart';
import 'package:job_prep/features/dashboard/presentation/widgets/tokens_preview_card.dart';

/// Placeholder dashboard screen demonstrating design tokens, localization,
/// and theme switcher.
class DashboardScreen extends StatelessWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

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
                  l10n.dashboardTitle,
                  style: textStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.dashboardSubtitle,
                  style: textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.xl),
                const ThemeSwitcherCard(),
                SizedBox(height: spacing.lg),
                const LanguageSwitcherCard(),
                SizedBox(height: spacing.lg),
                const TokensPreviewCard(),
                SizedBox(height: spacing.lg),
                const FormattersPreviewCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
