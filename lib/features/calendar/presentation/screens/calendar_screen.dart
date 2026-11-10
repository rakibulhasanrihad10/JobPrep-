import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/domain/utils/calendar_grouping.dart';
import 'package:job_prep/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';
import 'package:job_prep/features/calendar/presentation/widgets/calendar_agenda_card.dart';
import 'package:job_prep/features/calendar/presentation/widgets/calendar_legend_bar.dart';
import 'package:job_prep/features/calendar/presentation/widgets/calendar_month_grid.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';

/// Responsive calendar screen displaying application deadlines and scheduled
/// exam stages on a month view with a selected-day agenda list.
class CalendarScreen extends ConsumerWidget {
  /// Creates a [CalendarScreen].
  const CalendarScreen({
    super.key,
    this.onOpenCircular,
  });

  /// Optional navigation override invoked when tapping a calendar agenda item.
  final ValueChanged<Circular>? onOpenCircular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final breakpoints = tokens.breakpoints;
    final l10n = context.l10n;

    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isCompact = breakpoints.isCompact(viewportWidth);
    final isExpanded = breakpoints.isExpanded(viewportWidth);

    final locale = CalendarLocaleL10n.effectiveLocale(
      context,
      ref.watch(localeProvider),
    );
    final firstDayOfWeek = CalendarLocaleL10n.resolveFirstDayOfWeek(
      context,
      locale,
    );

    final nowRaw = ref.watch(circularNowProvider)();
    final today = normalizeCalendarDate(
      nowRaw.isUtc ? nowRaw.toUtc() : nowRaw.toLocal(),
    );

    final viewState = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);
    final eventsAsync = ref.watch(calendarEventsByDateProvider);

    void openCircularDetail(CalendarEvent event) {
      if (onOpenCircular != null) {
        onOpenCircular!(event.circular);
        return;
      }
      unawaited(
        GoRouter.maybeOf(context)?.push<Object?>(
              '/circulars/${event.circular.id}',
              extra: event.circular,
            ) ??
            Future<Object?>.value(),
      );
    }

    final pagePadding = isCompact
        ? EdgeInsets.fromLTRB(
            spacing.md,
            spacing.lg,
            spacing.md,
            spacing.xl + spacing.xxxl,
          )
        : spacing.insetsAllXl;

    return SingleChildScrollView(
      key: const ValueKey('calendar-screen-scroll'),
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Text(
              l10n.calendarTitle,
              style: isCompact
                  ? textStyles.headlineMedium
                  : textStyles.headlineLarge,
            ),
          ),
          SizedBox(height: spacing.xs),
          FadeSlideIn(
            index: 1,
            child: Text(
              l10n.calendarSubtitle,
              style: textStyles.bodyMedium,
            ),
          ),
          SizedBox(height: isCompact ? spacing.md : spacing.lg),
          eventsAsync.when(
            loading: () => Center(
              child: Padding(
                padding: spacing.insetsAllXl,
                child: CircularProgressIndicator(color: colors.goldAccent),
              ),
            ),
            error: (error, _) => GlassCard(
              key: const ValueKey('calendar-error-card'),
              padding: spacing.insetsAllLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.calendarLoadError} '
                    '${CircularL10n.circularErrorMessage(error, l10n)}',
                    style: textStyles.bodyMedium.copyWith(color: colors.danger),
                  ),
                  SizedBox(height: spacing.md),
                  GlassButton(
                    key: const ValueKey('calendar-retry-btn'),
                    onPressed: () => unawaited(
                      ref.read(circularsListProvider.notifier).refresh(),
                    ),
                    child: Text(l10n.calendarRetry),
                  ),
                ],
              ),
            ),
            data: (eventsByDate) {
              final monthlyCounts = countMonthlyEventsByKind(
                eventsByDate,
                year: viewState.displayedMonth.year,
                month: viewState.displayedMonth.month,
              );
              final selectedEvents = eventsForCalendarDay(
                eventsByDate,
                viewState.selectedDate,
              );
              final hasAnyMonthEvents = monthlyCounts.values.any((c) => c > 0);

              final monthWidget = CalendarMonthGrid(
                displayedMonth: viewState.displayedMonth,
                selectedDate: viewState.selectedDate,
                today: today,
                firstDayOfWeek: firstDayOfWeek,
                eventsByDate: eventsByDate,
                isCompact: isCompact,
                onSelectDay: controller.selectDay,
                onPreviousMonth: controller.previousMonth,
                onNextMonth: controller.nextMonth,
                onGoToToday: controller.goToToday,
              );

              final agendaWidget = CalendarAgendaCard(
                selectedDate: viewState.selectedDate,
                events: selectedEvents,
                hasAnyMonthEvents: hasAnyMonthEvents,
                isCompact: isCompact,
                onTapEvent: openCircularDetail,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(
                    index: 2,
                    child: CalendarLegendBar(monthlyCounts: monthlyCounts),
                  ),
                  SizedBox(height: isCompact ? spacing.md : spacing.lg),
                  FadeSlideIn(
                    index: 3,
                    child: isExpanded
                        ? Row(
                            key: const ValueKey('calendar-desktop-layout'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 7, child: monthWidget),
                              SizedBox(width: spacing.lg),
                              Expanded(flex: 5, child: agendaWidget),
                            ],
                          )
                        : Column(
                            key: ValueKey(
                              isCompact
                                  ? 'calendar-mobile-layout'
                                  : 'calendar-tablet-layout',
                            ),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              monthWidget,
                              SizedBox(
                                height: isCompact ? spacing.md : spacing.lg,
                              ),
                              agendaWidget,
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
