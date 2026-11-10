import 'package:flutter/material.dart';

/// Design tokens for colors across light and dark palettes.
@immutable
class AppColorsToken {
  /// Creates an [AppColorsToken].
  const AppColorsToken({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.glassFill,
    required this.glassFillSolid,
    required this.glassBorder,
    required this.goldAccent,
    required this.goldAccentSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// Dark mode palette (deep navy & refined gold).
  factory AppColorsToken.dark() {
    return const AppColorsToken(
      background: Color(0xFF0A0E1A),
      surface: Color(0xFF12182B),
      surfaceElevated: Color(0xFF1B243D),
      glassFill: Color(0x14FFFFFF), // White fill at 8% opacity (6-10% range)
      // Solid translucent fill for reduce effects:
      glassFillSolid: Color(0xFF141A2E),
      glassBorder: Color(0x26FFFFFF), // 1px border at ~15% opacity
      goldAccent: Color(0xFFE5A93C),
      goldAccentSubtle: Color(0x26E5A93C),
      textPrimary: Color(0xFFF1F5F9),
      textSecondary: Color(0xFF94A3B8),
      textMuted: Color(0xFF64748B),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      danger: Color(0xFFEF4444),
    );
  }

  /// Light mode palette (clean light navy & accessible gold).
  factory AppColorsToken.light() {
    return const AppColorsToken(
      background: Color(0xFFF4F6FB),
      surface: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFF8FAFC),
      glassFill: Color(0xB3FFFFFF), // Translucent clean white fill
      glassFillSolid: Color(0xFFFFFFFF), // Solid clean fill for reduce effects
      glassBorder: Color(0x260F172A), // 1px border at ~15% opacity
      goldAccent: Color(0xFFC59128),
      goldAccentSubtle: Color(0x1FC59128),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF475569),
      textMuted: Color(0xFF94A3B8),
      success: Color(0xFF059669),
      warning: Color(0xFFD97706),
      danger: Color(0xFFDC2626),
    );
  }

  /// Scaffold background color.
  final Color background;

  /// Card / Surface color.
  final Color surface;

  /// Elevated surface color.
  final Color surfaceElevated;

  /// Glassmorphic translucent fill color (white at 6-10% opacity in dark mode).
  final Color glassFill;

  /// Solid translucent fill used when reduce effects is enabled.
  final Color glassFillSolid;

  /// Subtle border highlight for glass surfaces (at ~15% opacity).
  final Color glassBorder;

  /// Gold accent color.
  final Color goldAccent;

  /// Soft gold highlight for badges and selection states.
  final Color goldAccentSubtle;

  /// Primary high-contrast text color.
  final Color textPrimary;

  /// Secondary muted text color.
  final Color textSecondary;

  /// Disabled / placeholder text color.
  final Color textMuted;

  /// Semantic success state color.
  final Color success;

  /// Semantic warning state color.
  final Color warning;

  /// Semantic danger / error state color.
  final Color danger;

  /// Linearly interpolates with another [AppColorsToken].
  AppColorsToken lerp(AppColorsToken? other, double t) {
    if (other == null) return this;
    return AppColorsToken(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassFillSolid: Color.lerp(glassFillSolid, other.glassFillSolid, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      goldAccentSubtle:
          Color.lerp(goldAccentSubtle, other.goldAccentSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
