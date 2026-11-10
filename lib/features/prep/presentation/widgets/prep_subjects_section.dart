import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_card.dart';

/// Displays the loading, error, empty, or reorderable list of study subjects.
class PrepSubjectsSection extends StatelessWidget {
  /// Creates a [PrepSubjectsSection].
  const PrepSubjectsSection({
    required this.subjectsAsync,
    required this.orderedSubjects,
    required this.materialsBySubject,
    required this.selectedSubjectId,
    required this.isExpandedViewport,
    required this.onRefresh,
    required this.onSelectSubject,
    required this.onEditSubject,
    required this.onDeleteSubject,
    required this.onReorderItem,
    required this.onMoveSubjectByOffset,
    super.key,
  });

  /// Async loading state for subjects.
  final AsyncValue<List<Subject>> subjectsAsync;

  /// Pre-sorted subjects rendered when data is available.
  final List<Subject> orderedSubjects;

  /// Materials grouped by owning `subjectId`.
  final Map<String, List<PrepMaterial>> materialsBySubject;

  /// Active subject identifier highlighted on desktop split views.
  final String? selectedSubjectId;

  /// Whether the viewport renders the desktop master-detail split.
  final bool isExpandedViewport;

  /// Reloads subjects on error.
  final VoidCallback onRefresh;

  /// Selects or navigates to a subject's materials view.
  final ValueChanged<Subject> onSelectSubject;

  /// Opens subject edit dialog.
  final ValueChanged<Subject> onEditSubject;

  /// Prompts delete confirmation for a subject and its materials.
  final void Function(Subject subject, List<PrepMaterial> materials)
      onDeleteSubject;

  /// Handles drag-and-drop reorder completion.
  final void Function(int oldIndex, int newIndex) onReorderItem;

  /// Handles accessible button reordering by offset (`-1` or `1`).
  final void Function(int index, int offset) onMoveSubjectByOffset;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return subjectsAsync.when(
      loading: () => Padding(
        padding: spacing.insetsAllXl,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => GlassCard(
        padding: spacing.insetsAllXl,
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.prepLoadError,
                style: tokens.textStyles.bodyMedium,
              ),
            ),
            SizedBox(width: spacing.md),
            GlassButton(
              onPressed: onRefresh,
              child: Text(l10n.calendarRetry),
            ),
          ],
        ),
      ),
      data: (_) {
        if (orderedSubjects.isEmpty) {
          return GlassCard(
            padding: spacing.insetsAllXl,
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: spacing.xxxl,
                  color: colors.goldAccent,
                ),
                SizedBox(height: spacing.md),
                Text(
                  l10n.prepEmptySubjectsTitle,
                  style: tokens.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.prepEmptySubjectsBody,
                  style: tokens.textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: orderedSubjects.length,
          onReorderItem: onReorderItem,
          itemBuilder: (context, index) {
            final subject = orderedSubjects[index];
            final subjectMaterials =
                materialsBySubject[subject.id] ?? const <PrepMaterial>[];
            return SubjectCard(
              key: ValueKey('reorder-subject-${subject.id}'),
              subject: subject,
              index: index,
              totalCount: orderedSubjects.length,
              materials: subjectMaterials,
              isSelected: isExpandedViewport && selectedSubjectId == subject.id,
              replayKey: 'prep-subject-bar-${subject.id}',
              onTap: () => onSelectSubject(subject),
              onEdit: () => onEditSubject(subject),
              onDelete: () => onDeleteSubject(subject, subjectMaterials),
              onMoveUp:
                  index > 0 ? () => onMoveSubjectByOffset(index, -1) : null,
              onMoveDown: index < orderedSubjects.length - 1
                  ? () => onMoveSubjectByOffset(index, 1)
                  : null,
            );
          },
        );
      },
    );
  }
}
