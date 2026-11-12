import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Compact badge indicating ahead, on-track, or behind study schedule status.
class StudyPlanStatusBadge extends StatelessWidget {
  /// Creates a [StudyPlanStatusBadge].
  const StudyPlanStatusBadge({
    required this.label,
    required this.color,
    super.key,
  });

  /// Localized schedule status text.
  final String label;

  /// Semantic status color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: tokens.radii.smRadius,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: tokens.textStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

/// Compact surface pill displaying one study plan metric and optional sublabel.
class StudyPlanStatPill extends StatelessWidget {
  /// Creates a [StudyPlanStatPill].
  const StudyPlanStatPill({
    required this.label,
    required this.value,
    required this.accent,
    this.sublabel,
    super.key,
  });

  /// Localized metric label.
  final String label;

  /// Primary formatted value.
  final String value;

  /// Optional secondary caption rendered below [value].
  final String? sublabel;

  /// Accent color applied to [value].
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.mdRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: tokens.textStyles.bodySmall),
          SizedBox(height: spacing.xxs),
          Text(
            value,
            style: tokens.textStyles.labelLarge.copyWith(color: accent),
          ),
          if (sublabel != null) ...[
            SizedBox(height: spacing.xxs),
            Text(sublabel!, style: tokens.textStyles.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Highlighted alert strip used for automatic catch-up or past-buffer notices.
class StudyPlanAlertBox extends StatelessWidget {
  /// Creates a [StudyPlanAlertBox].
  const StudyPlanAlertBox({
    required this.boxKey,
    required this.accent,
    required this.icon,
    required this.message,
    super.key,
  });

  /// Identifier key applied to the container.
  final Key boxKey;

  /// Border, tint, and icon color.
  final Color accent;

  /// Leading status icon.
  final IconData icon;

  /// Localized explanatory message.
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Container(
      key: boxKey,
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: radii.mdRadius,
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: spacing.lg),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              message,
              style: tokens.textStyles.bodySmall.copyWith(
                color: tokens.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
