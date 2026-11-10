import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Semantic color and icon palette resolvers for user-defined study subjects.
///
/// Stores portable token keys (like `gold`, `info`, `menu_book`) in PostgreSQL
/// so subjects automatically adapt between dark and light themes without
/// hardcoding literal palette colors inside widgets.
abstract final class PrepStyleTokens {
  /// Ordered list of supported semantic subject color keys.
  static const List<String> colorKeys = <String>[
    'gold',
    'info',
    'success',
    'warning',
    'danger',
    'accent_secondary',
  ];

  /// Ordered list of supported subject icon keys.
  static const List<String> iconKeys = <String>[
    'menu_book',
    'calculate',
    'language',
    'public',
    'science',
    'computer',
    'account_balance',
    'psychology',
    'gavel',
    'quiz',
  ];

  /// Resolves a stored subject color key (or optional hex value) against the
  /// active [AppColorsToken].
  static Color resolveSubjectColor(String rawKey, AppColorsToken colors) {
    final normalized = rawKey.trim().toLowerCase();
    switch (normalized) {
      case 'gold':
        return colors.goldAccent;
      case 'info':
      case 'blue':
        return colors.info;
      case 'success':
      case 'green':
        return colors.success;
      case 'warning':
      case 'amber':
        return colors.warning;
      case 'danger':
      case 'red':
        return colors.danger;
      case 'accent_secondary':
      case 'violet':
      case 'purple':
        return colors.accentSecondary;
      default:
        return _tryParseHexColor(normalized) ?? colors.goldAccent;
    }
  }

  /// Localized accessible label for a semantic color swatch key.
  static String resolveColorLabel(String rawKey, AppLocalizations l10n) {
    return switch (rawKey.trim().toLowerCase()) {
      'info' || 'blue' => l10n.prepColorInfo,
      'success' || 'green' => l10n.prepColorSuccess,
      'warning' || 'amber' => l10n.prepColorWarning,
      'danger' || 'red' => l10n.prepColorDanger,
      'accent_secondary' ||
      'violet' ||
      'purple' =>
        l10n.prepColorAccentSecondary,
      _ => l10n.prepColorGold,
    };
  }

  /// Resolves a stored subject icon key to its Material icon glyph.
  static IconData resolveSubjectIcon(String rawKey) {
    return switch (rawKey.trim().toLowerCase()) {
      'calculate' => Icons.calculate_outlined,
      'language' => Icons.translate_outlined,
      'public' => Icons.public_outlined,
      'science' => Icons.science_outlined,
      'computer' => Icons.computer_outlined,
      'account_balance' => Icons.account_balance_outlined,
      'psychology' => Icons.psychology_outlined,
      'gavel' => Icons.gavel_outlined,
      'quiz' => Icons.quiz_outlined,
      _ => Icons.menu_book_outlined,
    };
  }

  /// Localized accessible label for a subject icon key.
  static String resolveIconLabel(String rawKey, AppLocalizations l10n) {
    return switch (rawKey.trim().toLowerCase()) {
      'calculate' => l10n.prepIconCalculate,
      'language' => l10n.prepIconLanguage,
      'public' => l10n.prepIconPublic,
      'science' => l10n.prepIconScience,
      'computer' => l10n.prepIconComputer,
      'account_balance' => l10n.prepIconAccountBalance,
      'psychology' => l10n.prepIconPsychology,
      'gavel' => l10n.prepIconGavel,
      'quiz' => l10n.prepIconQuiz,
      _ => l10n.prepIconMenuBook,
    };
  }

  static Color? _tryParseHexColor(String value) {
    var cleaned = value.replaceFirst('#', '').trim();
    if (cleaned.length == 6) {
      cleaned = 'ff$cleaned';
    }
    if (cleaned.length != 8) {
      return null;
    }
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(parsed);
  }
}
