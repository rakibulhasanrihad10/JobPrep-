import 'package:flutter/material.dart';

/// Design tokens for animation and transition durations.
@immutable
class AppDurationsToken {
  /// Default duration constants.
  const AppDurationsToken({
    this.fast = const Duration(milliseconds: 150),
    this.normal = const Duration(milliseconds: 250),
    this.slow = const Duration(milliseconds: 400),
    this.pageTransition = const Duration(milliseconds: 300),
  });

  /// 150ms - fast micro-interactions.
  final Duration fast;

  /// 250ms - standard subtle transitions.
  final Duration normal;

  /// 400ms - deliberate reveals or progress fills.
  final Duration slow;

  /// 300ms - screen / modal transitions.
  final Duration pageTransition;

  /// Linearly interpolates duration values.
  AppDurationsToken lerp(AppDurationsToken? other, double t) {
    if (other == null) return this;
    return AppDurationsToken(
      fast: _lerpDuration(fast, other.fast, t),
      normal: _lerpDuration(normal, other.normal, t),
      slow: _lerpDuration(slow, other.slow, t),
      pageTransition: _lerpDuration(pageTransition, other.pageTransition, t),
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      milliseconds:
          (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t)
              .round(),
    );
  }
}
