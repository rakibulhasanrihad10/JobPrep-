import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/chapter_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/quick_add_outline_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/subject_checkpoints_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_map_view.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_progress_ring_summary.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_tree_view.dart';

/// Main Syllabus tab view hosted inside `PrepScreen`.
class SyllabusTabView extends ConsumerWidget {
  const SyllabusTabView({
    required this.visitId,
    super.key,
  });

  final int visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      loading: () => Center(
        child: Padding(
          padding: spacing.insetsAllXl,
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(
        child: Text(
          err.toString(),
          style: textStyles.bodyMedium.copyWith(color: colors.danger),
        ),
      ),
      data: (subjects) {
        if (subjects.isEmpty) {
          return GlassCard(
            padding: spacing.insetsAllXl,
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 28,
                  color: colors.textSecondary,
                ),
                SizedBox(height: spacing.md),
                Text(
                  l10n.syllabusNoSubjects,
                  style: textStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  l10n.syllabusNoSubjectsDesc,
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final selectedSubjectId =
            ref.watch(selectedSyllabusSubjectIdProvider) ?? subjects.first.id;
        final currentSubject = subjects.firstWhere(
          (s) => s.id == selectedSubjectId,
          orElse: () => subjects.first,
        );

        final chaptersAsync =
            ref.watch(chaptersForSubjectProvider(currentSubject.id));
        final unassignedTopics =
            ref.watch(unassignedTopicsForSubjectProvider(currentSubject.id));
        final syllabusProgress =
            ref.watch(subjectSyllabusProgressProvider(currentSubject.id));
        final readingProgressAsync =
            ref.watch(subjectProgressProvider(currentSubject.id));
        final readingProgress = readingProgressAsync.asData?.value ?? 0.0;
        final viewMode = ref.watch(syllabusViewModeProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject picker
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: subjects.map((sub) {
                  final isSelected = sub.id == currentSubject.id;
                  return Padding(
                    padding: EdgeInsets.only(right: spacing.xs),
                    child: ChoiceChip(
                      key: ValueKey('syllabus-subject-${sub.id}'),
                      label: Text(sub.name),
                      selected: isSelected,
                      selectedColor: colors.goldAccent.withValues(alpha: 0.25),
                      backgroundColor: colors.surfaceElevated,
                      labelStyle: textStyles.labelMedium.copyWith(
                        color: isSelected
                            ? colors.goldAccent
                            : colors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        ref
                            .read(selectedSyllabusSubjectIdProvider.notifier)
                            .currentId = sub.id;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: spacing.md),

            // Summary card: Syllabus Ring + Reading Ring (never merged)
            GlassCard(
              padding: spacing.insetsAllLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SyllabusProgressRingSummary(
                        key: const ValueKey('syllabus-progress-ring'),
                        label: l10n.syllabusOverallProgress,
                        value: syllabusProgress,
                        replayKey:
                            'syllabus-ring-${currentSubject.id}-$visitId',
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: colors.glassBorder,
                      ),
                      SyllabusProgressRingSummary(
                        key: const ValueKey('reading-progress-ring'),
                        label: l10n.syllabusReadingProgress,
                        value: readingProgress,
                        replayKey: 'reading-ring-${currentSubject.id}-$visitId',
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  Divider(height: 1, color: colors.glassBorder),
                  SizedBox(height: spacing.sm),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    alignment: WrapAlignment.end,
                    children: [
                      GlassButton(
                        key: const ValueKey(
                          'syllabus-configure-checkpoints-btn',
                        ),
                        onPressed: () => SubjectCheckpointsDialog.show(
                          context,
                          subject: currentSubject,
                        ),
                        leading: const Icon(Icons.tune_rounded, size: 18),
                        child: Text(l10n.syllabusConfigureCheckpoints),
                      ),
                      GlassButton(
                        key: const ValueKey('syllabus-quick-add-outline-btn'),
                        onPressed: () => QuickAddOutlineDialog.show(
                          context,
                          subjectId: currentSubject.id,
                        ),
                        leading:
                            const Icon(Icons.playlist_add_rounded, size: 18),
                        child: Text(l10n.syllabusQuickAdd),
                      ),
                      GlassButton(
                        key: const ValueKey('syllabus-add-chapter-top-btn'),
                        onPressed: () => ChapterFormDialog.show(
                          context,
                          subjectId: currentSubject.id,
                        ),
                        leading: const Icon(Icons.add_rounded, size: 18),
                        variant: GlassButtonVariant.primary,
                        child: Text(l10n.syllabusAddChapter),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.md),

            // View toggle (Tree vs Map)
            Row(
              children: [
                ChoiceChip(
                  key: const ValueKey('syllabus-view-tree-chip'),
                  label: Text(l10n.syllabusViewTree),
                  selected: viewMode == SyllabusViewMode.tree,
                  selectedColor: colors.goldAccent.withValues(alpha: 0.25),
                  backgroundColor: colors.surfaceElevated,
                  labelStyle: textStyles.labelMedium.copyWith(
                    color: viewMode == SyllabusViewMode.tree
                        ? colors.goldAccent
                        : colors.textSecondary,
                    fontWeight: viewMode == SyllabusViewMode.tree
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    ref
                        .read(syllabusViewModeProvider.notifier)
                        .setMode(SyllabusViewMode.tree);
                  },
                ),
                SizedBox(width: spacing.xs),
                ChoiceChip(
                  key: const ValueKey('syllabus-view-map-chip'),
                  label: Text(l10n.syllabusViewMap),
                  selected: viewMode == SyllabusViewMode.map,
                  selectedColor: colors.goldAccent.withValues(alpha: 0.25),
                  backgroundColor: colors.surfaceElevated,
                  labelStyle: textStyles.labelMedium.copyWith(
                    color: viewMode == SyllabusViewMode.map
                        ? colors.goldAccent
                        : colors.textSecondary,
                    fontWeight: viewMode == SyllabusViewMode.map
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    ref
                        .read(syllabusViewModeProvider.notifier)
                        .setMode(SyllabusViewMode.map);
                  },
                ),
              ],
            ),
            SizedBox(height: spacing.md),

            // Content: Tree or Map
            chaptersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (chapters) {
                final allTopics = ref
                        .watch(topicsForSubjectProvider(currentSubject.id))
                        .asData
                        ?.value ??
                    const [];

                if (viewMode == SyllabusViewMode.map) {
                  return SyllabusMapView(
                    subject: currentSubject,
                    chapters: chapters,
                    topics: allTopics,
                  );
                }

                return SyllabusTreeView(
                  subject: currentSubject,
                  chapters: chapters,
                  unassignedTopics: unassignedTopics,
                  visitId: visitId,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
