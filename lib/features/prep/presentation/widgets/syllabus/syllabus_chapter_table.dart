import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Table displaying completion percentages per chapter across checkpoints.
class SyllabusChapterTable extends ConsumerWidget {
  /// Creates a [SyllabusChapterTable].
  const SyllabusChapterTable({
    required this.chapters,
    required this.topics,
    super.key,
  });

  /// Chapters belonging to the selected subject.
  final List<Chapter> chapters;

  /// Topics belonging to the selected subject.
  final List<Topic> topics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    if (chapters.isEmpty) {
      return const SizedBox.shrink();
    }

    String formatPct(int count, int total) {
      if (total <= 0) return '0%';
      final pct = ((count / total) * 100).round();
      final numStr = AppFormatters.formatNumber(
        pct,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      );
      return '$numStr%';
    }

    return GlassCard(
      key: const ValueKey('syllabus-chapter-table-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart_rounded,
                size: 20,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.xs),
              Text(
                l10n.syllabusChapterTableTitle,
                style: tokens.textStyles.titleMedium,
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: spacing.md,
              headingRowHeight: 40,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 52,
              columns: [
                DataColumn(
                  label: Text(
                    l10n.syllabusColChapter,
                    style: tokens.textStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.syllabusColStudied,
                    style: tokens.textStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.syllabusColPracticed,
                    style: tokens.textStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.syllabusColTested,
                    style: tokens.textStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.syllabusColRevised,
                    style: tokens.textStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: chapters.map((chapter) {
                final chTopics =
                    topics.where((t) => t.chapterId == chapter.id).toList();
                final total = chTopics.length;
                final studied =
                    chTopics.where((t) => t.studyDoneAt != null).length;
                final practiced =
                    chTopics.where((t) => t.practiceDoneAt != null).length;
                final tested =
                    chTopics.where((t) => t.modelTestDoneAt != null).length;
                final revised =
                    chTopics.where((t) => t.revisionDoneAt != null).length;

                return DataRow(
                  key: ValueKey('chapter-table-row-${chapter.id}'),
                  cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          chapter.title,
                          overflow: TextOverflow.ellipsis,
                          style: tokens.textStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(formatPct(studied, total))),
                    DataCell(Text(formatPct(practiced, total))),
                    DataCell(Text(formatPct(tested, total))),
                    DataCell(Text(formatPct(revised, total))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
