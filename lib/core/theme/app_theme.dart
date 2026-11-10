import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Provides complete light and dark [ThemeData] configurations.
abstract final class AppTheme {
  /// Builds dark mode [ThemeData] in a deep navy and gold aesthetic.
  static ThemeData dark() {
    final tokens = AppThemeTokens.dark();
    final colors = tokens.colors;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        primary: colors.goldAccent,
        secondary: colors.goldAccent,
        error: colors.danger,
        onSurface: colors.textPrimary,
        onPrimary: colors.background,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radii.cardRadius,
          side: BorderSide(color: colors.glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.goldAccent,
          foregroundColor: colors.background,
          elevation: 0,
          textStyle: textStyles.labelLarge,
          padding: tokens.spacing.insetsHorizontalLg +
              tokens.spacing.insetsVerticalMd,
          shape: RoundedRectangleBorder(
            borderRadius: radii.buttonRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.goldAccent,
          side: BorderSide(color: colors.goldAccent),
          textStyle: textStyles.labelLarge,
          padding: tokens.spacing.insetsHorizontalLg +
              tokens.spacing.insetsVerticalMd,
          shape: RoundedRectangleBorder(
            borderRadius: radii.buttonRadius,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: textStyles.headlineLarge,
        headlineMedium: textStyles.headlineMedium,
        titleLarge: textStyles.titleLarge,
        titleMedium: textStyles.titleMedium,
        bodyLarge: textStyles.bodyLarge,
        bodyMedium: textStyles.bodyMedium,
        bodySmall: textStyles.bodySmall,
        labelLarge: textStyles.labelLarge,
        labelMedium: textStyles.labelMedium,
        labelSmall: textStyles.labelSmall,
      ),
      extensions: [tokens],
    );
  }

  /// Builds light mode [ThemeData] in a clean navy and gold aesthetic.
  static ThemeData light() {
    final tokens = AppThemeTokens.light();
    final colors = tokens.colors;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        surface: colors.surface,
        primary: colors.goldAccent,
        secondary: colors.goldAccent,
        error: colors.danger,
        onSurface: colors.textPrimary,
        onPrimary: colors.surface,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radii.cardRadius,
          side: BorderSide(color: colors.glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.goldAccent,
          foregroundColor: colors.surface,
          elevation: 0,
          textStyle: textStyles.labelLarge,
          padding: tokens.spacing.insetsHorizontalLg +
              tokens.spacing.insetsVerticalMd,
          shape: RoundedRectangleBorder(
            borderRadius: radii.buttonRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.goldAccent,
          side: BorderSide(color: colors.goldAccent),
          textStyle: textStyles.labelLarge,
          padding: tokens.spacing.insetsHorizontalLg +
              tokens.spacing.insetsVerticalMd,
          shape: RoundedRectangleBorder(
            borderRadius: radii.buttonRadius,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: textStyles.headlineLarge,
        headlineMedium: textStyles.headlineMedium,
        titleLarge: textStyles.titleLarge,
        titleMedium: textStyles.titleMedium,
        bodyLarge: textStyles.bodyLarge,
        bodyMedium: textStyles.bodyMedium,
        bodySmall: textStyles.bodySmall,
        labelLarge: textStyles.labelLarge,
        labelMedium: textStyles.labelMedium,
        labelSmall: textStyles.labelSmall,
      ),
      extensions: [tokens],
    );
  }
}
