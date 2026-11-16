import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_detail_sheet.dart';

/// Single topic row displaying title, notes indicator, and enabled checkpoint
/// checkboxes.
class TopicCheckpointRow extends ConsumerWidget {
  const TopicCheckpointRow({
    required this.topic,
    required this.enabledCheckpoints,
    super.key,
  });

  final Topic topic;
  final List<String> enabledCheckpoints;

  void _openDetail(BuildContext context) {
    unawaited(
      TopicDetailSheet.show(
        context,
        topic: topic,
        enabledCheckpoints: enabledCheckpoints,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return InkWell(
      onLongPress: () => _openDetail(context),
      borderRadius: tokens.radii.smRadius,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      topic.title,
                      style: textStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (topic.weight > 1) ...[
                    SizedBox(width: spacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs,
                        vertical: spacing.xxs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.goldAccent.withValues(alpha: 0.15),
                        borderRadius: tokens.radii.smRadius,
                      ),
                      child: Text(
                        '${topic.weight}x',
                        style: textStyles.labelSmall.copyWith(
                          color: colors.goldAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (topic.notes?.trim().isNotEmpty ?? false) ...[
                    SizedBox(width: spacing.xs),
                    Icon(
                      Icons.note_rounded,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            ...SyllabusCheckpoint.values.where((cp) {
              return enabledCheckpoints.contains(cp.value);
            }).map((cp) {
              final isDone = switch (cp) {
                SyllabusCheckpoint.study => topic.studyDoneAt != null,
                SyllabusCheckpoint.practice => topic.practiceDoneAt != null,
                SyllabusCheckpoint.modelTest => topic.modelTestDoneAt != null,
                SyllabusCheckpoint.revision => topic.revisionDoneAt != null,
              };

              final tooltip = switch (cp) {
                SyllabusCheckpoint.study => l10n.syllabusCheckpointStudy,
                SyllabusCheckpoint.practice => l10n.syllabusCheckpointPractice,
                SyllabusCheckpoint.modelTest =>
                  l10n.syllabusCheckpointModelTest,
                SyllabusCheckpoint.revision => l10n.syllabusCheckpointRevision,
              };

              return Tooltip(
                message: tooltip,
                child: Checkbox(
                  key: ValueKey('topic-${topic.id}-${cp.value}'),
                  value: isDone,
                  activeColor: colors.goldAccent,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    unawaited(
                      ref.read(syllabusControllerProvider).toggleCheckpoint(
                            topic: topic,
                            checkpoint: cp,
                            isDone: val == true,
                          ),
                    );
                  },
                ),
              );
            }),
            IconButton(
              key: ValueKey('topic-menu-${topic.id}'),
              icon: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
              onPressed: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}
