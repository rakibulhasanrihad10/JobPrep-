import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';
import 'package:job_prep/features/calendar/presentation/widgets/calendar_day_tile.dart';

/// Interactive 7-column month calendar grid supporting locale-based start of
/// week, color-coded stage/deadline dots, and compact mobile sizing.
class CalendarMonthGrid extends ConsumerWidget {
  /// Creates a [CalendarMonthGrid].
  const CalendarMonthGrid({
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.firstDayOfWeek,
    required this.eventsByDate,
    required this.isCompact,
    required this.onSelectDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onGoToToday,
    super.key,
  });

  /// Displayed month (`DateTime(year, month)`).
  final DateTime displayedMonth;

  /// Selected day highlighted on the grid.
  final DateTime selectedDate;

  /// Current calendar date highlighted with a subtle ring.
  final DateTime today;

  /// First weekday column (`DateTime.monday = 1` .. `DateTime.sunday = 7`).
  final int firstDayOfWeek;

  /// Pre-grouped events mapped by normalized calendar day.
  final Map<DateTime, List<CalendarEvent>> eventsByDate;

  /// Whether compact phone sizing should be used.
  final bool isCompact;

  /// Callback when user taps a calendar day cell.
  final ValueChanged<DateTime> onSelectDay;

  /// Callback navigating backward one month.
  final VoidCallback onPreviousMonth;

  /// Callback navigating forward one month.
  final VoidCallback onNextMonth;

  /// Callback jumping selection back to [today].
  final VoidCallback onGoToToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = CalendarLocaleL10n.effectiveLocale(
      context,
      ref.watch(localeProvider),
    );
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final weekdays = orderedWeekdaysFrom(firstDayOfWeek: firstDayOfWeek);
    final cells = buildCalendarMonthGrid(
      year: displayedMonth.year,
      month: displayedMonth.month,
      firstDayOfWeek: firstDayOfWeek,
    );
    final weekCount = cells.length ~/ 7;
    final monthTitle = CalendarLocaleL10n.monthYearTitle(
      displayedMonth,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final firstDayFullName = CalendarLocaleL10n.weekdayFullLabel(
      firstDayOfWeek,
      locale: locale,
    );

    return GlassCard(
      key: ValueKey(
        isCompact ? 'calendar-month-card-compact' : 'calendar-month-card',
      ),
      padding: isCompact ? spacing.insetsAllMd : spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                monthTitle,
                key: const ValueKey('calendar-month-title'),
                style:
                    isCompact ? textStyles.titleMedium : textStyles.titleLarge,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const ValueKey('calendar-prev-month-btn'),
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.calendarPreviousMonthTooltip,
                    onPressed: onPreviousMonth,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  GlassButton(
                    key: const ValueKey('calendar-today-btn'),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    onPressed: onGoToToday,
                    child: Text(l10n.calendarTodayButton),
                  ),
                  SizedBox(width: spacing.xs),
                  IconButton(
                    key: const ValueKey('calendar-next-month-btn'),
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.calendarNextMonthTooltip,
                    onPressed: onNextMonth,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.calendarWeekStartsNote(firstDayFullName),
            key: const ValueKey('calendar-week-start-note'),
            style: textStyles.bodySmall.copyWith(color: colors.textMuted),
          ),
          SizedBox(height: spacing.md),
          Row(
            key: const ValueKey('calendar-weekday-row'),
            children: [
              for (var i = 0; i < weekdays.length; i++)
                Expanded(
                  child: Semantics(
                    label: CalendarLocaleL10n.weekdayFullLabel(
                      weekdays[i],
                      locale: locale,
                    ),
                    child: Container(
                      key: ValueKey('calendar-weekday-col-$i'),
                      padding: EdgeInsets.symmetric(vertical: spacing.xs),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CalendarLocaleL10n.weekdayShortLabel(
                            weekdays[i],
                            locale: locale,
                          ),
                          style: textStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.xs),
          for (var week = 0; week < weekCount; week++) ...[
            if (week > 0) SizedBox(height: spacing.xs),
            Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  if (col > 0) SizedBox(width: spacing.xs),
                  Expanded(
                    child: CalendarDayTile(
                      cell: cells[week * 7 + col],
                      isSelected: isSameCalendarDate(
                        cells[week * 7 + col].date,
                        selectedDate,
                      ),
                      isToday: isSameCalendarDate(
                        cells[week * 7 + col].date,
                        today,
                      ),
                      kinds: kindsForCalendarDay(
                        eventsByDate,
                        cells[week * 7 + col].date,
                      ),
                      isCompact: isCompact,
                      locale: locale,
                      useBanglaDigits: useBanglaDigits,
                      onTap: () => onSelectDay(cells[week * 7 + col].date),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
