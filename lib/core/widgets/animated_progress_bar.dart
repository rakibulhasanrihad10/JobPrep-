import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Animated horizontal progress bar with token-based styling.
///
/// Animates from 0.0 to [value] (clamped to 0.0 - 1.0) using
/// [TweenAnimationBuilder]. Supports replay on tab switches via [replayKey]
/// and immediately renders the target value without animation when
/// [reduceEffectsProvider] is true.
class AnimatedProgressBar extends ConsumerWidget {
  /// Creates an [AnimatedProgressBar].
  const AnimatedProgressBar({
    required this.value,
    super.key,
    this.replayKey,
    this.height,
    this.borderRadius,
    this.progressColor,
    this.backgroundColor,
    this.duration,
    this.curve = Curves.easeOutCubic,
  });

  /// Target progress value between 0.0 and 1.0.
  final double value;

  /// Optional key tied to active tab/screen to trigger replays.
  final Object? replayKey;

  /// Height of the progress bar track. Defaults to tokens.spacing.sm (8.0).
  final double? height;

  /// Rounded corner radius. Defaults to tokens.radii.smRadius (4.0).
  final BorderRadius? borderRadius;

  /// Color of the progressing fill. Defaults to gold accent.
  final Color? progressColor;

  /// Color of the track background. Defaults to elevated surface.
  final Color? backgroundColor;

  /// Animation duration. Defaults to tokens.durations.slow (400ms).
  final Duration? duration;

  /// Animation curve. Defaults to [Curves.easeOutCubic].
  final Curve curve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final durations = tokens.durations;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final clampedValue = value.clamp(0.0, 1.0);
    final effectiveHeight = height ?? spacing.sm;
    final effectiveRadius = borderRadius ?? radii.smRadius;
    final effectiveProgressColor = progressColor ?? colors.goldAccent;
    final effectiveBackgroundColor = backgroundColor ?? colors.surfaceElevated;
    final effectiveDuration =
        reduceEffects ? Duration.zero : (duration ?? durations.slow);

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Container(
        height: effectiveHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: effectiveRadius,
        ),
        child: TweenAnimationBuilder<double>(
          key: replayKey != null ? ValueKey(replayKey) : null,
          tween: Tween<double>(
            begin: reduceEffects ? clampedValue : 0.0,
            end: clampedValue,
          ),
          duration: effectiveDuration,
          curve: curve,
          builder: (context, animatedValue, _) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedValue,
              child: ColoredBox(
                color: effectiveProgressColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
