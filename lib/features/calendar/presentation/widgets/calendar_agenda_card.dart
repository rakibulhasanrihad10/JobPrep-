import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';

/// Displays the selected day's scheduled deadlines and exam stages as tappable
/// solid translucent agenda rows that navigate to circular detail.
class CalendarAgendaCard extends ConsumerWidget {
  /// Creates a [CalendarAgendaCard].
  const CalendarAgendaCard({
    required this.selectedDate,
    required this.events,
    required this.hasAnyMonthEvents,
    required this.isCompact,
    required this.onTapEvent,
    super.key,
  });

  /// Currently selected calendar day.
  final DateTime selectedDate;

  /// Ordered events occurring on [selectedDate].
  final List<CalendarEvent> events;

  /// Whether the active displayed month contains any events at all.
  final bool hasAnyMonthEvents;

  /// Whether compact phone padding should be used.
  final bool isCompact;

  /// Callback triggered when the user taps an agenda item.
  final ValueChanged<CalendarEvent> onTapEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = CalendarLocaleL10n.effectiveLocale(
      context,
      ref.watch(localeProvider),
    );
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    return GlassCard(
      key: const ValueKey('calendar-agenda-card'),
      padding: isCompact ? spacing.insetsAllMd : spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                CalendarLocaleL10n.selectedDayTitle(
                  selectedDate,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
                key: const ValueKey('calendar-agenda-date-title'),
                style: textStyles.titleMedium,
              ),
              Container(
                key: const ValueKey('calendar-agenda-count-badge'),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: radii.smRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Text(
                  CalendarLocaleL10n.agendaCountLabel(
                    events.length,
                    l10n,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                  style: textStyles.labelSmall.copyWith(
                    color:
                        events.isEmpty ? colors.textMuted : colors.goldAccent,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: colors.glassBorder, height: spacing.xl),
          if (events.isEmpty) ...[
            Text(
              l10n.calendarAgendaEmptyDay,
              key: const ValueKey('calendar-agenda-empty-text'),
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (!hasAnyMonthEvents) ...[
              SizedBox(height: spacing.sm),
              Text(
                l10n.calendarEmptyMonthHint,
                style: textStyles.bodySmall.copyWith(color: colors.textMuted),
              ),
            ],
          ] else ...[
            Column(
              key: const ValueKey('calendar-agenda-list'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  if (i > 0) SizedBox(height: spacing.sm),
                  _CalendarAgendaTile(
                    event: events[i],
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                    onTap: () => onTapEvent(events[i]),
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

class _CalendarAgendaTile extends StatelessWidget {
  const _CalendarAgendaTile({
    required this.event,
    required this.locale,
    required this.useBanglaDigits,
    required this.onTap,
  });

  final CalendarEvent event;
  final Locale locale;
  final bool useBanglaDigits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final kindColor = CalendarLocaleL10n.colorForKind(event.kind, colors);
    final kindLabel = CalendarLocaleL10n.labelForKind(event.kind, l10n);
    final timeLabel = CalendarLocaleL10n.eventTimeLabel(
      event.date,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final org = event.circular.organizationName?.trim() ?? '';
    final venue = event.examDate?.venue?.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('calendar-agenda-item-${event.id}'),
        borderRadius: radii.buttonRadius,
        onTap: onTap,
        child: Container(
          padding: spacing.insetsAllMd,
          decoration: BoxDecoration(
            color: colors.glassFillSolid,
            borderRadius: radii.buttonRadius,
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                key: ValueKey('calendar-agenda-accent-${event.id}'),
                width: spacing.xs,
                height: spacing.xxxl,
                decoration: BoxDecoration(
                  color: kindColor,
                  borderRadius: radii.smRadius,
                ),
              ),
              SizedBox(width: spacing.md),
              Container(
                padding: spacing.insetsAllSm,
                decoration: BoxDecoration(
                  color: kindColor.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                  border: Border.all(
                    color: kindColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  CalendarLocaleL10n.iconForKind(event.kind),
                  color: kindColor,
                  size: spacing.lg,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: kindColor.withValues(alpha: 0.14),
                            borderRadius: radii.smRadius,
                          ),
                          child: Text(
                            kindLabel,
                            style: textStyles.labelSmall.copyWith(
                              color: kindColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (timeLabel != null)
                          Text(
                            timeLabel,
                            style: textStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      event.circular.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.labelLarge,
                    ),
                    if (org.isNotEmpty || venue.isNotEmpty) ...[
                      SizedBox(height: spacing.xxs),
                      Text(
                        [
                          if (org.isNotEmpty) org,
                          if (venue.isNotEmpty) venue,
                        ].join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textMuted,
                semanticLabel: l10n.calendarOpenCircularAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
