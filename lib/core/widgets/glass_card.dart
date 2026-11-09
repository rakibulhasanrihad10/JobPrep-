import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Reusable glassmorphic card with 12 px radius, subtle fill, and 1 px border.
///
/// Respects [reduceEffectsProvider] by swapping the blur filter for a solid
/// translucent fill.
class GlassCard extends ConsumerWidget {
  /// Creates a [GlassCard].
  const GlassCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.borderColor,
    this.fillColor,
    this.onTap,
  });

  /// The widget below this card in the tree.
  final Widget child;

  /// Empty space to inscribe inside the card.
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the card.
  final EdgeInsetsGeometry? margin;

  /// Explicit card width.
  final double? width;

  /// Explicit card height.
  final double? height;

  /// Optional custom border radius (defaults to 12 px card radius token).
  final BorderRadius? borderRadius;

  /// Optional custom border color (defaults to glass border token).
  final Color? borderColor;

  /// Optional custom fill color (defaults to glass fill token).
  final Color? fillColor;

  /// Optional callback invoked when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;

    final reduceEffects = ref.watch(reduceEffectsProvider);
    final effectiveRadius = borderRadius ?? radii.cardRadius;
    final effectiveBorderColor = borderColor ?? colors.glassBorder;
    final effectiveFillColor = reduceEffects
        ? (fillColor ?? colors.glassFillSolid)
        : (fillColor ?? colors.glassFill);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: effectiveFillColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: effectiveBorderColor,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: content,
        ),
      );
    }

    if (reduceEffects) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: content,
      );
    } else {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}
