import 'package:flutter/material.dart';

/// Design tokens for typography using the Inter font family.
@immutable
class AppTextStylesToken {
  /// Creates an [AppTextStylesToken].
  const AppTextStylesToken({
    required this.headlineLarge,
    required this.headlineMedium,
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  /// Factory creating text styles tuned for light or dark palette colors.
  factory AppTextStylesToken.fromColor({
    required Color primary,
    required Color secondary,
    required Color muted,
  }) {
    const fallbackFonts = ['Noto Sans Bengali', 'sans-serif'];

    return AppTextStylesToken(
      headlineLarge: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ).copyWith(color: primary),
      headlineMedium: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ).copyWith(color: primary),
      titleLarge: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ).copyWith(color: primary),
      titleMedium: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ).copyWith(color: primary),
      bodyLarge: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ).copyWith(color: primary),
      bodyMedium: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ).copyWith(color: secondary),
      bodySmall: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ).copyWith(color: muted),
      labelLarge: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ).copyWith(color: primary),
      labelMedium: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ).copyWith(color: secondary),
      labelSmall: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: fallbackFonts,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ).copyWith(color: muted),
    );
  }

  /// 32px bold
  final TextStyle headlineLarge;

  /// 24px semibold
  final TextStyle headlineMedium;

  /// 20px semibold
  final TextStyle titleLarge;

  /// 16px semibold
  final TextStyle titleMedium;

  /// 16px regular
  final TextStyle bodyLarge;

  /// 14px regular
  final TextStyle bodyMedium;

  /// 12px regular
  final TextStyle bodySmall;

  /// 14px semibold
  final TextStyle labelLarge;

  /// 12px medium
  final TextStyle labelMedium;

  /// 10px medium
  final TextStyle labelSmall;

  /// Linearly interpolates typography tokens.
  AppTextStylesToken lerp(AppTextStylesToken? other, double t) {
    if (other == null) return this;
    return AppTextStylesToken(
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }
}
