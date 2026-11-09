import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Glassmorphic sidebar navigation container.
///
/// Features a subtle glass backdrop with blur sigma 16 (or solid fill
/// when reduce effects is active) and a 1 px border along its inner edge.
class GlassSidebar extends ConsumerWidget {
  /// Creates a [GlassSidebar].
  const GlassSidebar({
    required this.children,
    super.key,
    this.header,
    this.footer,
    this.width = 260.0,
    this.padding,
    this.isTrailing = false,
  });

  /// Optional header widget at top of sidebar.
  final Widget? header;

  /// Main navigation children / list items.
  final List<Widget> children;

  /// Optional footer widget at bottom of sidebar.
  final Widget? footer;

  /// Width of sidebar container.
  final double width;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Whether sidebar is placed on the trailing (right) edge of viewport.
  final bool isTrailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final effectiveFill =
        reduceEffects ? colors.glassFillSolid : colors.glassFill;

    final borderSide = BorderSide(color: colors.glassBorder);
    final border = Border(
      right: isTrailing ? BorderSide.none : borderSide,
      left: isTrailing ? borderSide : BorderSide.none,
    );

    final Widget content = Container(
      width: width,
      height: double.infinity,
      padding: padding ?? spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: effectiveFill,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              header!,
              SizedBox(height: spacing.lg),
            ],
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: children,
              ),
            ),
            if (footer != null) ...[
              SizedBox(height: spacing.md),
              footer!,
            ],
          ],
        ),
      ),
    );

    if (reduceEffects) {
      return ClipRect(
        child: content,
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: content,
      ),
    );
  }
}
