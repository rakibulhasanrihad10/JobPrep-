import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Reusable rectangular glassmorphic chip with an 8 px radius.
///
/// Strictly rectangular (no pill chips). Complies with design tokens
/// and respects [reduceEffectsProvider].
class GlassChip extends ConsumerStatefulWidget {
  /// Creates a [GlassChip].
  const GlassChip({
    required this.label,
    super.key,
    this.leading,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.padding,
  });

  /// The primary chip label widget.
  final Widget label;

  /// Optional leading widget (e.g. icon or avatar).
  final Widget? leading;

  /// Optional callback invoked when chip is tapped.
  final VoidCallback? onTap;

  /// Optional callback invoked when delete icon is pressed.
  final VoidCallback? onDeleted;

  /// Whether the chip is currently selected.
  final bool isSelected;

  /// Custom padding inside chip.
  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<GlassChip> createState() => _GlassChipState();
}

class _GlassChipState extends ConsumerState<GlassChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final durations = tokens.durations;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final chipRadius = radii.mdRadius;

    // Determine colors based on selection and hover
    final Color fillColor;
    final Color borderColor;
    final Color textColor;

    if (widget.isSelected) {
      fillColor = colors.goldAccentSubtle;
      borderColor = colors.goldAccent;
      textColor = colors.goldAccent;
    } else if (_isHovered && widget.onTap != null) {
      fillColor = reduceEffects
          ? colors.surfaceElevated
          : colors.glassFill.withValues(alpha: 0.18);
      borderColor = colors.goldAccentSubtle;
      textColor = colors.textPrimary;
    } else {
      fillColor = reduceEffects ? colors.glassFillSolid : colors.glassFill;
      borderColor = colors.glassBorder;
      textColor = colors.textSecondary;
    }

    final defaultPadding = EdgeInsets.symmetric(
      horizontal: spacing.sm,
      vertical: spacing.xs,
    );

    Widget content = DefaultTextStyle(
      style: tokens.textStyles.labelMedium.copyWith(
        color: textColor,
        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null) ...[
            IconTheme(
              data: IconThemeData(
                color: textColor,
                size: 16,
              ),
              child: widget.leading!,
            ),
            SizedBox(width: spacing.xs),
          ],
          widget.label,
          if (widget.onDeleted != null) ...[
            SizedBox(width: spacing.xs),
            InkWell(
              onTap: widget.onDeleted,
              borderRadius: radii.smRadius,
              child: Padding(
                padding: spacing.insetsAllXxs,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: textColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    content = AnimatedContainer(
      duration: durations.fast,
      padding: widget.padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: chipRadius,
        border: Border.all(color: borderColor),
      ),
      child: content,
    );

    if (widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) => setState(() => _isHovered = hovered),
          borderRadius: chipRadius,
          child: content,
        ),
      );
    }

    if (reduceEffects) {
      return ClipRRect(
        borderRadius: chipRadius,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: chipRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: content,
      ),
    );
  }
}
