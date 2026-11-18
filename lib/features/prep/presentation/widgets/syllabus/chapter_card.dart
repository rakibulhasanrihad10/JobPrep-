import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/chapter_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_checkpoint_row.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_form_dialog.dart';

/// Expandable card for a single syllabus chapter with topics and progress.
class ChapterCard extends ConsumerStatefulWidget {
  const ChapterCard({
    required this.chapter,
    required this.enabledCheckpoints,
    required this.visitId,
    super.key,
  });

  final Chapter chapter;
  final List<String> enabledCheckpoints;
  final int visitId;

  @override
  ConsumerState<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends ConsumerState<ChapterCard> {
  bool _isExpanded = true;

  Future<void> _confirmDelete(BuildContext context, int topicCount) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.syllabusDeleteChapter),
        content: Text(
          l10n.syllabusDeleteChapterConfirm(widget.chapter.title, topicCount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              MaterialLocalizations.of(ctx).deleteButtonTooltip,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(syllabusControllerProvider).deleteChapter(
            subjectId: widget.chapter.subjectId,
            chapterId: widget.chapter.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    final topics = ref.watch(
      topicsForChapterProvider(
        (
          subjectId: widget.chapter.subjectId,
          chapterId: widget.chapter.id,
        ),
      ),
    );

    final progress = ref.watch(
      chapterProgressProvider(
        (
          subjectId: widget.chapter.subjectId,
          chapterId: widget.chapter.id,
        ),
      ),
    );

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: tokens.radii.cardRadius,
            child: Padding(
              padding: spacing.insetsAllMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.expand_more_rounded
                            : Icons.chevron_right_rounded,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: spacing.xs),
                      Expanded(
                        child: Text(
                          widget.chapter.title,
                          style: textStyles.titleMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        l10n.syllabusTopicCount(topics.length),
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      PopupMenuButton<String>(
                        key: ValueKey('chapter-menu-${widget.chapter.id}'),
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        onSelected: (val) {
                          if (val == 'add_topic') {
                            unawaited(
                              TopicFormDialog.show(
                                context,
                                subjectId: widget.chapter.subjectId,
                                chapterId: widget.chapter.id,
                              ),
                            );
                          } else if (val == 'edit') {
                            unawaited(
                              ChapterFormDialog.show(
                                context,
                                subjectId: widget.chapter.subjectId,
                                existing: widget.chapter,
                              ),
                            );
                          } else if (val == 'delete') {
                            unawaited(_confirmDelete(context, topics.length));
                          } else if (val.startsWith('mark_all_')) {
                            final cpValue = val.replaceFirst('mark_all_', '');
                            final cp = SyllabusCheckpoint.tryParse(cpValue);
                            if (cp != null) {
                              unawaited(
                                ref
                                    .read(syllabusControllerProvider)
                                    .markAllCheckpointInChapter(
                                      subjectId: widget.chapter.subjectId,
                                      chapterId: widget.chapter.id,
                                      checkpoint: cp,
                                      isDone: true,
                                    ),
                              );
                            }
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'add_topic',
                            child: Text(l10n.syllabusAddTopic),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l10n.syllabusEditChapter),
                          ),
                          ...SyllabusCheckpoint.values.where((cp) {
                            return widget.enabledCheckpoints.contains(cp.value);
                          }).map((cp) {
                            final label = switch (cp) {
                              SyllabusCheckpoint.study =>
                                l10n.syllabusCheckpointStudy,
                              SyllabusCheckpoint.practice =>
                                l10n.syllabusCheckpointPractice,
                              SyllabusCheckpoint.modelTest =>
                                l10n.syllabusCheckpointModelTest,
                              SyllabusCheckpoint.revision =>
                                l10n.syllabusCheckpointRevision,
                            };
                            return PopupMenuItem(
                              value: 'mark_all_${cp.value}',
                              child: Text(l10n.syllabusMarkAllDone(label)),
                            );
                          }),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              l10n.syllabusDeleteChapter,
                              style: TextStyle(color: colors.danger),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.xs),
                  AnimatedProgressBar(
                    value: progress,
                    replayKey: 'chapter-progress-${widget.chapter.id}-'
                        '${widget.visitId}',
                    height: 4,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1, color: colors.glassBorder),
            if (topics.isEmpty)
              Padding(
                padding: spacing.insetsAllMd,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => unawaited(
                      TopicFormDialog.show(
                        context,
                        subjectId: widget.chapter.subjectId,
                        chapterId: widget.chapter.id,
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.syllabusAddTopic),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: spacing.xs),
                itemCount: topics.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: colors.glassBorder),
                itemBuilder: (ctx, idx) => TopicCheckpointRow(
                  topic: topics[idx],
                  enabledCheckpoints: widget.enabledCheckpoints,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
