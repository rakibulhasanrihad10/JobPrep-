import 'package:job_prep/l10n/app_localizations.dart';

/// Pure formatting helper for backup timestamps.
abstract final class BackupTimeFormatter {
  /// Formats [lastBackup] relative to [now] using localized labels.
  static String format(
    DateTime? lastBackup,
    AppLocalizations l10n, {
    DateTime? now,
  }) {
    if (lastBackup == null) {
      return l10n.settingsLastBackup(l10n.settingsLastBackupNever);
    }

    final current = now ?? DateTime.now();
    final difference = current.difference(lastBackup);

    if (difference.inDays <= 0 && current.day == lastBackup.day) {
      return l10n.settingsLastBackup(l10n.settingsLastBackupToday);
    }

    final days = difference.inDays;
    if (days == 1 || (days == 0 && current.day != lastBackup.day)) {
      return l10n.settingsLastBackup(l10n.settingsLastBackupYesterday);
    }

    final effectiveDays = days <= 0 ? 1 : days;
    return l10n.settingsLastBackup(
      l10n.settingsLastBackupDaysAgo(effectiveDays),
    );
  }
}
