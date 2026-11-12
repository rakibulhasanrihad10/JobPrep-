import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Validation errors returned when parsing or checking a target book page.
enum BookPositionValidationError {
  empty,
  notWholeNumber,
  belowZero,
  exceedsTotal,
}

/// Immutable result of computing the progress delta between a material's
/// current position and a requested target position.
@immutable
class BookPositionChange {
  /// Creates a [BookPositionChange].
  const BookPositionChange({
    required this.currentPosition,
    required this.targetPosition,
    required this.delta,
    required this.entryType,
  });

  /// Material's clamped position before this change.
  final int currentPosition;

  /// Clamped target position requested by the user.
  final int targetPosition;

  /// Signed delta (`targetPosition - currentPosition`) persisted in
  /// `progress_logs.units_done`.
  final int delta;

  /// Log entry type (`study` for forward jumps, `correction` for moves below
  /// the current position).
  final ProgressLogEntryType entryType;

  /// Whether moving to [targetPosition] lowers progress and requires user
  /// confirmation before recording a correction entry.
  bool get requiresConfirmation =>
      delta < 0 || entryType == ProgressLogEntryType.correction;

  /// Whether [targetPosition] matches [currentPosition] cleanly (`delta == 0`).
  bool get isNoOp => delta == 0;
}

/// Pure, dependency-free calculations and validation for book position updates
/// and interactive bookmark dragging.
abstract final class BookPositionCalculator {
  static const int _banglaZeroCodeUnit = 0x09E6;
  static const int _banglaNineCodeUnit = 0x09EF;

  /// Converts localized Bangla digits (`০`-`৯`) inside [raw] into ASCII digits.
  static String normalizeDigits(String raw) {
    if (raw.isEmpty) return raw;
    final buffer = StringBuffer();
    for (final rune in raw.runes) {
      if (rune >= _banglaZeroCodeUnit && rune <= _banglaNineCodeUnit) {
        buffer.writeCharCode(0x30 + (rune - _banglaZeroCodeUnit));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Parses [raw] and validates it as a whole page inside `[0, totalUnits]`.
  static ({int? page, BookPositionValidationError? error})
      parseAndValidateTargetPage(
    String raw, {
    required int totalUnits,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return (page: null, error: BookPositionValidationError.empty);
    }

    final normalized = normalizeDigits(trimmed);
    final parsed = int.tryParse(normalized);
    if (parsed == null) {
      return (page: null, error: BookPositionValidationError.notWholeNumber);
    }
    if (parsed < 0) {
      return (page: null, error: BookPositionValidationError.belowZero);
    }
    final safeTotal = totalUnits < 0 ? 0 : totalUnits;
    if (parsed > safeTotal) {
      return (page: null, error: BookPositionValidationError.exceedsTotal);
    }
    return (page: parsed, error: null);
  }

  /// Computes the signed difference and entry type needed to move from
  /// [currentUnits] to [targetPage] on a material of size [totalUnits].
  static BookPositionChange computeChange({
    required int currentUnits,
    required int totalUnits,
    required int targetPage,
  }) {
    final safeTotal = totalUnits < 0 ? 0 : totalUnits;
    final clampedCurrent = currentUnits.clamp(0, safeTotal);
    final clampedTarget = targetPage.clamp(0, safeTotal);
    final delta = clampedTarget - clampedCurrent;
    final entryType = delta < 0
        ? ProgressLogEntryType.correction
        : ProgressLogEntryType.study;

    return BookPositionChange(
      currentPosition: clampedCurrent,
      targetPosition: clampedTarget,
      delta: delta,
      entryType: entryType,
    );
  }

  /// Maps a normalized `[0.0 .. 1.0]` bookmark drag fraction to a rounded
  /// page number inside `[0, totalUnits]`.
  static int pageFromFraction({
    required double fraction,
    required int totalUnits,
  }) {
    if (totalUnits <= 0 || fraction.isNaN) return 0;
    final clamped = fraction.clamp(0.0, 1.0);
    return (clamped * totalUnits).round();
  }
}
