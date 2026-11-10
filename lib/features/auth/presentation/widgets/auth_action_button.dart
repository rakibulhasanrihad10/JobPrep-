import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';

/// Full-width tokenized [GlassButton] with built-in loading state handling.
class AuthActionButton extends StatelessWidget {
  /// Creates an [AuthActionButton].
  const AuthActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = GlassButtonVariant.primary,
    this.leading,
  });

  /// Button text label.
  final String label;

  /// Action invoked when tapped.
  final VoidCallback? onPressed;

  /// Whether this specific button's async action is currently running.
  final bool isLoading;

  /// Whether another blocking operation disables this button.
  final bool isDisabled;

  /// Visual variant of the underlying [GlassButton].
  final GlassButtonVariant variant;

  /// Optional leading widget shown when not loading.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;
    final indicatorColor = variant == GlassButtonVariant.primary
        ? colors.textMuted
        : colors.goldAccent;

    final effectiveLeading = isLoading
        ? SizedBox.square(
            dimension: spacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: spacing.xxs,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          )
        : leading;

    return GlassButton(
      width: double.infinity,
      variant: variant,
      onPressed: effectiveOnPressed,
      leading: effectiveLeading,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Minimal geometric Google monogram rendered cleanly using design tokens.
class AuthGoogleMark extends StatelessWidget {
  /// Creates an [AuthGoogleMark].
  const AuthGoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final size = tokens.spacing.lg + tokens.spacing.xxs;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GoogleMarkPainter(
          primaryColor: tokens.colors.goldAccent,
          secondaryColor: tokens.colors.textPrimary,
          strokeWidth: tokens.spacing.xxs,
        ),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final ringPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final barPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Outer open circle forming the 'G'
    canvas
      ..drawArc(rect, -0.35, 5.2, false, ringPaint)
      // Horizontal crossbar of 'G'
      ..drawLine(
        center,
        Offset(center.dx + radius, center.dy),
        barPaint,
      );
  }

  @override
  bool shouldRepaint(covariant _GoogleMarkPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
