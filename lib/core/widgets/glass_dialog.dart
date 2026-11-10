import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Shows a dialog with a frosted glassmorphic card container.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  final fallbackColor = Theme.of(context)
      .extension<AppThemeTokens>()!
      .colors
      .background
      .withValues(alpha: 0.65);

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? fallbackColor,
    builder: builder,
  );
}

/// Glassmorphic dialog container with a 12 px radius.
///
/// Features a subtle glass backdrop, 1 px border, and design token styling.
class GlassDialog extends ConsumerWidget {
  /// Creates a [GlassDialog].
  const GlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.maxWidth = 480.0,
    this.padding,
  });

  /// The title of the dialog.
  final Widget? title;

  /// The primary content of the dialog.
  final Widget? content;

  /// The set of actions displayed at the bottom of the dialog.
  final List<Widget>? actions;

  /// Maximum width of the dialog.
  final double maxWidth;

  /// Optional inner padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final dialogRadius = radii.cardRadius;
    final effectiveFill =
        reduceEffects ? colors.glassFillSolid : colors.glassFill;

    Widget dialogBody = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding ?? spacing.insetsAllXl,
      decoration: BoxDecoration(
        color: effectiveFill,
        borderRadius: dialogRadius,
        border: Border.all(
          color: colors.glassBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            DefaultTextStyle(
              style: tokens.textStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              child: title!,
            ),
            SizedBox(height: spacing.md),
          ],
          if (content != null) ...[
            Flexible(
              child: DefaultTextStyle(
                style: tokens.textStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                child: content!,
              ),
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(height: spacing.xl),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: actions!,
            ),
          ],
        ],
      ),
    );

    if (reduceEffects) {
      dialogBody = ClipRRect(
        borderRadius: dialogRadius,
        child: dialogBody,
      );
    } else {
      dialogBody = ClipRRect(
        borderRadius: dialogRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: dialogBody,
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: spacing.insetsAllLg,
      child: dialogBody,
    );
  }
}
