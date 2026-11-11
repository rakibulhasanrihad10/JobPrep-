import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_state.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_session_finish_sheet.dart';

/// Compact floating timer control displayed on every authenticated shell route
/// while a study session is active (running or paused), also keeping the
/// browser tab title synced to the active locale.
class StudyTimerFloatingBar extends ConsumerStatefulWidget {
  /// Creates a [StudyTimerFloatingBar].
  const StudyTimerFloatingBar({super.key});

  @override
  ConsumerState<StudyTimerFloatingBar> createState() =>
      _StudyTimerFloatingBarState();
}

class _StudyTimerFloatingBarState extends ConsumerState<StudyTimerFloatingBar> {
  StudyTimerController? _boundController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerLocalizedTitleBuilder();
  }

  @override
  void dispose() {
    _boundController?.setTabTitleBuilder(null);
    super.dispose();
  }

  void _registerLocalizedTitleBuilder() {
    final l10n = context.l10n;
    final locale = ref.read(localeProvider);
    final useBanglaDigits = ref.read(useBanglaDigitsProvider);
    final controller = ref.read(studyTimerControllerProvider.notifier);
    _boundController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.setTabTitleBuilder(
        (session, eval) => StudyTimerL10n.buildBrowserTabTitle(
          session: session,
          evaluation: eval,
          l10n: l10n,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        ),
      );
    });
  }

  Future<void> _openFinish(
    StudyTimerState timerState,
    Subject? subject,
    PrepMaterial? material,
  ) async {
    final session = timerState.activeSession;
    if (session == null) return;
    final notifier = ref.read(studyTimerControllerProvider.notifier);
    if (timerState.isRunning) {
      await notifier.pause();
    }
    if (!mounted) return;
    final latest = ref.read(studyTimerControllerProvider);
    final latestSession = latest.activeSession ?? session;
    await showStudySessionFinishSheet(
      context,
      activeSession: latestSession,
      studiedSeconds: latest.evaluation?.studiedSeconds ?? 0,
      subject: subject,
      material: material,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    ref
      ..listen<Locale>(
        localeProvider,
        (_, __) => _registerLocalizedTitleBuilder(),
      )
      ..listen<bool>(
        useBanglaDigitsProvider,
        (_, __) => _registerLocalizedTitleBuilder(),
      );

    final timerState = ref.watch(studyTimerControllerProvider);
    final session = timerState.activeSession;
    if (session == null) return const SizedBox.shrink();

    final eval = timerState.evaluation;
    final subjects =
        ref.watch(subjectsProvider).asData?.value ?? const <Subject>[];
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final subject =
        subjects.where((s) => s.id == session.subjectId).firstOrNull;
    final material = session.materialId == null
        ? null
        : materials.where((m) => m.id == session.materialId).firstOrNull;

    final shownSeconds = session.mode == StudySessionMode.focus
        ? (eval?.phaseRemainingSeconds ?? 0)
        : (eval?.studiedSeconds ?? 0);
    final clockText = StudyTimerL10n.formatClock(
      shownSeconds,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final accent = PrepStyleTokens.resolveSubjectColor(
      subject?.color ?? 'gold',
      colors,
    );
    final borderColor = timerState.roundAlert != null
        ? colors.success
        : (timerState.isPaused ? colors.warning : colors.goldAccent);

    final isCompact = tokens.breakpoints.isCompact(
      MediaQuery.sizeOf(context).width,
    );

    return Positioned(
      right: spacing.lg,
      bottom: isCompact ? 136 : spacing.lg,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 328),
        child: GlassCard(
          key: const ValueKey('study-timer-floating-bar'),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          borderColor: borderColor.withValues(alpha: 0.75),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: spacing.sm,
                height: spacing.sm,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              SizedBox(width: spacing.sm),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clockText,
                      key: const ValueKey('floating-timer-clock'),
                      style: tokens.textStyles.titleMedium.copyWith(
                        color: borderColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (subject != null)
                      Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tokens.textStyles.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: spacing.xs),
              if (timerState.isRunning)
                IconButton(
                  key: const ValueKey('floating-timer-pause-btn'),
                  tooltip: l10n.prepTimerPauseButton,
                  visualDensity: VisualDensity.compact,
                  onPressed: timerState.isBusy
                      ? null
                      : () => unawaited(
                            ref
                                .read(studyTimerControllerProvider.notifier)
                                .pause(),
                          ),
                  icon: Icon(Icons.pause_rounded, size: spacing.lg),
                )
              else
                IconButton(
                  key: const ValueKey('floating-timer-resume-btn'),
                  tooltip: l10n.prepTimerResumeButton,
                  visualDensity: VisualDensity.compact,
                  onPressed: timerState.isBusy
                      ? null
                      : () => unawaited(
                            ref
                                .read(studyTimerControllerProvider.notifier)
                                .resume(),
                          ),
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                ),
              IconButton(
                key: const ValueKey('floating-timer-finish-btn'),
                tooltip: l10n.prepTimerFinishButton,
                visualDensity: VisualDensity.compact,
                onPressed: timerState.isBusy
                    ? null
                    : () =>
                        unawaited(_openFinish(timerState, subject, material)),
                icon: Icon(
                  Icons.stop_circle_outlined,
                  size: spacing.lg,
                  color: colors.success,
                ),
              ),
              IconButton(
                key: const ValueKey('floating-timer-open-btn'),
                tooltip: l10n.prepTimerOpenFullButton,
                visualDensity: VisualDensity.compact,
                onPressed: () => GoRouter.maybeOf(context)?.go('/prep/timer'),
                icon: Icon(Icons.open_in_full_rounded, size: spacing.md),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
