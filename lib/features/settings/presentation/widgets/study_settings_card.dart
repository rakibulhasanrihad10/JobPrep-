import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';

/// Study section card configuring default Focus/Break timer lengths and letting
/// users reopen the onboarding wizard cleanly (`Run setup again`).
class StudySettingsCard extends ConsumerStatefulWidget {
  /// Creates a [StudySettingsCard].
  const StudySettingsCard({super.key});

  @override
  ConsumerState<StudySettingsCard> createState() => _StudySettingsCardState();
}

class _StudySettingsCardState extends ConsumerState<StudySettingsCard> {
  final TextEditingController _focusController = TextEditingController();
  final TextEditingController _shortBreakController = TextEditingController();
  final TextEditingController _longBreakController = TextEditingController();
  bool _seeded = false;
  bool _savingTimer = false;
  bool _rerunningSetup = false;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void dispose() {
    _focusController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  Future<void> _saveTimerDefaults() async {
    final l10n = context.l10n;
    final focus = int.tryParse(_focusController.text.trim());
    final shortBreak = int.tryParse(_shortBreakController.text.trim());
    final longBreak = int.tryParse(_longBreakController.text.trim());

    final valid = focus != null &&
        shortBreak != null &&
        longBreak != null &&
        focus >= UserAppSettings.minFocusMinutes &&
        focus <= UserAppSettings.maxFocusMinutes &&
        shortBreak >= UserAppSettings.minShortBreakMinutes &&
        shortBreak <= UserAppSettings.maxShortBreakMinutes &&
        longBreak >= UserAppSettings.minLongBreakMinutes &&
        longBreak <= UserAppSettings.maxLongBreakMinutes;

    if (!valid) {
      setState(() {
        _statusIsError = true;
        _statusMessage = l10n.settingsStudyTimerInvalidError;
      });
      return;
    }

    setState(() {
      _savingTimer = true;
      _statusMessage = null;
    });

    await ref.read(userSettingsProvider.notifier).updateStudyTimerDefaults(
          focusMinutes: focus,
          shortBreakMinutes: shortBreak,
          longBreakMinutes: longBreak,
        );

    if (!mounted) return;
    setState(() {
      _savingTimer = false;
      _statusIsError = false;
      _statusMessage = l10n.settingsStudyTimerSaved;
    });
  }

  Future<void> _rerunSetup() async {
    setState(() => _rerunningSetup = true);
    final router = GoRouter.maybeOf(context);
    await ref.read(onboardingStatusProvider.notifier).runSetupAgain();
    if (!mounted) return;
    setState(() => _rerunningSetup = false);
    router?.go(AppRoutePaths.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final config = ref.watch(pomodoroConfigProvider);

    if (!_seeded) {
      _seeded = true;
      _focusController.text = '${config.focusMinutes}';
      _shortBreakController.text = '${config.shortBreakMinutes}';
      _longBreakController.text = '${config.longBreakMinutes}';
    }

    return GlassCard(
      key: const ValueKey('settings-study-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsStudyTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsStudySubtitle,
            style: tokens.textStyles.bodySmall,
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              SizedBox(
                width: 165,
                child: GlassTextField(
                  key: const ValueKey('settings-timer-focus-input'),
                  controller: _focusController,
                  enabled: !_savingTimer,
                  keyboardType: TextInputType.number,
                  labelText: l10n.settingsTimerFocusMinutesLabel,
                ),
              ),
              SizedBox(
                width: 165,
                child: GlassTextField(
                  key: const ValueKey('settings-timer-short-break-input'),
                  controller: _shortBreakController,
                  enabled: !_savingTimer,
                  keyboardType: TextInputType.number,
                  labelText: l10n.settingsTimerShortBreakLabel,
                ),
              ),
              SizedBox(
                width: 165,
                child: GlassTextField(
                  key: const ValueKey('settings-timer-long-break-input'),
                  controller: _longBreakController,
                  enabled: !_savingTimer,
                  keyboardType: TextInputType.number,
                  labelText: l10n.settingsTimerLongBreakLabel,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GlassButton(
                key: const ValueKey('settings-save-timer-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: _savingTimer ? null : _saveTimerDefaults,
                child: Text(l10n.settingsStudySaveTimerButton),
              ),
              GlassButton(
                key: const ValueKey('settings-run-setup-again-btn'),
                onPressed: _rerunningSetup ? null : _rerunSetup,
                leading: Icon(Icons.auto_fix_high_rounded, size: spacing.lg),
                child: Text(l10n.settingsRunSetupAgainButton),
              ),
            ],
          ),
          if (_statusMessage != null) ...[
            SizedBox(height: spacing.sm),
            Text(
              _statusMessage!,
              key: const ValueKey('settings-study-timer-status'),
              style: tokens.textStyles.bodySmall.copyWith(
                color: _statusIsError ? colors.danger : colors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
