import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_template_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_card.dart';

/// Displays loading, error, empty-state templates, or reorderable glass
/// cards for study subjects.
class PrepSubjectsSection extends StatelessWidget {
  /// Creates a [PrepSubjectsSection].
  const PrepSubjectsSection({
    required this.subjectsAsync,
    required this.templatesAsync,
    required this.orderedSubjects,
    required this.materialsBySubject,
    required this.selectedSubjectId,
    required this.isExpandedViewport,
    required this.tabVisitId,
    required this.isApplyingTemplate,
    required this.activeTemplateKey,
    required this.appliedTemplateKeys,
    required this.onRefresh,
    required this.onRetryTemplates,
    required this.onApplyTemplate,
    required this.onCustomizeTemplate,
    required this.onDeleteTemplate,
    required this.onSelectSubject,
    required this.onEditSubject,
    required this.onDeleteSubject,
    required this.onReorderItem,
    required this.onMoveSubjectByOffset,
    super.key,
  });

  /// Async loading state for subjects.
  final AsyncValue<List<Subject>> subjectsAsync;

  /// Async loading state for starter and personal templates.
  final AsyncValue<List<PrepTemplate>> templatesAsync;

  /// Pre-sorted subjects rendered when data is available.
  final List<Subject> orderedSubjects;

  /// Materials grouped by owning `subjectId`.
  final Map<String, List<PrepMaterial>> materialsBySubject;

  /// Active subject identifier highlighted on desktop split views.
  final String? selectedSubjectId;

  /// Whether the viewport renders the desktop master-detail split.
  final bool isExpandedViewport;

  /// Monotonic visit counter replaying progress rings when switching tabs.
  final int tabVisitId;

  /// Disables template buttons while a template batch write runs.
  final bool isApplyingTemplate;

  /// Active template key currently mutating, if any.
  final String? activeTemplateKey;

  /// Template keys already completely represented in the user's subjects.
  final Set<String> appliedTemplateKeys;

  /// Reloads subjects on error.
  final VoidCallback onRefresh;

  /// Reloads templates when template fetch fails.
  final VoidCallback onRetryTemplates;

  /// Applies a chosen starter or personal template directly.
  final ValueChanged<PrepTemplate> onApplyTemplate;

  /// Opens customization dialog before copying a template.
  final ValueChanged<PrepTemplate> onCustomizeTemplate;

  /// Deletes a user-saved personal template.
  final ValueChanged<PrepTemplate> onDeleteTemplate;

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
            key: const ValueKey('prep-empty-state-card'),
            padding: spacing.insetsAllXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                SizedBox(height: spacing.xl),
                Text(
                  l10n.prepTemplatesTitle,
                  style: tokens.textStyles.titleMedium,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  l10n.prepTemplatesSubtitle,
                  style: tokens.textStyles.bodySmall,
                ),
                SizedBox(height: spacing.md),
                templatesAsync.when(
                  loading: () => Padding(
                    padding: spacing.insetsAllLg,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Row(
                    children: [
                      Expanded(
                        child: Text(
                          PrepL10n.failureMessage(error, l10n),
                          style: tokens.textStyles.bodyMedium,
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      GlassButton(
                        onPressed: onRetryTemplates,
                        child: Text(l10n.calendarRetry),
                      ),
                    ],
                  ),
                  data: (templates) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final template in templates)
                        PrepTemplateCard(
                          template: template,
                          isAlreadyApplied:
                              appliedTemplateKeys.contains(template.stableKey),
                          isBusy: isApplyingTemplate,
                          isActive: activeTemplateKey == template.stableKey,
                          onApply: () => onApplyTemplate(template),
                          onCustomize: () => onCustomizeTemplate(template),
                          onDelete: template.isSystem
                              ? null
                              : () => onDeleteTemplate(template),
                        ),
                    ],
                  ),
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
              replayKey: 'prep-sub-${subject.id}-visit-$tabVisitId',
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
