import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Entrance animation wrapper that fades in and performs a subtle upward slide.
///
/// Built with `flutter_animate` using [Curves.easeOutCubic] (500-900 ms).
/// Supports item stagger delays (default 80 ms per item index).
/// When [reduceEffectsProvider] is true, skips all animation and renders
/// [child] immediately to prevent unwanted motion and conserve resources.
class FadeSlideIn extends ConsumerWidget {
  /// Creates a [FadeSlideIn].
  const FadeSlideIn({
    required this.child,
    super.key,
    this.index = 0,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.delay,
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = const Offset(0, 0.08),
    this.curve = Curves.easeOutCubic,
  });

  /// The widget to animate.
  final Widget child;

  /// Optional item index used to compute stagger delay (index * staggerDelay).
  final int index;

  /// Delay increment per item index. Defaults to 80 ms.
  final Duration staggerDelay;

  /// Explicit base delay. If null, computed as index * staggerDelay.
  final Duration? delay;

  /// Duration of the fade and slide transition (typically 500-900 ms).
  /// Defaults to 600 ms.
  final Duration duration;

  /// Fractional offset to slide up from. Defaults to Offset(0, 0.08).
  final Offset slideOffset;

  /// Animation curve. Defaults to [Curves.easeOutCubic].
  final Curve curve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceEffects = ref.watch(reduceEffectsProvider);

    if (reduceEffects) {
      return child;
    }

    final effectiveDelay = delay ?? (staggerDelay * index);

    return child
        .animate(delay: effectiveDelay)
        .fadeIn(
          duration: duration,
          curve: curve,
        )
        .slide(
          begin: slideOffset,
          end: Offset.zero,
          duration: duration,
          curve: curve,
        );
  }
}
