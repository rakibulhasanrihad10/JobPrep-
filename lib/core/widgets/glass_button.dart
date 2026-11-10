import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Style variant for [GlassButton].
enum GlassButtonVariant {
  /// Standard translucent glass button with subtle border.
  standard,

  /// Gold accent highlighted glass button for primary actions.
  primary,
}

/// Reusable rectangular glassmorphic button with an 8 px radius.
///
/// Strictly rectangular with an 8 px radius (no pill buttons).
/// Reads all styles from [AppThemeTokens] and respects [reduceEffectsProvider].
class GlassButton extends ConsumerStatefulWidget {
  /// Creates a [GlassButton].
  const GlassButton({
    required this.child,
    super.key,
    this.onPressed,
    this.variant = GlassButtonVariant.standard,
    this.padding,
    this.width,
    this.height,
    this.leading,
    this.trailing,
  });

  /// The button's primary child (typically a [Text]).
  final Widget child;

  /// Callback when button is pressed. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Visual variant of the button.
  final GlassButtonVariant variant;

  /// Custom padding inside the button.
  final EdgeInsetsGeometry? padding;

  /// Optional explicit width.
  final double? width;

  /// Optional explicit height.
  final double? height;

  /// Optional leading widget (e.g. icon).
  final Widget? leading;

  /// Optional trailing widget.
  final Widget? trailing;

  @override
  ConsumerState<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends ConsumerState<GlassButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _isEnabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final durations = tokens.durations;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final isPrimary = widget.variant == GlassButtonVariant.primary;
    final isHighlighted = (_isHovered || _isFocused) && _isEnabled;

    // Fill color computation
    final Color fillColor;
    if (!_isEnabled) {
      fillColor = reduceEffects
          ? colors.glassFillSolid.withValues(alpha: 0.5)
          : colors.glassFill.withValues(alpha: 0.5);
    } else if (isPrimary) {
      fillColor = isHighlighted
          ? colors.goldAccent
          : colors.goldAccent.withValues(alpha: 0.85);
    } else if (reduceEffects) {
      fillColor =
          isHighlighted ? colors.surfaceElevated : colors.glassFillSolid;
    } else {
      fillColor = isHighlighted
          ? colors.glassFill.withValues(alpha: 0.18)
          : colors.glassFill;
    }

    // Border color computation
    final Color borderColor;
    if (!_isEnabled) {
      borderColor = colors.glassBorder.withValues(alpha: 0.3);
    } else if (isPrimary) {
      borderColor = colors.goldAccent;
    } else if (isHighlighted) {
      borderColor = colors.goldAccent;
    } else {
      borderColor = colors.glassBorder;
    }

    // Text color computation
    final Color textColor;
    if (!_isEnabled) {
      textColor = colors.textMuted;
    } else if (isPrimary) {
      textColor = colors.background;
    } else {
      textColor = colors.textPrimary;
    }

    final buttonRadius = radii.buttonRadius;
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: spacing.lg,
      vertical: spacing.md,
    );

    Widget content = IconTheme(
      data: IconThemeData(
        color: textColor,
        size: 18,
      ),
      child: DefaultTextStyle(
        style: tokens.textStyles.labelLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              SizedBox(width: spacing.sm),
            ],
            Flexible(child: widget.child),
            if (widget.trailing != null) ...[
              SizedBox(width: spacing.sm),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );

    content = AnimatedContainer(
      duration: durations.fast,
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: buttonRadius,
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: content,
    );

    if (_isEnabled) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (hovered) => setState(() => _isHovered = hovered),
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          borderRadius: buttonRadius,
          child: content,
        ),
      );
    }

    if (reduceEffects) {
      return ClipRRect(
        borderRadius: buttonRadius,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: buttonRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: content,
      ),
    );
  }
}
