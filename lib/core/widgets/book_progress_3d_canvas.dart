import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/book_progress_3d_parts.dart';
import 'package:job_prep/core/widgets/book_progress_painters.dart';

/// Visual 3D book rendered with Flutter's [Transform] and perspective
/// [Matrix4], featuring a front cover (or glass initial placeholder), dynamic
/// page-stack edge thickness reflecting reading progress, a draggable ribbon
/// bookmark, and a gentle open-book animation on mount / [replayKey] changes.
class BookProgress3dCanvas extends ConsumerStatefulWidget {
  /// Creates a [BookProgress3dCanvas].
  const BookProgress3dCanvas({
    required this.title,
    required this.accentColor,
    required this.progressFraction,
    super.key,
    this.cover,
    this.percentLabel,
    this.width = 196,
    this.height = 272,
    this.compact = false,
    this.replayKey,
    this.interactiveBookmark = false,
    this.bookmarkSemanticLabel,
    this.onBookmarkDragUpdate,
    this.onBookmarkDragEnd,
  });

  /// Title rendered inside the glass fallback placeholder when [cover] is null.
  final String title;

  /// Subject/book accent color used on spine tint and glass placeholder.
  final Color accentColor;

  /// Normalized reading progress fraction in `[0.0 .. 1.0]`.
  final double progressFraction;

  /// Optional front cover widget (for example, `MaterialCoverThumbnail`).
  final Widget? cover;

  /// Optional percentage badge overlaid subtly on the front cover corner.
  final String? percentLabel;

  /// Outer visual width allocated for the tilted book canvas.
  final double width;

  /// Outer visual height allocated for the tilted book canvas.
  final double height;

  /// Whether to render a compact shelf-sized geometry with smaller edge/ribbon.
  final bool compact;

  /// Changing key triggering a fresh open-book entrance animation.
  final Object? replayKey;

  /// Enables dragging the ribbon bookmark horizontally across the page edge.
  final bool interactiveBookmark;

  /// Semantic label attached to the interactive bookmark handle.
  final String? bookmarkSemanticLabel;

  /// Invoked continuously while dragging the bookmark with normalized `[0..1]`.
  final ValueChanged<double>? onBookmarkDragUpdate;

  /// Invoked when the bookmark drag completes with final normalized `[0..1]`.
  final ValueChanged<double>? onBookmarkDragEnd;

  @override
  ConsumerState<BookProgress3dCanvas> createState() =>
      _BookProgress3dCanvasState();
}

class _BookProgress3dCanvasState extends ConsumerState<BookProgress3dCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double? _activeDragFraction;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _startOpenAnimation();
  }

  @override
  void didUpdateWidget(BookProgress3dCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayKey != widget.replayKey) {
      _activeDragFraction = null;
      _startOpenAnimation();
    }
  }

  void _startOpenAnimation() {
    final reduceEffects = ref.read(reduceEffectsProvider);
    if (reduceEffects) {
      _controller.value = 1.0;
      return;
    }
    _controller
      ..value = 0.0
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _initialLetter() {
    final trimmed = widget.title.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final reduceEffects = ref.watch(reduceEffectsProvider);
    if (reduceEffects && _controller.value != 1.0) {
      _controller.value = 1.0;
    }

    final displayFraction =
        (_activeDragFraction ?? widget.progressFraction).clamp(0, 1).toDouble();
    final edgeMaxWidth = widget.compact ? 14.0 : 24.0;
    final spineWidth = widget.compact ? 8.0 : 12.0;
    final ribbonHeight = widget.compact ? 14.0 : 20.0;
    final bodyHeight = math.max(80, widget.height - ribbonHeight).toDouble();
    final trackWidth =
        math.max(40, widget.width - spineWidth - edgeMaxWidth).toDouble();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final rawT = reduceEffects ? 1.0 : _controller.value;
          final eased = Curves.easeOutCubic.transform(rawT);
          final bodyTiltY = lerpDouble(-0.34, -0.14, eased)!;
          final bodyTiltX = lerpDouble(0.10, 0.04, eased)!;
          final coverHingeY = lerpDouble(0.0, -0.07, eased)!;

          final bodyMatrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0014)
            ..rotateY(bodyTiltY)
            ..rotateX(bodyTiltX);

          final coverMatrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0018)
            ..rotateY(coverHingeY);

          final coverRadius = BorderRadius.only(
            topLeft: Radius.circular(spacing.xxs),
            bottomLeft: Radius.circular(spacing.xxs),
            topRight: radii.cardRadius.topRight,
            bottomRight: radii.cardRadius.bottomRight,
          );

          return Transform(
            alignment: Alignment.center,
            transform: bodyMatrix,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: spineWidth * 0.5,
                  top: spacing.xxs,
                  right: 0,
                  height: bodyHeight - spacing.xs,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: coverRadius,
                      border: Border.all(color: colors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: colors.background.withValues(alpha: 0.28),
                          blurRadius: spacing.md,
                          offset: Offset(spacing.xs, spacing.sm),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: edgeMaxWidth,
                        height: double.infinity,
                        child: CustomPaint(
                          key: const ValueKey('book-page-stack-edge'),
                          painter: BookPageStackPainter(
                            progress: displayFraction,
                            paperColor: colors.surfaceElevated,
                            lineColor: colors.textMuted.withValues(alpha: 0.26),
                            readColor:
                                colors.goldAccent.withValues(alpha: 0.72),
                            borderColor: colors.glassBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  width: spineWidth,
                  height: bodyHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        widget.accentColor.withValues(alpha: 0.48),
                        colors.surfaceElevated,
                      ),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(spacing.xs),
                      ),
                      border: Border.all(color: colors.glassBorder),
                    ),
                  ),
                ),
                Positioned(
                  left: spineWidth - 1,
                  top: 0,
                  width: trackWidth + 1,
                  height: bodyHeight,
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: coverMatrix,
                    child: BookFrontCoverFace(
                      initialLetter: _initialLetter(),
                      accentColor: widget.accentColor,
                      borderRadius: coverRadius,
                      cover: widget.cover,
                      percentLabel: widget.percentLabel,
                      compact: widget.compact,
                    ),
                  ),
                ),
                Positioned(
                  left: spineWidth,
                  top: bodyHeight - spacing.sm,
                  width: trackWidth,
                  height: ribbonHeight + spacing.sm,
                  child: BookBookmarkTrack(
                    fraction: displayFraction,
                    trackWidth: trackWidth,
                    ribbonHeight: ribbonHeight,
                    compact: widget.compact,
                    interactive: widget.interactiveBookmark,
                    semanticLabel: widget.bookmarkSemanticLabel,
                    onDragStart: () {
                      setState(() => _activeDragFraction = displayFraction);
                    },
                    onDragUpdate: (deltaDx) {
                      final next = ((_activeDragFraction ?? displayFraction) +
                              (deltaDx / trackWidth))
                          .clamp(0.0, 1.0);
                      setState(() => _activeDragFraction = next);
                      widget.onBookmarkDragUpdate?.call(next);
                    },
                    onDragEnd: () {
                      final committed = _activeDragFraction ?? displayFraction;
                      setState(() => _activeDragFraction = null);
                      widget.onBookmarkDragEnd?.call(committed);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
