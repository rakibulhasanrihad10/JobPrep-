import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Shared rectangular (`8 px`) option chip used in subject and material forms.
class PrepOptionChip extends StatelessWidget {
  /// Creates a [PrepOptionChip].
  const PrepOptionChip({
    required this.label,
    required this.onTap,
    super.key,
    this.isSelected = false,
    this.useElevatedUnselectedFill = true,
  });

  /// Visible chip text.
  final String label;

  /// Callback fired when tapped (disabled when `null`).
  final VoidCallback? onTap;

  /// Whether this option represents the active selection.
  final bool isSelected;

  /// Uses elevated surface fill when unselected (defaults to true).
  final bool useElevatedUnselectedFill;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final unselectedFill =
        useElevatedUnselectedFill ? colors.surfaceElevated : colors.surface;

    return InkWell(
      borderRadius: tokens.radii.buttonRadius,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.goldAccentSubtle : unselectedFill,
          borderRadius: tokens.radii.buttonRadius,
          border: Border.all(
            color: isSelected ? colors.goldAccent : colors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: tokens.textStyles.labelMedium.copyWith(
            color: isSelected ? colors.goldAccent : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
