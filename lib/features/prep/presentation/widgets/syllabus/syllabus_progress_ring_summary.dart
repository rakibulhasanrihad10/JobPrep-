import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';

/// Ring widget displaying animated percentage and a caption label.
class SyllabusProgressRingSummary extends StatelessWidget {
  const SyllabusProgressRingSummary({
    required this.label,
    required this.value,
    required this.replayKey,
    super.key,
  });

  final String label;
  final double value;
  final Object replayKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;

    final percent = (value * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedProgressRing(
          value: value,
          replayKey: replayKey,
          size: 72,
          child: Text(
            '$percent%',
            style: textStyles.labelLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: spacing.xs),
        Text(
          label,
          style: textStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
