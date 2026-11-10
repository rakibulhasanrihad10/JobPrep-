import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Localization and design-token color helpers for circular presentation
/// widgets.
abstract final class CircularL10n {
  /// Localized display label for [sector].
  static String sectorLabel(CircularSector sector, AppLocalizations l10n) {
    return switch (sector) {
      CircularSector.government => l10n.circularSectorGovernment,
      CircularSector.bcs => l10n.circularSectorBcs,
      CircularSector.bank => l10n.circularSectorBank,
      CircularSector.autonomous => l10n.circularSectorAutonomous,
      CircularSector.private => l10n.circularSectorPrivate,
      CircularSector.ngo => l10n.circularSectorNgo,
      CircularSector.defense => l10n.circularSectorDefense,
      CircularSector.other => l10n.circularSectorOther,
    };
  }

  /// Localized display label for [status].
  static String applicationStatusLabel(
    ApplicationStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      ApplicationStatus.notApplied => l10n.circularAppStatusNotApplied,
      ApplicationStatus.inProgress => l10n.circularAppStatusInProgress,
      ApplicationStatus.applied => l10n.circularAppStatusApplied,
      ApplicationStatus.feePaid => l10n.circularAppStatusFeePaid,
      ApplicationStatus.exempt => l10n.circularAppStatusExempt,
      ApplicationStatus.missed => l10n.circularAppStatusMissed,
      ApplicationStatus.notApplicable => l10n.circularAppStatusNotApplicable,
    };
  }

  /// Localized display label for [priority].
  static String priorityLabel(
    CircularPriority priority,
    AppLocalizations l10n,
  ) {
    return switch (priority) {
      CircularPriority.low => l10n.circularPriorityLow,
      CircularPriority.medium => l10n.circularPriorityMedium,
      CircularPriority.high => l10n.circularPriorityHigh,
      CircularPriority.urgent => l10n.circularPriorityUrgent,
    };
  }

  /// Localized display label for [status].
  static String workflowStatusLabel(
    CircularWorkflowStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      CircularWorkflowStatus.saved => l10n.circularWorkflowSaved,
      CircularWorkflowStatus.preparing => l10n.circularWorkflowPreparing,
      CircularWorkflowStatus.applied => l10n.circularWorkflowApplied,
      CircularWorkflowStatus.examUpcoming => l10n.circularWorkflowExamUpcoming,
      CircularWorkflowStatus.resultAwaited =>
        l10n.circularWorkflowResultAwaited,
      CircularWorkflowStatus.archived => l10n.circularWorkflowArchived,
    };
  }

  /// Localized display label for [sortBy].
  static String sortOptionLabel(
    CircularSortOption sortBy,
    AppLocalizations l10n,
  ) {
    return switch (sortBy) {
      CircularSortOption.deadlineAsc => l10n.circularsSortDeadline,
      CircularSortOption.priorityDesc => l10n.circularsSortPriority,
      CircularSortOption.createdDesc => l10n.circularsSortCreated,
      CircularSortOption.updatedDesc => l10n.circularsSortUpdated,
      CircularSortOption.titleAsc => l10n.circularsSortTitle,
    };
  }

  /// Localized vacancy summary with locale-aware digits.
  static String vacanciesLabel(
    int? vacancies,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (vacancies == null) {
      return l10n.circularsVacanciesUnspecified;
    }
    final formatted = AppFormatters.formatNumber(
      vacancies,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.circularsVacanciesCount(vacancies, formatted);
  }

  /// Localized countdown phrase from [countdown] using localized numerals.
  static String deadlineCountdownLabel(
    DeadlineCountdown countdown,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final days = countdown.daysRemaining;
    if (days == null) {
      return l10n.circularsCountdownNoDeadline;
    }

    if (countdown.isOverdue) {
      final overdueDays = days.abs();
      final formatted = AppFormatters.formatNumber(
        overdueDays,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      );
      return l10n.circularsCountdownOverdueDays(overdueDays, formatted);
    }

    if (days == 0) {
      return l10n.circularsCountdownToday;
    }

    final formatted = AppFormatters.formatNumber(
      days,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.circularsCountdownDaysLeft(days, formatted);
  }

  /// Maps urgency [band] to its semantic color token.
  static Color deadlineBandColor(
    DeadlineColorBand band,
    AppColorsToken colors,
  ) {
    return switch (band) {
      DeadlineColorBand.none => colors.textMuted,
      DeadlineColorBand.green => colors.success,
      DeadlineColorBand.amber => colors.warning,
      DeadlineColorBand.red => colors.danger,
    };
  }

  /// Maps circular repository errors to localized user-facing copy.
  static String circularErrorMessage(Object error, AppLocalizations l10n) {
    if (error is CircularPermissionFailure) {
      return l10n.circularsErrorPermission;
    }
    if (error is CircularNetworkFailure) {
      return l10n.circularsErrorNetwork;
    }
    return l10n.circularsErrorUnknown;
  }
}
