import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the layered page stack edge with read thickness proportional to
/// [progress].
class BookPageStackPainter extends CustomPainter {
  /// Creates a [BookPageStackPainter].
  const BookPageStackPainter({
    required this.progress,
    required this.paperColor,
    required this.lineColor,
    required this.readColor,
    required this.borderColor,
  });

  /// Completion fraction in `[0.0 .. 1.0]`.
  final double progress;

  /// Base paper fill color from tokens.
  final Color paperColor;

  /// Sheet line separator color from tokens.
  final Color lineColor;

  /// Highlight color filling the read portion of the stack thickness.
  final Color readColor;

  /// Outer fore-edge border color from tokens.
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = paperColor);

    final clamped = progress.clamp(0, 1).toDouble();
    if (clamped > 0) {
      final readWidth = math.max(2, size.width * clamped).toDouble();
      canvas.drawRect(
        Rect.fromLTWH(0, 0, readWidth, size.height),
        Paint()..color = readColor,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;
    const sheetGap = 4.0;
    for (var x = sheetGap; x < size.width; x += sheetGap) {
      canvas.drawLine(Offset(x, 2), Offset(x, size.height - 2), linePaint);
    }

    canvas.drawRect(
      rect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(BookPageStackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.paperColor != paperColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.readColor != readColor ||
        oldDelegate.borderColor != borderColor;
  }
}

/// Paints the notched chevron ribbon bookmark icon tail.
class RibbonBookmarkPainter extends CustomPainter {
  /// Creates a [RibbonBookmarkPainter].
  const RibbonBookmarkPainter({
    required this.fillColor,
    required this.borderColor,
  });

  /// Primary ribbon fill color from tokens.
  final Color fillColor;

  /// Subtle edge stroke color from tokens.
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final notchDepth = size.height * 0.24;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.5, size.height - notchDepth)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(path, Paint()..color = fillColor)
      ..drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
  }

  @override
  bool shouldRepaint(RibbonBookmarkPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
