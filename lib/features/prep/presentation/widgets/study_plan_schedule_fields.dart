import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Schedule configuration fields (start date, exam date, finish buffer, rest
/// days per week, and optional max daily pace) inside study plan forms.
class StudyPlanScheduleFields extends StatelessWidget {
  /// Creates a [StudyPlanScheduleFields].
  const StudyPlanScheduleFields({
    required this.startDate,
    required this.targetDate,
    required this.dateError,
    required this.bufferController,
    required this.maxPaceController,
    required this.restDaysPerWeek,
    required this.isBusy,
    required this.locale,
    required this.useBanglaDigits,
    required this.onPickDate,
    required this.onRestDaysChanged,
    super.key,
  });

  /// Selected start date.
  final DateTime startDate;

  /// Selected exam date.
  final DateTime targetDate;

  /// Optional date-ordering validation message.
  final String? dateError;

  /// Text controller for finish buffer days.
  final TextEditingController bufferController;

  /// Text controller for optional maximum daily pace cap.
  final TextEditingController maxPaceController;

  /// Selected rest days per week (`0..6`).
  final int restDaysPerWeek;

  /// Whether inputs are disabled during submission.
  final bool isBusy;

  /// Active locale for formatting dates and numbers.
  final Locale locale;

  /// Whether Bangla digits are enabled.
  final bool useBanglaDigits;

  /// Callback opening a date picker (`isStart = true` or `false`).
  final Future<void> Function({required bool isStart}) onPickDate;

  /// Callback updating [restDaysPerWeek].
  final ValueChanged<int> onRestDaysChanged;

  static int? _parseInt(String raw) {
    final ascii = AppFormatters.toEnglishDigits(raw.trim());
    return int.tryParse(ascii);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final startText = AppFormatters.formatDate(
      startDate,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );
    final targetText = AppFormatters.formatDate(
      targetDate,
      locale: locale,
      pattern: 'd MMM yyyy',
      useBanglaDigits: useBanglaDigits,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            GlassButton(
              key: const ValueKey('study-plan-start-date-button'),
              onPressed:
                  isBusy ? null : () => unawaited(onPickDate(isStart: true)),
              leading: Icon(Icons.today_outlined, size: spacing.lg),
              child: Text(l10n.prepStudyPlanStartDateValue(startText)),
            ),
            GlassButton(
              key: const ValueKey('study-plan-target-date-button'),
              onPressed:
                  isBusy ? null : () => unawaited(onPickDate(isStart: false)),
              leading: Icon(Icons.event_outlined, size: spacing.lg),
              child: Text(l10n.prepStudyPlanTargetDateValue(targetText)),
            ),
          ],
        ),
        if (dateError != null) ...[
          SizedBox(height: spacing.xs),
          Text(
            dateError!,
            style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
          ),
        ],
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('study-plan-buffer-field'),
          controller: bufferController,
          labelText: l10n.prepStudyPlanBufferDaysLabel,
          enabled: !isBusy,
          keyboardType: TextInputType.number,
          validator: (val) {
            final parsed = _parseInt(val ?? '');
            if (parsed == null || parsed < 0) {
              return l10n.prepStudyPlanValidationBuffer;
            }
            return null;
          },
        ),
        SizedBox(height: spacing.md),
        Text(
          l10n.prepStudyPlanRestDaysLabel,
          style: tokens.textStyles.labelLarge,
        ),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (var d = 0; d <= 6; d++)
              PrepOptionChip(
                key: ValueKey('study-plan-rest-$d'),
                label: AppFormatters.formatNumber(
                  d,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
                isSelected: restDaysPerWeek == d,
                onTap: isBusy ? null : () => onRestDaysChanged(d),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('study-plan-max-pace-field'),
          controller: maxPaceController,
          labelText: l10n.prepStudyPlanMaxPaceLabel,
          hintText: l10n.prepStudyPlanMaxPaceHint,
          enabled: !isBusy,
          keyboardType: TextInputType.number,
          validator: (val) {
            final trimmed = (val ?? '').trim();
            if (trimmed.isEmpty) return null;
            final parsed = _parseInt(trimmed);
            if (parsed == null || parsed <= 0) {
              return l10n.prepStudyPlanValidationPace;
            }
            return null;
          },
        ),
      ],
    );
  }
}
