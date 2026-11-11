import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/book_progress_painters.dart';

/// Renders the front hardcover face (uploaded cover image or glass initial
/// placeholder) with a spine crease line and optional percent corner badge.
class BookFrontCoverFace extends StatelessWidget {
  /// Creates a [BookFrontCoverFace].
  const BookFrontCoverFace({
    required this.initialLetter,
    required this.accentColor,
    required this.borderRadius,
    required this.compact,
    super.key,
    this.cover,
    this.percentLabel,
  });

  /// First letter shown inside the glass fallback placeholder.
  final String initialLetter;

  /// Subject/book accent color tinting the glass placeholder.
  final Color accentColor;

  /// Outer hardcover border radius.
  final BorderRadius borderRadius;

  /// Whether shelf compact typography sizing applies.
  final bool compact;

  /// Optional cover widget (such as Phase 4C `MaterialCoverThumbnail`).
  final Widget? cover;

  /// Optional percentage string shown in the top-right badge.
  final String? percentLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cover != null)
            cover!
          else
            Container(
              key: const ValueKey('book-cover-glass-placeholder'),
              padding: compact ? spacing.insetsAllSm : spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accentColor.withValues(alpha: 0.24),
                  colors.surfaceElevated,
                ),
                borderRadius: borderRadius,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.55),
                ),
              ),
              child: Center(
                child: Text(
                  initialLetter,
                  style: (compact
                          ? tokens.textStyles.headlineMedium
                          : tokens.textStyles.headlineLarge)
                      .copyWith(color: colors.textPrimary),
                ),
              ),
            ),
          Positioned(
            left: spacing.xs,
            top: 0,
            bottom: 0,
            width: 1,
            child: ColoredBox(
              color: colors.glassBorder,
            ),
          ),
          if (percentLabel != null && percentLabel!.isNotEmpty)
            Positioned(
              top: spacing.xs,
              right: spacing.xs,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xs,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.background.withValues(alpha: 0.82),
                  borderRadius: radii.smRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Text(
                  percentLabel!,
                  style: tokens.textStyles.labelSmall.copyWith(
                    color: colors.goldAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interactive horizontal ribbon track positioned along a book's bottom page
/// edge, displaying a notched gold bookmark at [fraction].
class BookBookmarkTrack extends StatelessWidget {
  /// Creates a [BookBookmarkTrack].
  const BookBookmarkTrack({
    required this.fraction,
    required this.trackWidth,
    required this.ribbonHeight,
    required this.compact,
    required this.interactive,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    super.key,
    this.semanticLabel,
  });

  /// Normalized bookmark position in `[0.0 .. 1.0]`.
  final double fraction;

  /// Horizontal width of the bottom page track.
  final double trackWidth;

  /// Visible hanging tail length of the bookmark ribbon.
  final double ribbonHeight;

  /// Uses narrower ribbon geometry when true.
  final bool compact;

  /// Enables pointer/touch horizontal drag handling.
  final bool interactive;

  /// Accessibility label describing the bookmark slider.
  final String? semanticLabel;

  /// Called when dragging begins.
  final VoidCallback onDragStart;

  /// Called with horizontal drag deltas in pixels.
  final ValueChanged<double> onDragUpdate;

  /// Called when dragging finishes or cancels.
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final ribbonWidth = compact ? 12.0 : 18.0;
    final handleHitWidth = interactive ? 44.0 : ribbonWidth + spacing.xs;
    final usableSpan = math.max(0, trackWidth - ribbonWidth).toDouble();
    final ribbonLeft = usableSpan * fraction;
    final handleLeft = (ribbonLeft + ribbonWidth / 2 - handleHitWidth / 2)
        .clamp(-spacing.sm, trackWidth - handleHitWidth + spacing.sm);

    final trackBar = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: spacing.xxs,
          height: spacing.xs,
          child: ClipRRect(
            borderRadius: tokens.radii.smRadius,
            child: Row(
              children: [
                if (fraction > 0)
                  Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: ColoredBox(
                      color: colors.goldAccent,
                      child: const SizedBox.expand(),
                    ),
                  ),
                if (fraction < 1)
                  Expanded(
                    flex: ((1.0 - fraction) * 1000).round().clamp(1, 1000),
                    child: ColoredBox(
                      color: colors.glassBorder,
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: handleLeft,
          top: 0,
          width: handleHitWidth,
          height: ribbonHeight + spacing.sm,
          child: Semantics(
            slider: interactive,
            label: semanticLabel,
            child: MouseRegion(
              cursor: interactive
                  ? SystemMouseCursors.resizeLeftRight
                  : SystemMouseCursors.basic,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  key: interactive
                      ? const ValueKey('book-bookmark-handle')
                      : null,
                  width: ribbonWidth,
                  height: ribbonHeight + spacing.xs,
                  child: CustomPaint(
                    painter: RibbonBookmarkPainter(
                      fillColor: colors.goldAccent,
                      borderColor: Color.alphaBlend(
                        colors.background.withValues(alpha: 0.32),
                        colors.goldAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (!interactive) return trackBar;

    return GestureDetector(
      key: const ValueKey('book-bookmark-track'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => onDragStart(),
      onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
      onHorizontalDragEnd: (_) => onDragEnd(),
      onHorizontalDragCancel: onDragEnd,
      child: trackBar,
    );
  }
}
