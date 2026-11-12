import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/notifications/presentation/utils/notification_message_formatter.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Step 4: Exam target date (or "I don't know yet"), weekly study days &
/// rest-day weekdays, and optional maximum daily unit pace.
class OnboardingStepSchedule extends ConsumerWidget {
  /// Creates an [OnboardingStepSchedule].
  const OnboardingStepSchedule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final state = ref.watch(onboardingWizardControllerProvider);
    final draft = state.draft;
    final controller = ref.read(onboardingWizardControllerProvider.notifier);

    final examDateText = draft.examDate == null
        ? l10n.onboardingExamDatePickButton
        : AppFormatters.formatDate(
            draft.examDate!,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
          );
    final studyDaysCount = draft.studyDaysPerWeek;
    final studyDaysBadge = l10n.onboardingStudyDaysCount(
      studyDaysCount,
      AppFormatters.formatNumber(
        studyDaysCount,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
    );

    return GlassCard(
      key: const ValueKey('onboarding-step-4'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingScheduleTitle,
            style: tokens.textStyles.headlineMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.onboardingScheduleSubtitle,
            style: tokens.textStyles.bodyMedium,
          ),
          if (state.scheduleError != null) ...[
            SizedBox(height: spacing.md),
            Text(
              _errorMessage(state.scheduleError!, l10n),
              key: const ValueKey('onboarding-step4-error'),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: spacing.lg),
          Text(
            l10n.onboardingExamDateLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.sm),
          GlassButton(
            key: const ValueKey('onboarding-pick-exam-date-btn'),
            onPressed: draft.dontKnowExamDate
                ? null
                : () => unawaited(
                      _pickExamDate(
                        context,
                        ref,
                        draft.examDate,
                        controller,
                      ),
                    ),
            leading: Icon(Icons.event_outlined, size: spacing.lg),
            child: Text(examDateText),
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.onboardingExamDateUnknownToggle,
                  style: tokens.textStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Switch(
                key: const ValueKey('onboarding-exam-unknown-switch'),
                value: draft.dontKnowExamDate,
                onChanged: (val) =>
                    controller.setDontKnowExamDate(dontKnow: val),
              ),
            ],
          ),
          if (draft.dontKnowExamDate)
            Text(
              l10n.onboardingExamDateUnknownNote,
              style: tokens.textStyles.bodySmall,
            ),
          SizedBox(height: spacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.onboardingStudyDaysLabel,
                  style: tokens.textStyles.labelLarge,
                ),
              ),
              Text(
                studyDaysBadge,
                key: const ValueKey('onboarding-study-days-badge'),
                style: tokens.textStyles.labelLarge.copyWith(
                  color: colors.goldAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (var count = 1; count <= 7; count++)
                _DaySquareButton(
                  key: ValueKey('onboarding-study-days-$count'),
                  label: AppFormatters.formatNumber(
                    count,
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                  ),
                  selected: studyDaysCount == count,
                  radii: radii.buttonRadius,
                  onTap: () => controller.setStudyDaysPerWeek(count),
                ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Text(
            l10n.onboardingRestDaysLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                _DaySquareButton(
                  key: ValueKey('onboarding-rest-day-$weekday'),
                  label: NotificationMessageFormatter.formatWeekdayName(
                    weekday,
                    locale: locale,
                    abbreviated: true,
                  ),
                  selected: draft.restWeekdays.contains(weekday),
                  radii: radii.buttonRadius,
                  onTap: () => controller.toggleRestWeekday(weekday),
                ),
            ],
          ),
          SizedBox(height: spacing.xl),
          GlassTextField(
            key: const ValueKey('onboarding-max-pace-input'),
            initialValue: state.maxDailyPaceInput,
            keyboardType: TextInputType.number,
            labelText: l10n.onboardingMaxPaceLabel,
            hintText: l10n.onboardingMaxPaceHint,
            onChanged: controller.setMaxDailyPaceInput,
          ),
        ],
      ),
    );
  }

  Future<void> _pickExamDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
    OnboardingWizardController controller,
  ) async {
    final now = ref.read(onboardingNowProvider)();
    final todayCal = DateTime(now.year, now.month, now.day);
    final initial = current != null && !current.isBefore(todayCal)
        ? current
        : todayCal.add(const Duration(days: 60));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: todayCal,
      lastDate: todayCal.add(const Duration(days: 1095)),
    );
    if (picked != null) {
      controller.setExamDate(picked);
    }
  }

  String _errorMessage(
    OnboardingScheduleValidationError error,
    AppLocalizations l10n,
  ) {
    return switch (error) {
      OnboardingScheduleValidationError.missingExamDate =>
        l10n.onboardingValidationMissingExamDate,
      OnboardingScheduleValidationError.pastExamDate =>
        l10n.onboardingValidationPastExamDate,
      OnboardingScheduleValidationError.noStudyDaysSelected =>
        l10n.onboardingValidationNoStudyDays,
      OnboardingScheduleValidationError.invalidMaxDailyPace =>
        l10n.onboardingValidationInvalidMaxPace,
    };
  }
}

class _DaySquareButton extends StatelessWidget {
  const _DaySquareButton({
    required this.label,
    required this.selected,
    required this.radii,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final BorderRadius radii;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return Material(
      color: selected ? colors.goldAccentSubtle : colors.surfaceElevated,
      borderRadius: radii,
      child: InkWell(
        borderRadius: radii,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: radii,
            border: Border.all(
              color: selected ? colors.goldAccent : colors.glassBorder,
            ),
          ),
          child: Text(
            label,
            style: tokens.textStyles.labelMedium.copyWith(
              color: selected ? colors.goldAccent : colors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
