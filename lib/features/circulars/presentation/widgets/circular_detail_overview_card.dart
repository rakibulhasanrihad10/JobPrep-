import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Structured metadata card presenting dates, vacancies, salary range,
/// application fee, priority, and timestamp fields for a [Circular].
class CircularDetailOverviewCard extends ConsumerWidget {
  /// Creates a [CircularDetailOverviewCard].
  const CircularDetailOverviewCard({
    required this.circular,
    super.key,
  });

  /// Active circular to display.
  final Circular circular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    String fmtDate(DateTime? dt, String fallback) {
      if (dt == null) return fallback;
      return AppFormatters.formatDate(
        dt.toLocal(),
        locale: locale,
        pattern: 'd MMM yyyy',
        useBanglaDigits: useBanglaDigits,
      );
    }

    final rows = <_DetailField>[
      _DetailField(
        label: l10n.circularFieldSectorLabel,
        value: CircularL10n.sectorLabel(circular.sector, l10n),
      ),
      _DetailField(
        label: l10n.circularFieldPriorityLabel,
        value: CircularL10n.priorityLabel(circular.priority, l10n),
      ),
      _DetailField(
        label: l10n.circularDetailFieldDeadline,
        value: fmtDate(circular.deadline, l10n.circularsCountdownNoDeadline),
      ),
      _DetailField(
        label: l10n.circularDetailFieldVacancies,
        value: CircularL10n.vacanciesLabel(
          circular.vacancies,
          l10n,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        ),
      ),
      _DetailField(
        label: l10n.circularDetailFieldSalary,
        value: _formatSalary(
          circular.salaryMin,
          circular.salaryMax,
          l10n: l10n,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        ),
      ),
      _DetailField(
        label: l10n.circularDetailFieldSalaryNote,
        value: _orNotProvided(circular.salaryNote, l10n),
      ),
      _DetailField(
        label: l10n.circularDetailFieldFee,
        value: circular.applicationFee != null
            ? AppFormatters.formatCurrency(
                circular.applicationFee!,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
              )
            : l10n.circularDetailNotProvided,
      ),
      _DetailField(
        label: l10n.circularDetailFieldFeeNote,
        value: _orNotProvided(circular.feeNote, l10n),
      ),
      _DetailField(
        label: l10n.circularDetailFieldCreated,
        value: fmtDate(circular.createdAt, l10n.circularDetailNotProvided),
      ),
      _DetailField(
        label: l10n.circularDetailFieldUpdated,
        value: fmtDate(circular.updatedAt, l10n.circularDetailNotProvided),
      ),
    ];

    return GlassCard(
      key: const ValueKey('circular-detail-overview-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: colors.goldAccent,
                  size: spacing.lg,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    l10n.circularDetailOverviewTitle,
                    style: textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    tokens.breakpoints.isCompact(constraints.maxWidth) ? 1 : 2;
                final spacingWidth = spacing.lg;
                final tileWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacingWidth) / 2;

                return Wrap(
                  spacing: spacingWidth,
                  runSpacing: spacing.md,
                  children: [
                    for (final field in rows)
                      SizedBox(
                        width: tileWidth,
                        child: _FieldEntry(field: field),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _orNotProvided(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? l10n.circularDetailNotProvided : trimmed;
  }

  String _formatSalary(
    double? min,
    double? max, {
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (min == null && max == null) {
      return l10n.circularDetailNotProvided;
    }
    String fmt(double v) => AppFormatters.formatCurrency(
          v,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );
    if (min != null && max != null) {
      return l10n.circularDetailSalaryRange(fmt(min), fmt(max));
    }
    if (min != null) {
      return l10n.circularDetailSalaryFrom(fmt(min));
    }
    return l10n.circularDetailSalaryUpTo(fmt(max!));
  }
}

class _DetailField {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;
}

class _FieldEntry extends StatelessWidget {
  const _FieldEntry({required this.field});

  final _DetailField field;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: tokens.textStyles.labelSmall.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: tokens.spacing.xxs),
        Text(
          field.value,
          style: tokens.textStyles.bodyMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
