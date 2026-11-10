import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/calendar/domain/entities/calendar_event.dart';
import 'package:job_prep/features/calendar/presentation/utils/calendar_locale_l10n.dart';

/// Displays color legend badges for application deadlines and exam stages
/// (`preliminary`, `written`, `viva`, plus `practical`/`other` when scheduled).
class CalendarLegendBar extends ConsumerWidget {
  /// Creates a [CalendarLegendBar].
  const CalendarLegendBar({
    required this.monthlyCounts,
    super.key,
  });

  /// Event counts per [CalendarEventKind] for the displayed month.
  final Map<CalendarEventKind, int> monthlyCounts;

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

    final visibleKinds = <CalendarEventKind>[
      CalendarEventKind.deadline,
      CalendarEventKind.preliminary,
      CalendarEventKind.written,
      CalendarEventKind.viva,
      if ((monthlyCounts[CalendarEventKind.practical] ?? 0) > 0)
        CalendarEventKind.practical,
      if ((monthlyCounts[CalendarEventKind.other] ?? 0) > 0)
        CalendarEventKind.other,
    ];

    return GlassCard(
      key: const ValueKey('calendar-legend-card'),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.calendarLegendTitle,
            style: textStyles.labelMedium.copyWith(color: colors.textMuted),
          ),
          for (final kind in visibleKinds)
            Row(
              key: ValueKey('calendar-legend-${kind.name}'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: spacing.sm,
                  height: spacing.sm,
                  decoration: BoxDecoration(
                    color: CalendarLocaleL10n.colorForKind(kind, colors),
                    borderRadius: radii.smRadius,
                  ),
                ),
                SizedBox(width: spacing.xs),
                Text(
                  CalendarLocaleL10n.labelForKind(kind, l10n),
                  style: textStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if ((monthlyCounts[kind] ?? 0) > 0) ...[
                  SizedBox(width: spacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.xs,
                      vertical: spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: radii.smRadius,
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Text(
                      AppFormatters.formatNumber(
                        monthlyCounts[kind]!,
                        locale: locale,
                        useBanglaDigits: useBanglaDigits,
                      ),
                      style: textStyles.labelSmall.copyWith(
                        color: CalendarLocaleL10n.colorForKind(kind, colors),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
