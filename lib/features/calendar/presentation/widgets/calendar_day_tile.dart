import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';

/// Interactive day cell inside `CalendarMonthGrid` showing the localized date
/// numeral and distinct colored indicator dots for scheduled event types.
class CalendarDayTile extends StatelessWidget {
  /// Creates a [CalendarDayTile].
  const CalendarDayTile({
    required this.cell,
    required this.isSelected,
    required this.isToday,
    required this.kinds,
    required this.isCompact,
    required this.locale,
    required this.useBanglaDigits,
    required this.onTap,
    super.key,
  });

  /// Calendar date metadata for this cell.
  final CalendarDayCell cell;

  /// Whether this cell matches the selected agenda date.
  final bool isSelected;

  /// Whether this cell falls on the current date (`today`).
  final bool isToday;

  /// Distinct event categories scheduled on this date.
  final List<CalendarEventKind> kinds;

  /// Whether compact phone sizing should be used.
  final bool isCompact;

  /// Active locale used for digit localization.
  final Locale locale;

  /// Whether Bangla numerals are forced.
  final bool useBanglaDigits;

  /// Callback when the day cell is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;

    final cellDate = cell.date;
    final visibleKinds = kinds.take(4).toList();
    final overflowCount = kinds.length - visibleKinds.length;

    final backgroundColor = isSelected
        ? colors.goldAccentSubtle
        : cell.inCurrentMonth
            ? colors.surfaceElevated
            : colors.glassFillSolid.withValues(alpha: 0.35);

    final borderColor = isSelected
        ? colors.goldAccent
        : isToday
            ? colors.goldAccent.withValues(alpha: 0.6)
            : colors.glassBorder;

    final dayTextColor = isSelected
        ? colors.goldAccent
        : cell.inCurrentMonth
            ? colors.textPrimary
            : colors.textMuted;

    final dotSize = isCompact ? spacing.xs + spacing.xxs : spacing.sm;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey(
          'calendar-day-${cellDate.year}-${cellDate.month}-${cellDate.day}',
        ),
        borderRadius: radii.buttonRadius,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            minHeight: isCompact ? spacing.xxxl : spacing.xxxl + spacing.sm,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xxs,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: radii.buttonRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected ? spacing.xxs : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CalendarLocaleL10n.dayNumberLabel(
                  cellDate.day,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
                style:
                    (isCompact ? textStyles.labelMedium : textStyles.labelLarge)
                        .copyWith(
                  color: dayTextColor,
                  fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (visibleKinds.isNotEmpty)
                Wrap(
                  spacing: spacing.xxs,
                  runSpacing: spacing.xxs,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final kind in visibleKinds)
                      Container(
                        key: ValueKey(
                          'calendar-dot-${cellDate.year}-'
                          '${cellDate.month}-${cellDate.day}-${kind.name}',
                        ),
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: CalendarLocaleL10n.colorForKind(kind, colors),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (overflowCount > 0)
                      Text(
                        CalendarLocaleL10n.moreCountLabel(
                          overflowCount,
                          context.l10n,
                          locale: locale,
                          useBanglaDigits: useBanglaDigits,
                        ),
                        style: textStyles.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                )
              else
                SizedBox(height: dotSize),
            ],
          ),
        ),
      ),
    );
  }
}
