import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_durations.dart';
import 'package:job_prep/core/theme/app_radii.dart';
import 'package:job_prep/core/theme/app_spacing.dart';
import 'package:job_prep/core/theme/app_text_styles.dart';

/// Global design tokens provided via [ThemeExtension].
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  /// Creates an instance of [AppThemeTokens].
  const AppThemeTokens({
    required this.colors,
    required this.spacing,
    required this.radii,
    required this.durations,
    required this.textStyles,
  });

  /// Factory for dark mode design tokens.
  factory AppThemeTokens.dark() {
    final colors = AppColorsToken.dark();
    return AppThemeTokens(
      colors: colors,
      spacing: const AppSpacingToken(),
      radii: const AppRadiiToken(),
      durations: const AppDurationsToken(),
      textStyles: AppTextStylesToken.fromColor(
        primary: colors.textPrimary,
        secondary: colors.textSecondary,
        muted: colors.textMuted,
      ),
    );
  }

  /// Factory for light mode design tokens.
  factory AppThemeTokens.light() {
    final colors = AppColorsToken.light();
    return AppThemeTokens(
      colors: colors,
      spacing: const AppSpacingToken(),
      radii: const AppRadiiToken(),
      durations: const AppDurationsToken(),
      textStyles: AppTextStylesToken.fromColor(
        primary: colors.textPrimary,
        secondary: colors.textSecondary,
        muted: colors.textMuted,
      ),
    );
  }

  /// Color palette tokens.
  final AppColorsToken colors;

  /// Spacing scale tokens.
  final AppSpacingToken spacing;

  /// Border radii tokens (12px card, 8px button).
  final AppRadiiToken radii;

  /// Animation duration tokens.
  final AppDurationsToken durations;

  /// Typography tokens using Inter.
  final AppTextStylesToken textStyles;

  @override
  AppThemeTokens copyWith({
    AppColorsToken? colors,
    AppSpacingToken? spacing,
    AppRadiiToken? radii,
    AppDurationsToken? durations,
    AppTextStylesToken? textStyles,
  }) {
    return AppThemeTokens(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      durations: durations ?? this.durations,
      textStyles: textStyles ?? this.textStyles,
    );
  }

  @override
  AppThemeTokens lerp(
    covariant ThemeExtension<AppThemeTokens>? other,
    double t,
  ) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      colors: colors.lerp(other.colors, t),
      spacing: spacing.lerp(other.spacing, t),
      radii: radii.lerp(other.radii, t),
      durations: durations.lerp(other.durations, t),
      textStyles: textStyles.lerp(other.textStyles, t),
    );
  }
}

/// Convenience extension on [BuildContext] to access design tokens.
extension ThemeTokensContextX on BuildContext {
  /// Access the active [AppThemeTokens].
  AppThemeTokens get tokens => Theme.of(this).extension<AppThemeTokens>()!;

  /// Access color design tokens.
  AppColorsToken get colors => tokens.colors;

  /// Access spacing design tokens.
  AppSpacingToken get spacing => tokens.spacing;

  /// Access border radii design tokens.
  AppRadiiToken get radii => tokens.radii;

  /// Access duration design tokens.
  AppDurationsToken get durations => tokens.durations;

  /// Access typography design tokens.
  AppTextStylesToken get textStyles => tokens.textStyles;
}
