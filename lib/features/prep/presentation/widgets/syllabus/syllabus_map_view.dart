import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_chapter_table.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_gaps_list.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_topic_grid.dart';

/// Syllabus Map view showing topic grid, chapter table, and gaps list.
class SyllabusMapView extends ConsumerWidget {
  /// Creates a [SyllabusMapView].
  const SyllabusMapView({
    required this.subject,
    required this.chapters,
    required this.topics,
    super.key,
  });

  /// The active subject.
  final Subject subject;

  /// Chapters belonging to [subject].
  final List<Chapter> chapters;

  /// Topics belonging to [subject].
  final List<Topic> topics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.tokens.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SyllabusTopicGrid(
          topics: topics,
          enabledCheckpoints: subject.enabledCheckpoints,
        ),
        SizedBox(height: spacing.lg),
        SyllabusChapterTable(
          chapters: chapters,
          topics: topics,
        ),
        SizedBox(height: spacing.lg),
        SyllabusGapsList(
          topics: topics,
          enabledCheckpoints: subject.enabledCheckpoints,
        ),
      ],
    );
  }
}
