import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';

/// Step 2: Lets the user pick Government job exams, Private software jobs, or
/// a completely blank start for any other career track.
class OnboardingStepTrack extends ConsumerWidget {
  /// Creates an [OnboardingStepTrack].
  const OnboardingStepTrack({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final selectedTrack = ref.watch(
      onboardingWizardControllerProvider.select((s) => s.draft.track),
    );
    final controller = ref.read(onboardingWizardControllerProvider.notifier);

    final options = [
      (
        track: OnboardingTrack.government,
        icon: Icons.account_balance_outlined,
        title: l10n.onboardingTrackGovernmentTitle,
        desc: l10n.onboardingTrackGovernmentDesc,
      ),
      (
        track: OnboardingTrack.software,
        icon: Icons.code_rounded,
        title: l10n.onboardingTrackSoftwareTitle,
        desc: l10n.onboardingTrackSoftwareDesc,
      ),
      (
        track: OnboardingTrack.blank,
        icon: Icons.dashboard_customize_outlined,
        title: l10n.onboardingTrackBlankTitle,
        desc: l10n.onboardingTrackBlankDesc,
      ),
    ];

    return GlassCard(
      key: const ValueKey('onboarding-step-2'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingTrackTitle,
            style: tokens.textStyles.headlineMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.onboardingTrackSubtitle,
            style: tokens.textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.lg),
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.md),
            _TrackCardOption(
              key: ValueKey('onboarding-track-${options[i].track.value}'),
              icon: options[i].icon,
              title: options[i].title,
              description: options[i].desc,
              selected: selectedTrack == options[i].track,
              onTap: () => controller.selectTrack(options[i].track),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackCardOption extends StatelessWidget {
  const _TrackCardOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Material(
      color: selected ? colors.goldAccentSubtle : colors.surfaceElevated,
      borderRadius: radii.cardRadius,
      child: InkWell(
        borderRadius: radii.cardRadius,
        onTap: onTap,
        child: Container(
          padding: spacing.insetsAllLg,
          decoration: BoxDecoration(
            borderRadius: radii.cardRadius,
            border: Border.all(
              color: selected ? colors.goldAccent : colors.glassBorder,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: spacing.insetsAllSm,
                decoration: BoxDecoration(
                  color: selected ? colors.surface : colors.glassFill,
                  borderRadius: radii.buttonRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Icon(
                  icon,
                  color: selected ? colors.goldAccent : colors.textSecondary,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tokens.textStyles.titleMedium.copyWith(
                        color:
                            selected ? colors.goldAccent : colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      description,
                      style: tokens.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.goldAccent : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
