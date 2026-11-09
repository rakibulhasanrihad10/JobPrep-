import 'package:flutter/material.dart';

/// Design tokens for border radii across the application.
@immutable
class AppRadiiToken {
  /// Default border radius scale.
  const AppRadiiToken({
    this.sm = 4.0,
    this.md = 8.0,
    this.button = 8.0,
    this.lg = 12.0,
    this.card = 12.0,
    this.xl = 16.0,
  });

  /// Small radius (4.0 dp).
  final double sm;

  /// Medium / standard input radius (8.0 dp).
  final double md;

  /// Strict button radius (8.0 dp - no pill buttons).
  final double button;

  /// Large radius (12.0 dp).
  final double lg;

  /// Strict card radius (12.0 dp).
  final double card;

  /// Extra large radius (16.0 dp).
  final double xl;

  /// Button border radius: 8 px.
  BorderRadius get buttonRadius => BorderRadius.circular(button);

  /// Card border radius: 12 px.
  BorderRadius get cardRadius => BorderRadius.circular(card);

  /// Small border radius: 4 px.
  BorderRadius get smRadius => BorderRadius.circular(sm);

  /// Medium border radius: 8 px.
  BorderRadius get mdRadius => BorderRadius.circular(md);

  /// Large border radius: 12 px.
  BorderRadius get lgRadius => BorderRadius.circular(lg);

  /// Extra-large border radius: 16 px.
  BorderRadius get xlRadius => BorderRadius.circular(xl);

  /// Linearly interpolates radii values.
  AppRadiiToken lerp(AppRadiiToken? other, double t) {
    if (other == null) return this;
    return AppRadiiToken(
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      button: _lerpDouble(button, other.button, t),
      lg: _lerpDouble(lg, other.lg, t),
      card: _lerpDouble(card, other.card, t),
      xl: _lerpDouble(xl, other.xl, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
