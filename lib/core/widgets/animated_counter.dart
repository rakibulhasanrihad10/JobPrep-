import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Animated numeric counter supporting [int] and [double] values with
/// locale-aware formatting.
///
/// Interpolates from 0.0 to [value] using [TweenAnimationBuilder], formatting
/// each frame according to active [Locale] and Bangla digit settings.
/// When [reduceEffectsProvider] is true, renders the target value immediately.
class AnimatedCounter extends ConsumerWidget {
  /// Creates an [AnimatedCounter].
  const AnimatedCounter({
    required this.value,
    super.key,
    this.replayKey,
    this.prefix,
    this.suffix,
    this.decimalDigits,
    this.style,
    this.duration,
    this.curve = Curves.easeOutCubic,
  });

  /// Target numeric value to count up to.
  final num value;

  /// Optional key tied to active tab/screen to trigger replays.
  final Object? replayKey;

  /// Optional prefix string (e.g. currency symbol or tag).
  final String? prefix;

  /// Optional suffix string (e.g. '%' or unit description).
  final String? suffix;

  /// Number of decimal places to format. Defaults to 0 for ints,
  /// or preserves precision for doubles.
  final int? decimalDigits;

  /// Text style for the displayed counter. Defaults to bodyLarge.
  final TextStyle? style;

  /// Animation duration. Defaults to tokens.durations.slow (400ms).
  final Duration? duration;

  /// Animation curve. Defaults to [Curves.easeOutCubic].
  final Curve curve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final durations = tokens.durations;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final targetDouble = value.toDouble();
    final effectiveDuration =
        reduceEffects ? Duration.zero : (duration ?? durations.slow);
    final effectiveStyle = style ?? tokens.textStyles.bodyLarge;

    final effectiveDecimals =
        decimalDigits ?? (value is int ? 0 : (targetDouble % 1 == 0 ? 0 : 1));

    String format(num numToFormat) {
      final formattedNumber = AppFormatters.formatNumber(
        numToFormat,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
        decimalDigits: effectiveDecimals,
      );
      final pre = prefix ?? '';
      final suf = suffix ?? '';
      return '$pre$formattedNumber$suf';
    }

    if (reduceEffects) {
      return Text(
        format(value),
        style: effectiveStyle,
      );
    }

    return TweenAnimationBuilder<double>(
      key: replayKey != null ? ValueKey(replayKey) : null,
      tween: Tween<double>(
        begin: 0,
        end: targetDouble,
      ),
      duration: effectiveDuration,
      curve: curve,
      builder: (context, animatedValue, _) {
        final displayValue =
            value is int ? animatedValue.round() : animatedValue;

        return Text(
          format(displayValue),
          style: effectiveStyle,
        );
      },
    );
  }
}
