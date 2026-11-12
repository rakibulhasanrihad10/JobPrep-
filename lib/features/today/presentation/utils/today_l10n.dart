import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/domain/utils/today_summary_calculator.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Pure localization and formatting helpers for Phase 6I Today UI widgets.
abstract final class TodayL10n {
  /// Formats a greeting string combining time-of-day salutation with the user's
  /// first/display name when set.
  static String greetingText({
    required DateTime now,
    required AuthUser? user,
    required AppLocalizations l10n,
  }) {
    final base = switch (TodaySummaryCalculator.greetingPeriodFor(now)) {
      TodayGreetingPeriod.morning => l10n.todayGreetingMorning,
      TodayGreetingPeriod.afternoon => l10n.todayGreetingAfternoon,
      TodayGreetingPeriod.evening => l10n.todayGreetingEvening,
    };
    final rawName = user?.displayName?.trim();
    if (rawName != null && rawName.isNotEmpty) {
      return l10n.todayGreetingNamed(base, rawName);
    }
    return base;
  }

  /// Resolves localized title for a study plan scope (`subject?.name` or
  /// "All subjects").
  static String planScopeTitle({
    required bool isAllSubjects,
    required Subject? subject,
    required AppLocalizations l10n,
  }) {
    if (isAllSubjects) {
      return l10n.prepStudyPlanAllSubjectsLabel;
    }
    return subject?.name ?? l10n.prepStudyPlanSectionTitle;
  }

  /// Formats integer counts using active locale & Bangla-digit preference.
  static String formatCount(
    int value, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    return AppFormatters.formatNumber(
      value,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
  }

  /// Formats studied [seconds] into localized hours + minutes or minutes-only.
  static String formatStudiedDuration({
    required int seconds,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final totalMinutes = seconds <= 0 ? 0 : seconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) {
      return l10n.todayTimeStudiedHoursMinutes(
        formatCount(hours, locale: locale, useBanglaDigits: useBanglaDigits),
        formatCount(mins, locale: locale, useBanglaDigits: useBanglaDigits),
      );
    }
    return l10n.todayTimeStudiedMinutesOnly(
      formatCount(mins, locale: locale, useBanglaDigits: useBanglaDigits),
    );
  }

  /// Formats Phase 6C catch-up or past-buffer alert line.
  static String formatCatchUpMessage({
    required TodayCatchUpNotice notice,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final fmtRemaining = formatCount(
      notice.remainingUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final fmtMissed = formatCount(
      notice.missedUnits,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final fmtDays = formatCount(
      notice.studyDaysLeft,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final fmtExtra = AppFormatters.formatNumber(
      notice.dailyCatchUpExtra,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: 1,
    );

    final baseMessage = notice.isPastBufferOrTarget
        ? l10n.prepStudyPlanPastTargetNotice(fmtRemaining)
        : l10n.prepStudyPlanMissedRedistributed(
            notice.studyDaysLeft,
            fmtMissed,
            fmtDays,
            fmtExtra,
          );
    final scope = planScopeTitle(
      isAllSubjects: notice.planSnapshot.plan.isAllSubjects,
      subject: notice.subject,
      l10n: l10n,
    );
    return l10n.todayCatchUpSubjectLine(scope, baseMessage);
  }
}
