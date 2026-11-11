import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_form_dialog.dart';

/// Displays the combined all-subjects study plan card followed by per-subject
/// exam plan cards inside PrepScreen when any plans exist.
class PrepStudyPlansSection extends StatelessWidget {
  /// Creates a [PrepStudyPlansSection].
  const PrepStudyPlansSection({
    required this.snapshots,
    required this.visitId,
    super.key,
  });

  /// Live ordered study plan snapshots (all-subjects first, then subjects).
  final List<StudyPlanSnapshot> snapshots;

  /// Tab visit token replaying progress ring animations cleanly.
  final int visitId;

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      key: const ValueKey('prep-study-plans-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_note_outlined,
              color: colors.goldAccent,
              size: spacing.lg,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                l10n.prepStudyPlanSectionTitle,
                style: tokens.textStyles.titleLarge,
              ),
            ),
            GlassButton(
              key: const ValueKey('prep-plans-add-button'),
              onPressed: () => unawaited(showStudyPlanFormDialog(context)),
              leading: Icon(Icons.add_rounded, size: spacing.lg),
              child: Text(l10n.prepStudyPlanAddButton),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        for (var i = 0; i < snapshots.length; i++) ...[
          if (i > 0) SizedBox(height: spacing.md),
          FadeSlideIn(
            index: i,
            child: StudyPlanCard(
              snapshot: snapshots[i],
              visitId: visitId,
            ),
          ),
        ],
      ],
    );
  }
}
