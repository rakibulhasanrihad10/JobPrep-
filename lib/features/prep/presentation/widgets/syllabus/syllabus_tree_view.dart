import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/chapter_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_empty_state.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_checkpoint_row.dart';

/// Tree hierarchy view displaying expandable chapters and topic rows.
class SyllabusTreeView extends StatelessWidget {
  /// Creates a [SyllabusTreeView].
  const SyllabusTreeView({
    required this.subject,
    required this.chapters,
    required this.unassignedTopics,
    required this.visitId,
    super.key,
  });

  /// The active subject.
  final Subject subject;

  /// Chapters belonging to [subject].
  final List<Chapter> chapters;

  /// Topics not assigned to any chapter.
  final List<Topic> unassignedTopics;

  /// Animation visit identifier.
  final int visitId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final textStyles = tokens.textStyles;

    if (chapters.isEmpty && unassignedTopics.isEmpty) {
      return SyllabusEmptyState(subject: subject);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...chapters.map((chapter) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing.md),
            child: ChapterCard(
              key: ValueKey('chapter-card-${chapter.id}'),
              chapter: chapter,
              enabledCheckpoints: subject.enabledCheckpoints,
              visitId: visitId,
            ),
          );
        }),
        if (unassignedTopics.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: Text(
              'Unassigned Topics',
              style: textStyles.bodyLarge.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GlassCard(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: unassignedTopics.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.glassBorder,
              ),
              itemBuilder: (ctx, idx) => TopicCheckpointRow(
                topic: unassignedTopics[idx],
                enabledCheckpoints: subject.enabledCheckpoints,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
