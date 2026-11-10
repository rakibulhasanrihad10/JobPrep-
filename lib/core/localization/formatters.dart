import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper utilities for locale-aware formatting of dates, numbers,
/// and currency.
class AppFormatters {
  AppFormatters._();

  static const List<String> _englishDigits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];

  static const List<String> _banglaDigits = [
    '০',
    '১',
    '২',
    '৩',
    '৪',
    '৫',
    '৬',
    '৭',
    '৮',
    '৯',
  ];

  /// Converts all ASCII digits ('0'-'9') in [input] to Bangla numerals
  /// ('০'-'৯').
  static String toBanglaDigits(String input) {
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(_englishDigits[i], _banglaDigits[i]);
    }
    return result;
  }

  /// Converts all Bangla numerals ('০'-'৯') in [input] to ASCII digits
  /// ('0'-'9').
  static String toEnglishDigits(String input) {
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(_banglaDigits[i], _englishDigits[i]);
    }
    return result;
  }

  /// Formats a numerical [value] according to [locale], with optional
  /// Bangla digits.
  static String formatNumber(
    num value, {
    required Locale locale,
    bool useBanglaDigits = false,
    int? decimalDigits,
  }) {
    final formatter = decimalDigits != null
        ? NumberFormat.currency(
            locale: locale.languageCode,
            symbol: '',
            decimalDigits: decimalDigits,
          )
        : NumberFormat.decimalPattern(locale.languageCode);

    final formatted = formatter.format(value).trim();
    if (useBanglaDigits || locale.languageCode == 'bn') {
      return toBanglaDigits(formatted);
    }
    return formatted;
  }

  /// Formats currency [amount] with currency [symbol] (defaults to '৳')
  /// and locale rules.
  static String formatCurrency(
    num amount, {
    required Locale locale,
    String symbol = '৳',
    bool useBanglaDigits = false,
    int decimalDigits = 0,
  }) {
    final numberFormatted = formatNumber(
      amount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: decimalDigits,
    );
    return '$symbol $numberFormatted';
  }

  /// Formats a [date] according to [locale] and optional [pattern].
  static String formatDate(
    DateTime date, {
    required Locale locale,
    String pattern = 'd MMMM yyyy',
    bool useBanglaDigits = false,
  }) {
    final formatted = DateFormat(pattern, locale.languageCode).format(date);
    if (useBanglaDigits || locale.languageCode == 'bn') {
      return toBanglaDigits(formatted);
    }
    return formatted;
  }
}
