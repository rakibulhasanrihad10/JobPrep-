import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_chip.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

/// Deadline range and urgency preset filter controls inside the Circulars
/// filter panel.
class CircularDeadlineRangeFilter extends ConsumerWidget {
  /// Creates a [CircularDeadlineRangeFilter].
  const CircularDeadlineRangeFilter({
    required this.filter,
    super.key,
  });

  /// Active filter state.
  final CircularFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final filterNotifier = ref.read(circularFilterProvider.notifier);
    final now = ref.watch(circularNowProvider)();

    final hasNoDateRange =
        filter.deadlineFrom == null && filter.deadlineTo == null;
    final isAllDeadlines = filter.deadlineBand == null && hasNoDateRange;
    final isNext30Preset = _isNext30DaysActive(filter, now);

    String formatBound(DateTime? date, String fallback) {
      if (date == null) return fallback;
      return AppFormatters.formatDate(
        date,
        locale: locale,
        pattern: 'd MMM yyyy',
        useBanglaDigits: useBanglaDigits,
      );
    }

    Future<void> pickFromDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: filter.deadlineFrom ?? now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
      );
      if (picked != null) {
        final adjustedTo =
            filter.deadlineTo != null && filter.deadlineTo!.isBefore(picked)
                ? picked
                : filter.deadlineTo;
        filterNotifier
          ..setDeadlineBand(null)
          ..setDeadlineRange(from: picked, to: adjustedTo);
      }
    }

    Future<void> pickToDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: filter.deadlineTo ?? filter.deadlineFrom ?? now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
      );
      if (picked != null) {
        final adjustedFrom =
            filter.deadlineFrom != null && filter.deadlineFrom!.isAfter(picked)
                ? picked
                : filter.deadlineFrom;
        filterNotifier
          ..setDeadlineBand(null)
          ..setDeadlineRange(from: adjustedFrom, to: picked);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.circularsFilterDeadlineRange,
          style: tokens.textStyles.labelLarge,
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassChip(
              key: const ValueKey('filter-deadline-all'),
              isSelected: isAllDeadlines,
              label: Text(l10n.circularsDeadlineRangeAll),
              onTap: () => filterNotifier
                ..setDeadlineBand(null)
                ..setDeadlineRange(),
            ),
            GlassChip(
              key: const ValueKey('filter-deadline-red'),
              isSelected: filter.deadlineBand == DeadlineColorBand.red,
              label: Text(l10n.circularsDeadlineRangeUnder3OrOverdue),
              onTap: () => filterNotifier
                ..setDeadlineRange()
                ..setDeadlineBand(DeadlineColorBand.red),
            ),
            GlassChip(
              key: const ValueKey('filter-deadline-amber'),
              isSelected: filter.deadlineBand == DeadlineColorBand.amber,
              label: Text(l10n.circularsDeadlineRange3To7Days),
              onTap: () => filterNotifier
                ..setDeadlineRange()
                ..setDeadlineBand(DeadlineColorBand.amber),
            ),
            GlassChip(
              key: const ValueKey('filter-deadline-green'),
              isSelected: filter.deadlineBand == DeadlineColorBand.green,
              label: Text(l10n.circularsDeadlineRangeOver7Days),
              onTap: () => filterNotifier
                ..setDeadlineRange()
                ..setDeadlineBand(DeadlineColorBand.green),
            ),
            GlassChip(
              key: const ValueKey('filter-deadline-next30'),
              isSelected: isNext30Preset,
              label: Text(l10n.circularsDeadlineRangeNext30Days),
              onTap: () {
                final today = DateTime(now.year, now.month, now.day);
                filterNotifier
                  ..setDeadlineBand(null)
                  ..setDeadlineRange(
                    from: today,
                    to: today.add(const Duration(days: 30)),
                  );
              },
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassButton(
              key: const ValueKey('filter-deadline-from-btn'),
              onPressed: pickFromDate,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              leading: Icon(
                Icons.date_range_outlined,
                size: spacing.lg,
                color: tokens.colors.goldAccent,
              ),
              child: Text(
                formatBound(
                  filter.deadlineFrom,
                  l10n.circularsDeadlineFromLabel,
                ),
              ),
            ),
            GlassButton(
              key: const ValueKey('filter-deadline-to-btn'),
              onPressed: pickToDate,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              leading: Icon(
                Icons.event_outlined,
                size: spacing.lg,
                color: tokens.colors.goldAccent,
              ),
              child: Text(
                formatBound(filter.deadlineTo, l10n.circularsDeadlineToLabel),
              ),
            ),
            if (!hasNoDateRange)
              IconButton(
                key: const ValueKey('filter-deadline-clear-dates'),
                tooltip: l10n.circularsClearDatesTooltip,
                onPressed: filterNotifier.setDeadlineRange,
                icon: Icon(
                  Icons.close_rounded,
                  color: tokens.colors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  bool _isNext30DaysActive(CircularFilter filter, DateTime now) {
    final from = filter.deadlineFrom;
    final to = filter.deadlineTo;
    if (from == null || to == null) return false;
    final today = DateTime(now.year, now.month, now.day);
    final plus30 = today.add(const Duration(days: 30));
    return from.year == today.year &&
        from.month == today.month &&
        from.day == today.day &&
        to.year == plus30.year &&
        to.month == plus30.month &&
        to.day == plus30.day;
  }
}
