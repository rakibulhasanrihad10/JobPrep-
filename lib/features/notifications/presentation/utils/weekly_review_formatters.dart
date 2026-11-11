import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Pure presentation helpers formatting week-over-week delta badges and colors.
abstract final class WeeklyReviewFormatters {
  /// Color indicating improvement, regression, or flat comparison.
  static Color deltaColor(num delta, BuildContext context) {
    final colors = context.tokens.colors;
    if (delta > 0) return colors.success;
    if (delta < 0) return colors.warning;
    return colors.textSecondary;
  }

  /// Formats integer unit delta against the previous 7-day window.
  static String formatIntDelta({
    required int delta,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (delta == 0) return l10n.weeklyReviewDeltaSame;
    final sign = delta > 0 ? '+' : '-';
    final formatted = AppFormatters.formatNumber(
      delta.abs(),
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.weeklyReviewDeltaUnits(sign, formatted);
  }

  /// Formats fractional hours delta against the previous 7-day window.
  static String formatHoursDelta({
    required double deltaHours,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (deltaHours.abs() < 0.05) return l10n.weeklyReviewDeltaSame;
    final sign = deltaHours > 0 ? '+' : '-';
    final formatted = AppFormatters.formatNumber(
      deltaHours.abs(),
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: 1,
    );
    return l10n.weeklyReviewDeltaHours(sign, formatted);
  }

  /// Formats mock score percentage-point delta against the prior week.
  static String formatMockDelta({
    required double delta,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (delta.abs() < 0.05) return l10n.weeklyReviewDeltaSame;
    final sign = delta > 0 ? '+' : '-';
    final formatted = AppFormatters.formatNumber(
      delta.abs(),
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: 1,
    );
    return l10n.weeklyReviewDeltaPoints(sign, formatted);
  }
}
