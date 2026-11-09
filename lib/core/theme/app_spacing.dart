import 'package:flutter/material.dart';

/// Design tokens for consistent spacing across layouts.
@immutable
class AppSpacingToken {
  /// Default constant spacing scale.
  const AppSpacingToken({
    this.xxs = 2.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 24.0,
    this.xxl = 32.0,
    this.xxxl = 48.0,
  });

  /// 2.0 dp
  final double xxs;

  /// 4.0 dp
  final double xs;

  /// 8.0 dp
  final double sm;

  /// 12.0 dp
  final double md;

  /// 16.0 dp
  final double lg;

  /// 24.0 dp
  final double xl;

  /// 32.0 dp
  final double xxl;

  /// 48.0 dp
  final double xxxl;

  /// Edge insets helpers.
  EdgeInsets get insetsAllXxs => EdgeInsets.all(xxs);
  EdgeInsets get insetsAllXs => EdgeInsets.all(xs);
  EdgeInsets get insetsAllSm => EdgeInsets.all(sm);
  EdgeInsets get insetsAllMd => EdgeInsets.all(md);
  EdgeInsets get insetsAllLg => EdgeInsets.all(lg);
  EdgeInsets get insetsAllXl => EdgeInsets.all(xl);
  EdgeInsets get insetsAllXxl => EdgeInsets.all(xxl);

  EdgeInsets get insetsHorizontalSm => EdgeInsets.symmetric(horizontal: sm);
  EdgeInsets get insetsHorizontalMd => EdgeInsets.symmetric(horizontal: md);
  EdgeInsets get insetsHorizontalLg => EdgeInsets.symmetric(horizontal: lg);
  EdgeInsets get insetsHorizontalXl => EdgeInsets.symmetric(horizontal: xl);

  EdgeInsets get insetsVerticalSm => EdgeInsets.symmetric(vertical: sm);
  EdgeInsets get insetsVerticalMd => EdgeInsets.symmetric(vertical: md);
  EdgeInsets get insetsVerticalLg => EdgeInsets.symmetric(vertical: lg);

  /// Linearly interpolates spacing values.
  AppSpacingToken lerp(AppSpacingToken? other, double t) {
    if (other == null) return this;
    return AppSpacingToken(
      xxs: _lerpDouble(xxs, other.xxs, t),
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      xxxl: _lerpDouble(xxxl, other.xxxl, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
