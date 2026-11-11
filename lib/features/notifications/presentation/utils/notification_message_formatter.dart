import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Resolves localized notification copy, type badges, weekday labels, and
/// Weekly Review suggestions from ARB templates and domain parameters.
abstract final class NotificationMessageFormatter {
  /// Returns the localized category badge label for [type].
  static String typeLabel(AppNotificationType type, AppLocalizations l10n) {
    return switch (type) {
      AppNotificationType.deadlineSoon => l10n.notificationTypeDeadlineSoon,
      AppNotificationType.examSoon => l10n.notificationTypeExamSoon,
      AppNotificationType.revisionDue => l10n.notificationTypeRevisionDue,
      AppNotificationType.behindSchedule => l10n.notificationTypeBehindSchedule,
      AppNotificationType.weeklyReview => l10n.notificationTypeWeeklyReview,
    };
  }

  /// Resolves `notification.messageKey` and `notification.params` in [locale].
  static String formatMessage({
    required AppNotification notification,
    required AppLocalizations l10n,
    required Locale locale,
    bool useBanglaDigits = false,
  }) {
    final params = notification.params;
    switch (notification.messageKey) {
      case 'notificationMsgDeadlineSoon':
        final days = _intParam(params, 'days', fallback: 1);
        final title = _stringParam(params, 'title');
        final formattedDays = AppFormatters.formatNumber(
          days,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
        final formattedDate = _formatDateParam(
          params['targetDate'],
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
        return l10n.notificationMsgDeadlineSoon(
          days,
          title,
          formattedDays,
          formattedDate,
        );

      case 'notificationMsgExamSoon':
        final days = _intParam(params, 'days', fallback: 1);
        final title = _stringParam(params, 'title');
        final rawStage = _stringParam(params, 'stage');
        final stageLabel = CircularL10n.examStageDisplayLabel(rawStage, l10n);
        final formattedDays = AppFormatters.formatNumber(
          days,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
        final formattedDate = _formatDateParam(
          params['targetDate'],
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
        return l10n.notificationMsgExamSoon(
          days,
          title,
          stageLabel,
          formattedDays,
          formattedDate,
        );

      case 'notificationMsgRevisionDue':
        final count = _intParam(params, 'count', fallback: 1);
        final formattedCount = AppFormatters.formatNumber(
          count,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
        return l10n.notificationMsgRevisionDue(count, formattedCount);

      case 'notificationMsgBehindScheduleSubject':
        final subject = _stringParam(params, 'subject');
        if (subject.isEmpty) return l10n.notificationMsgBehindScheduleAll;
        return l10n.notificationMsgBehindScheduleSubject(subject);

      case 'notificationMsgBehindScheduleAll':
        return l10n.notificationMsgBehindScheduleAll;

      case 'notificationMsgWeeklyReview':
        return l10n.notificationMsgWeeklyReview;

      default:
        return switch (notification.type) {
          AppNotificationType.deadlineSoon => l10n.notificationTypeDeadlineSoon,
          AppNotificationType.examSoon => l10n.notificationTypeExamSoon,
          AppNotificationType.revisionDue => l10n.notificationTypeRevisionDue,
          AppNotificationType.behindSchedule =>
            l10n.notificationMsgBehindScheduleAll,
          AppNotificationType.weeklyReview => l10n.notificationMsgWeeklyReview,
        };
    }
  }

  /// Resolves the localized single focus suggestion for [summary].
  static String formatWeeklySuggestion({
    required WeeklyReviewSummary summary,
    required AppLocalizations l10n,
    required Locale locale,
    bool useBanglaDigits = false,
  }) {
    final param = summary.suggestionParam?.trim() ?? '';
    return switch (summary.suggestionKind) {
      WeeklyReviewSuggestionKind.prioritizeNearestDeadline =>
        l10n.weeklyReviewSuggestionDeadline(param),
      WeeklyReviewSuggestionKind.catchUpBehindPlan => param.isNotEmpty
          ? l10n.weeklyReviewSuggestionBehindSubject(param)
          : l10n.weeklyReviewSuggestionBehindAll,
      WeeklyReviewSuggestionKind.startLoggingRoutine =>
        l10n.weeklyReviewSuggestionStart,
      WeeklyReviewSuggestionKind.reduceMissedDays =>
        l10n.weeklyReviewSuggestionMissedDays(
          AppFormatters.formatNumber(
            summary.missedDaysCount,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
        ),
      WeeklyReviewSuggestionKind.boostMockPractice =>
        l10n.weeklyReviewSuggestionMock,
      WeeklyReviewSuggestionKind.clearOverdueRevision =>
        l10n.weeklyReviewSuggestionRevision(
          AppFormatters.formatNumber(
            int.tryParse(param) ?? 1,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          ),
        ),
      WeeklyReviewSuggestionKind.maintainStrongStreak =>
        l10n.weeklyReviewSuggestionMaintain,
    };
  }

  /// Localized weekday label for `0` (Sunday) .. `6` (Saturday) via `intl`.
  static String formatWeekdayName(
    int weekdayIndex, {
    required Locale locale,
    bool abbreviated = false,
  }) {
    final normalized = weekdayIndex.clamp(0, 6);
    // 2026-11-15 is a Sunday.
    final sampleDate = DateTime.utc(2026, 11, 15 + normalized);
    final fmt = abbreviated
        ? DateFormat.E(locale.languageCode)
        : DateFormat.EEEE(locale.languageCode);
    return fmt.format(sampleDate);
  }

  static String _formatDateParam(
    Object? raw, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (raw is! String || raw.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return raw.trim();
    return AppFormatters.formatDate(
      parsed,
      locale: locale,
      pattern: 'd MMM',
      useBanglaDigits: useBanglaDigits,
    );
  }

  static int _intParam(
    Map<String, Object?> params,
    String key, {
    int fallback = 0,
  }) {
    final raw = params[key];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? fallback;
    return fallback;
  }

  static String _stringParam(Map<String, Object?> params, String key) {
    final raw = params[key];
    return raw == null ? '' : raw.toString().trim();
  }
}
