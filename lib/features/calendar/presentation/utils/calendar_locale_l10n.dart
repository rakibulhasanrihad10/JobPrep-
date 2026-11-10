import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Locale, color-token, and label helpers for the Calendar feature.
abstract final class CalendarLocaleL10n {
  /// Returns the distinct theme color token assigned to [kind].
  static Color colorForKind(CalendarEventKind kind, AppColorsToken colors) {
    return switch (kind) {
      CalendarEventKind.deadline => colors.danger,
      CalendarEventKind.preliminary => colors.goldAccent,
      CalendarEventKind.written => colors.info,
      CalendarEventKind.viva => colors.success,
      CalendarEventKind.practical ||
      CalendarEventKind.other =>
        colors.accentSecondary,
    };
  }

  /// Returns the semantic icon assigned to [kind].
  static IconData iconForKind(CalendarEventKind kind) {
    return switch (kind) {
      CalendarEventKind.deadline => Icons.event_busy_rounded,
      CalendarEventKind.preliminary => Icons.quiz_outlined,
      CalendarEventKind.written => Icons.edit_note_rounded,
      CalendarEventKind.viva => Icons.record_voice_over_outlined,
      CalendarEventKind.practical => Icons.science_outlined,
      CalendarEventKind.other => Icons.event_note_rounded,
    };
  }

  /// Localized display label for [kind].
  static String labelForKind(CalendarEventKind kind, AppLocalizations l10n) {
    return switch (kind) {
      CalendarEventKind.deadline => l10n.calendarEventDeadline,
      CalendarEventKind.preliminary => l10n.calendarEventPreliminary,
      CalendarEventKind.written => l10n.calendarEventWritten,
      CalendarEventKind.viva => l10n.calendarEventViva,
      CalendarEventKind.practical => l10n.calendarEventPractical,
      CalendarEventKind.other => l10n.calendarEventOther,
    };
  }

  /// Resolves an initialized `intl` locale tag matching [locale], preferring
  /// `<language>_<country>` when available and falling back cleanly.
  static String resolveIntlLocaleTag(Locale locale) {
    final country = locale.countryCode?.trim();
    if (country != null && country.isNotEmpty) {
      final fullTag = '${locale.languageCode}_$country';
      if (DateFormat.localeExists(fullTag)) {
        return fullTag;
      }
    }
    if (DateFormat.localeExists(locale.languageCode)) {
      return locale.languageCode;
    }
    return 'en';
  }

  /// Resolves first day of the week (`1 = Monday` .. `7 = Sunday`) purely from
  /// `intl` CLDR symbols for [locale].
  static int firstDayOfWeekFromLocale(Locale locale) {
    final tag = resolveIntlLocaleTag(locale);
    final firstIsoOffset = DateFormat.yMMMM(tag).dateSymbols.FIRSTDAYOFWEEK;
    return (firstIsoOffset % 7) + 1;
  }

  /// Resolves first day of the week (`1 = Monday` .. `7 = Sunday`) from
  /// [MaterialLocalizations] on [context] when mounted, falling back to `intl`
  /// CLDR symbols for [locale].
  static int resolveFirstDayOfWeek(BuildContext context, Locale locale) {
    final material = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    if (material != null) {
      // MaterialLocalizations.firstDayOfWeekIndex uses 0 = Sunday .. 6 = Sat.
      final idx = material.firstDayOfWeekIndex;
      return idx == 0 ? DateTime.sunday : idx;
    }
    return firstDayOfWeekFromLocale(locale);
  }

  /// Resolves the mounted localization [Locale] on [context], falling back to
  /// [fallback] when no ancestor `Localizations` widget exists.
  static Locale effectiveLocale(BuildContext context, Locale fallback) {
    return Localizations.maybeLocaleOf(context) ?? fallback;
  }

  /// Formats the month and year header (e.g. `November 2026` / `নভেম্বর ২০২৬`).
  static String monthYearTitle(
    DateTime monthDate, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final tag = resolveIntlLocaleTag(locale);
    final formatted = DateFormat.yMMMM(tag).format(monthDate);
    if (useBanglaDigits || locale.languageCode == 'bn') {
      return AppFormatters.toBanglaDigits(formatted);
    }
    return formatted;
  }

  /// Formats a localized short weekday name for Dart `weekday` (`1..7`).
  static String weekdayShortLabel(int weekday, {required Locale locale}) {
    final tag = resolveIntlLocaleTag(locale);
    final symbols = DateFormat.yMMMM(tag).dateSymbols;
    return symbols.SHORTWEEKDAYS[weekday % 7];
  }

  /// Formats a localized full weekday name for Dart `weekday` (`1..7`).
  static String weekdayFullLabel(int weekday, {required Locale locale}) {
    final tag = resolveIntlLocaleTag(locale);
    final symbols = DateFormat.yMMMM(tag).dateSymbols;
    return symbols.STANDALONEWEEKDAYS[weekday % 7];
  }

  /// Formats day-of-month number (`1..31`) respecting Bangla digits.
  static String dayNumberLabel(
    int day, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    return AppFormatters.formatNumber(
      day,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
  }

  /// Formats the selected agenda header date
  /// (e.g. `Tuesday, 10 November 2026`).
  static String selectedDayTitle(
    DateTime day, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final tag = resolveIntlLocaleTag(locale);
    final formatted = DateFormat('EEEE, d MMMM yyyy', tag).format(day);
    if (useBanglaDigits || locale.languageCode == 'bn') {
      return AppFormatters.toBanglaDigits(formatted);
    }
    return formatted;
  }

  /// Formats event time-of-day (`hh:mm a`), returning `null` if midnight
  /// `00:00` when no meaningful time is present.
  static String? eventTimeLabel(
    DateTime date, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (date.hour == 0 && date.minute == 0) {
      return null;
    }
    final tag = resolveIntlLocaleTag(locale);
    final formatted = DateFormat('hh:mm a', tag).format(date);
    if (useBanglaDigits || locale.languageCode == 'bn') {
      return AppFormatters.toBanglaDigits(formatted);
    }
    return formatted;
  }

  /// Localized pluralized event count for an agenda day.
  static String agendaCountLabel(
    int count,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final formatted = AppFormatters.formatNumber(
      count,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.calendarAgendaCount(count, formatted);
  }

  /// Localized `+N` overflow marker when a day cell contains extra event kinds.
  static String moreCountLabel(
    int extraCount,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final formatted = AppFormatters.formatNumber(
      extraCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.calendarMoreEvents(formatted);
  }
}
