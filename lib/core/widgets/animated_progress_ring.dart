import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Circular progress ring drawn with a [CustomPainter] arc.
///
/// Animates from 0.0 to [value] (clamped to 0.0 - 1.0) using
/// [TweenAnimationBuilder]. Supports replay on tab switches via [replayKey]
/// and immediately renders the target value without animation when
/// [reduceEffectsProvider] is true.
class AnimatedProgressRing extends ConsumerWidget {
  /// Creates an [AnimatedProgressRing].
  const AnimatedProgressRing({
    required this.value,
    super.key,
    this.replayKey,
    this.child,
    this.size = 80.0,
    this.strokeWidth,
    this.progressColor,
    this.trackColor,
    this.strokeCap = StrokeCap.round,
    this.duration,
    this.curve = Curves.easeOutCubic,
  });

  /// Target progress value between 0.0 and 1.0.
  final double value;

  /// Optional key tied to active tab/screen to trigger replays.
  final Object? replayKey;

  /// Optional widget displayed in the center of the ring.
  final Widget? child;

  /// Diameter of the progress ring. Defaults to 80.0.
  final double size;

  /// Width of the ring stroke. Defaults to tokens.spacing.sm (8.0).
  final double? strokeWidth;

  /// Color of the progressing arc. Defaults to gold accent.
  final Color? progressColor;

  /// Color of the background circular track. Defaults to elevated surface.
  final Color? trackColor;

  /// Stroke cap styling at the arc endpoints. Defaults to [StrokeCap.round].
  final StrokeCap strokeCap;

  /// Animation duration. Defaults to tokens.durations.slow (400ms).
  final Duration? duration;

  /// Animation curve. Defaults to [Curves.easeOutCubic].
  final Curve curve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final durations = tokens.durations;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final clampedValue = value.clamp(0.0, 1.0);
    final effectiveStrokeWidth = strokeWidth ?? spacing.sm;
    final effectiveProgressColor = progressColor ?? colors.goldAccent;
    final effectiveTrackColor = trackColor ?? colors.surfaceElevated;
    final effectiveDuration =
        reduceEffects ? Duration.zero : (duration ?? durations.slow);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        key: replayKey != null ? ValueKey(replayKey) : null,
        tween: Tween<double>(
          begin: reduceEffects ? clampedValue : 0.0,
          end: clampedValue,
        ),
        duration: effectiveDuration,
        curve: curve,
        builder: (context, animatedValue, innerChild) {
          return CustomPaint(
            painter: _ProgressRingPainter(
              progress: animatedValue,
              trackColor: effectiveTrackColor,
              progressColor: effectiveProgressColor,
              strokeWidth: effectiveStrokeWidth,
              strokeCap: strokeCap,
            ),
            child: innerChild,
          );
        },
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.strokeCap,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (radius <= 0) return;

    // Background track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.strokeCap != strokeCap;
  }
}
