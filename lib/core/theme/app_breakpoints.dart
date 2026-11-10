import 'package:flutter/material.dart';

/// Design tokens for responsive layout breakpoints and content constraints.
@immutable
class AppBreakpointsToken {
  /// Creates an [AppBreakpointsToken].
  const AppBreakpointsToken({
    this.compact = 600.0,
    this.medium = 1024.0,
    this.maxContentWidth = 1200.0,
  });

  /// Breakpoint between compact (phone) and medium (tablet) screens: 600 px.
  final double compact;

  /// Breakpoint between medium (tablet) and expanded (desktop) screens:
  /// 1024 px.
  final double medium;

  /// Maximum content width on desktop / expanded screens: 1200 px.
  final double maxContentWidth;

  /// Whether [width] falls in compact / phone viewport (< 600 px).
  bool isCompact(double width) => width < compact;

  /// Whether [width] falls in medium / tablet viewport (600 - 1024 px).
  bool isMedium(double width) => width >= compact && width <= medium;

  /// Whether [width] falls in expanded / desktop viewport (> 1024 px).
  bool isExpanded(double width) => width > medium;

  /// Linearly interpolates breakpoints.
  AppBreakpointsToken lerp(AppBreakpointsToken? other, double t) {
    if (other == null) return this;
    return AppBreakpointsToken(
      compact: _lerpDouble(compact, other.compact, t),
      medium: _lerpDouble(medium, other.medium, t),
      maxContentWidth: _lerpDouble(maxContentWidth, other.maxContentWidth, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
