import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';

/// Step 6: Concise review of track, subjects, weekly schedule, optional
/// circular capture, and final idempotent setup trigger.
class OnboardingStepFinish extends ConsumerWidget {
  /// Creates an [OnboardingStepFinish].
  const OnboardingStepFinish({super.key});

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

    final enabledSubjects = draft.subjects.where((s) => s.enabled).toList();
    final materialCount = enabledSubjects.fold<int>(
      0,
      (sum, s) => sum + s.materials.length,
    );

    final trackLabel = switch (draft.track) {
      OnboardingTrack.government => l10n.onboardingTrackGovernmentTitle,
      OnboardingTrack.software => l10n.onboardingTrackSoftwareTitle,
      OnboardingTrack.blank => l10n.onboardingTrackBlankTitle,
    };

    final subjectsSummary = l10n.onboardingSummarySubjectsValue(
      enabledSubjects.length,
      AppFormatters.formatNumber(
        enabledSubjects.length,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
      AppFormatters.formatNumber(
        materialCount,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
    );

    final studyDaysText = l10n.onboardingStudyDaysCount(
      draft.studyDaysPerWeek,
      AppFormatters.formatNumber(
        draft.studyDaysPerWeek,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      ),
    );

    final scheduleText = draft.dontKnowExamDate || draft.examDate == null
        ? l10n.onboardingSummaryScheduleUnknown(studyDaysText)
        : l10n.onboardingSummaryScheduleExam(
            AppFormatters.formatDate(
              draft.examDate!,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
            ),
            studyDaysText,
          );

    final circularText = draft.circularLink.trim().isEmpty
        ? l10n.onboardingSummaryCircularSkipped
        : l10n.onboardingSummaryCircularPending(
            draft.circularTitle.trim().isNotEmpty
                ? draft.circularTitle.trim()
                : draft.circularLink.trim(),
          );

    return GlassCard(
      key: const ValueKey('onboarding-step-6'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingFinishTitle,
            style: tokens.textStyles.headlineMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.onboardingFinishSubtitle,
            style: tokens.textStyles.bodyMedium,
          ),
          if (state.applyFailed) ...[
            SizedBox(height: spacing.md),
            Text(
              l10n.onboardingApplyError,
              key: const ValueKey('onboarding-apply-error'),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: spacing.lg),
          _SummaryRow(
            icon: Icons.track_changes_outlined,
            label: l10n.onboardingSummaryTrackLabel,
            value: trackLabel,
            borderRadius: radii.cardRadius,
          ),
          SizedBox(height: spacing.sm),
          _SummaryRow(
            icon: Icons.menu_book_outlined,
            label: l10n.navPrep,
            value: subjectsSummary,
            borderRadius: radii.cardRadius,
          ),
          SizedBox(height: spacing.sm),
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.prepStudyPlanSectionTitle,
            value: scheduleText,
            extra: draft.maxDailyPace != null
                ? l10n.onboardingSummaryPaceLabel(
                    AppFormatters.formatNumber(
                      draft.maxDailyPace!,
                      locale: locale,
                      useBanglaDigits: useBanglaDigits,
                    ),
                  )
                : null,
            borderRadius: radii.cardRadius,
          ),
          SizedBox(height: spacing.sm),
          _SummaryRow(
            icon: Icons.work_outline,
            label: l10n.navCirculars,
            value: circularText,
            borderRadius: radii.cardRadius,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.borderRadius,
    this.extra,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? extra;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return Container(
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: borderRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: spacing.lg, color: colors.goldAccent),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tokens.textStyles.labelMedium),
                SizedBox(height: spacing.xxs),
                Text(
                  value,
                  style: tokens.textStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (extra != null) ...[
                  SizedBox(height: spacing.xxs),
                  Text(extra!, style: tokens.textStyles.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
