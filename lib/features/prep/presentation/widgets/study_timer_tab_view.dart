import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_sessions_history_list.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer.dart';

/// Prep section tab hosting the [StudyTimer] workspace and session history.
class StudyTimerTabView extends StatelessWidget {
  /// Creates a [StudyTimerTabView].
  const StudyTimerTabView({
    required this.visitId,
    super.key,
  });

  /// Monotonically incremented tab visit counter replaying entrance/ring.
  final int visitId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return FadeSlideIn(
      key: ValueKey('timer-tab-fade-$visitId'),
      child: Column(
        key: const ValueKey('study-timer-tab-view'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: spacing.insetsAllXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.prepTimerTitle,
                  style: tokens.textStyles.headlineMedium,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  l10n.prepTimerSubtitle,
                  style: tokens.textStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),
          StudyTimer(replayKey: 'timer-visit-$visitId'),
          SizedBox(height: spacing.lg),
          const StudySessionsHistoryList(),
        ],
      ),
    );
  }
}
