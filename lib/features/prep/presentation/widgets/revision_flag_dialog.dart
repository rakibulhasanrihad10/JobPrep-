import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_composer.dart';

/// Opens a glass dialog to create one or more revision flags manually from a
/// subject/material, from the Revision screen, or from mock test weak topics.
Future<void> showRevisionFlagDialog(
  BuildContext context, {
  String? subjectId,
  String? materialId,
  String? topicId,
  int? initialPageNumber,
  MockTest? fromMockTest,
  RevisionSource source = RevisionSource.manual,
}) {
  return showGlassDialog<void>(
    context: context,
    builder: (_) => RevisionFlagDialog(
      initialSubjectId: fromMockTest?.subjectId ?? subjectId,
      initialMaterialId: fromMockTest?.materialId ?? materialId,
      topicId: fromMockTest?.topicId ?? topicId,
      initialPageNumber: initialPageNumber,
      fromMockTest: fromMockTest,
      source: fromMockTest != null ? RevisionSource.mockTest : source,
    ),
  );
}

/// Standalone dialog wrapping [RevisionFlagComposer] with optional subject and
/// material selectors plus mock test weak-topic quick-fill chips.
class RevisionFlagDialog extends ConsumerStatefulWidget {
  /// Creates a [RevisionFlagDialog].
  const RevisionFlagDialog({
    super.key,
    this.initialSubjectId,
    this.initialMaterialId,
    this.topicId,
    this.initialPageNumber,
    this.fromMockTest,
    this.source = RevisionSource.manual,
  });

  /// Preselected subject identifier, if opened from a scoped item.
  final String? initialSubjectId;

  /// Preselected study material identifier, if any.
  final String? initialMaterialId;

  /// Optional linked syllabus topic identifier.
  final String? topicId;

  /// Optional initial page number prefilled when flagging a book/material.
  final int? initialPageNumber;

  /// Optional source mock test whose weak topics populate quick-fill pills.
  final MockTest? fromMockTest;

  /// Origin recorded on created revision items.
  final RevisionSource source;

  @override
  ConsumerState<RevisionFlagDialog> createState() => _RevisionFlagDialogState();
}

class _RevisionFlagDialogState extends ConsumerState<RevisionFlagDialog> {
  String? _selectedSubjectId;
  String? _selectedMaterialId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId;
    _selectedMaterialId = widget.initialMaterialId;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final allMaterials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];

    final effectiveSubjectId =
        _selectedSubjectId ?? (subjects.isNotEmpty ? subjects.first.id : null);
    final subjectMaterials = allMaterials
        .where((m) => m.subjectId == effectiveSubjectId)
        .toList(growable: false);
    final effectiveMaterialId = subjectMaterials.any(
      (m) => m.id == _selectedMaterialId,
    )
        ? _selectedMaterialId
        : null;

    final weakTopics = widget.fromMockTest != null
        ? RevisionScheduler.extractWeakTopicLabels(
            widget.fromMockTest!.weakTopics,
          )
        : const <String>[];
    final initialRef = weakTopics.length == 1
        ? weakTopics.first
        : (widget.initialPageNumber != null && widget.initialPageNumber! > 0
            ? l10n.prepRevisionPageChip(widget.initialPageNumber.toString())
            : '');

    return GlassDialog(
      key: const ValueKey('revision-flag-dialog'),
      maxWidth: 560,
      title: Text(
        l10n.prepRevisionDialogTitle,
        style: tokens.textStyles.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.initialSubjectId == null && subjects.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                key: const ValueKey('revision-dialog-subject-dropdown'),
                initialValue: effectiveSubjectId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.prepRevisionSubjectLabel,
                  border: OutlineInputBorder(
                    borderRadius: tokens.radii.buttonRadius,
                  ),
                ),
                dropdownColor: colors.surfaceElevated,
                items: [
                  for (final subject in subjects)
                    DropdownMenuItem<String>(
                      value: subject.id,
                      child: Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (next) => setState(() {
                  _selectedSubjectId = next;
                  _selectedMaterialId = null;
                }),
              ),
              SizedBox(height: spacing.md),
            ],
            if (widget.initialMaterialId == null &&
                effectiveSubjectId != null) ...[
              DropdownButtonFormField<String?>(
                key: ValueKey('revision-dialog-material-$effectiveSubjectId'),
                initialValue: effectiveMaterialId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.prepRevisionMaterialOptionalLabel,
                  border: OutlineInputBorder(
                    borderRadius: tokens.radii.buttonRadius,
                  ),
                ),
                dropdownColor: colors.surfaceElevated,
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(
                      l10n.prepRevisionNoMaterialOption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final material in subjectMaterials)
                    DropdownMenuItem<String?>(
                      value: material.id,
                      child: Text(
                        material.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (next) => setState(() => _selectedMaterialId = next),
              ),
              SizedBox(height: spacing.md),
            ],
            if (effectiveSubjectId != null)
              RevisionFlagComposer(
                subjectId: effectiveSubjectId,
                materialId: effectiveMaterialId,
                topicId: widget.topicId,
                mockTestId: widget.fromMockTest?.id,
                source: widget.source,
                initialReference: initialRef,
                initialPageNumber: widget.initialPageNumber,
                initialReason: widget.fromMockTest != null
                    ? RevisionReason.mistake
                    : RevisionReason.tricky,
                showPageField:
                    widget.fromMockTest == null || effectiveMaterialId != null,
                quickFillSuggestions: weakTopics,
              ),
          ],
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('revision-dialog-close-button'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.prepCloseButton),
        ),
      ],
    );
  }
}
