import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_material_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/book_progress_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/books_shelf_view.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_logs_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_delete_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_header_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_materials_grid.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_plan_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_mock_tests_section.dart';

/// Displays header, progress ring, materials / Books shelf switcher,
/// responsive grids (`3` per row on desktop, `2` per row on mobile), study
/// plan card, and subject mock test analytics.
class PrepSubjectDetailView extends ConsumerStatefulWidget {
  /// Creates a [PrepSubjectDetailView].
  const PrepSubjectDetailView({
    required this.subject,
    super.key,
    this.initialMaterialId,
    this.initialViewMode = PrepSubjectViewMode.allMaterials,
    this.onBack,
    this.onSubjectDeleted,
    this.replayKey,
  });

  /// Subject currently inspected.
  final Subject subject;

  /// Optional study material identifier to open automatically once loaded.
  final String? initialMaterialId;

  /// Initial view tab shown for [subject] (`All materials` or `Books shelf`).
  final PrepSubjectViewMode initialViewMode;

  /// Optional back action shown on compact mobile routes.
  final VoidCallback? onBack;

  /// Invoked after deleting [subject] successfully.
  final VoidCallback? onSubjectDeleted;

  /// Key controlling animation replay on tab switch or subject selection.
  final Object? replayKey;

  @override
  ConsumerState<PrepSubjectDetailView> createState() =>
      _PrepSubjectDetailViewState();
}

class _PrepSubjectDetailViewState extends ConsumerState<PrepSubjectDetailView> {
  static int _nextBooksShelfVisitId = 0;

  String? _handledInitialMaterialId;
  late PrepSubjectViewMode _viewMode;
  late int _booksShelfVisitId;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialViewMode;
    _booksShelfVisitId = ++_nextBooksShelfVisitId;
  }

  @override
  void didUpdateWidget(PrepSubjectDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject.id != widget.subject.id ||
        oldWidget.initialViewMode != widget.initialViewMode) {
      _viewMode = widget.initialViewMode;
      if (_viewMode == PrepSubjectViewMode.booksShelf) {
        _booksShelfVisitId = ++_nextBooksShelfVisitId;
      }
    }
  }

  void _switchViewMode(PrepSubjectViewMode next) {
    if (_viewMode == next) return;
    setState(() {
      _viewMode = next;
      if (next == PrepSubjectViewMode.booksShelf) {
        _booksShelfVisitId = ++_nextBooksShelfVisitId;
      }
    });
  }

  void _maybeOpenInitialMaterial({
    required List<PrepMaterial> materials,
    required Color subjectColor,
  }) {
    final targetId = widget.initialMaterialId?.trim();
    if (targetId == null ||
        targetId.isEmpty ||
        _handledInitialMaterialId == targetId) {
      return;
    }
    final match = materials.where((m) => m.id == targetId).firstOrNull;
    if (match == null) return;

    _handledInitialMaterialId = targetId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        showMaterialLogsDialog(
          context,
          material: match,
          subjectColor: subjectColor,
        ),
      );
    });
  }

  Future<void> _handleAddMaterial(
    BuildContext context,
    Color subjectColor,
  ) async {
    await showMaterialFormDialog(
      context,
      subjectId: widget.subject.id,
      subjectColor: subjectColor,
    );
  }

  Future<void> _handleEditMaterial(
    BuildContext context,
    PrepMaterial material,
    Color subjectColor,
  ) async {
    await showMaterialFormDialog(
      context,
      subjectId: widget.subject.id,
      subjectColor: subjectColor,
      existing: material,
    );
  }

  Future<void> _handleDeleteMaterial(
    BuildContext context,
    PrepMaterial material,
  ) async {
    final confirmed = await showDeleteMaterialDialog(
      context,
      material: material,
    );
    if (!confirmed || !mounted) return;
    await ref
        .read(prepMaterialControllerProvider.notifier)
        .deleteMaterial(material);
  }

  Future<void> _handleDeleteSubject(
    BuildContext context,
    List<PrepMaterial> materials,
  ) async {
    final confirmed = await showDeleteSubjectDialog(
      context,
      subject: widget.subject,
      subjectMaterials: materials,
    );
    if (!confirmed || !mounted) return;
    final deleted = await ref
        .read(prepSubjectsControllerProvider.notifier)
        .deleteSubject(widget.subject);
    if (deleted) {
      widget.onSubjectDeleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final subject = widget.subject;

    final subjectColor = PrepStyleTokens.resolveSubjectColor(
      subject.color,
      colors,
    );
    final materialsAsync = ref.watch(materialsForSubjectProvider(subject.id));
    final materials = materialsAsync.asData?.value ?? const <PrepMaterial>[];
    final books = materials
        .where((item) => item.kind == MaterialKind.book)
        .toList(growable: false);

    _maybeOpenInitialMaterial(
      materials: materials,
      subjectColor: subjectColor,
    );

    final subjectProgress = calculateSubjectProgress(materials);
    final logState = ref.watch(prepProgressLogControllerProvider);
    final subjectPlan = ref.watch(studyPlanForSubjectProvider(subject.id));
    final effectiveReplayKey = widget.replayKey ?? 'detail-${subject.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrepSubjectDetailHeaderCard(
          subject: subject,
          subjectColor: subjectColor,
          subjectProgress: subjectProgress,
          materialCount: materials.length,
          onBack: widget.onBack,
          replayKey: effectiveReplayKey,
          onAddMaterial: () => _handleAddMaterial(context, subjectColor),
          onEditSubject: () =>
              showSubjectFormDialog(context, existing: subject),
          onDeleteSubject: () => _handleDeleteSubject(context, materials),
        ),
        if (subjectPlan != null) ...[
          SizedBox(height: spacing.lg),
          StudyPlanCard(
            snapshot: subjectPlan,
            visitId: effectiveReplayKey.hashCode,
          ),
        ],
        SizedBox(height: spacing.lg),
        SubjectViewModeBar(
          activeMode: _viewMode,
          bookCount: books.length,
          onChanged: _switchViewMode,
        ),
        SizedBox(height: spacing.lg),
        if (_viewMode == PrepSubjectViewMode.booksShelf)
          BooksShelfView(
            subjectName: subject.name,
            subjectColor: subjectColor,
            books: books,
            replayKey: 'books-shelf-${subject.id}-$_booksShelfVisitId',
            onAddBook: () => unawaited(
              _handleAddMaterial(context, subjectColor),
            ),
            onOpenBook: (book) => unawaited(
              showBookProgressDialog(
                context,
                material: book,
                subjectColor: subjectColor,
              ),
            ),
          )
        else
          PrepSubjectMaterialsGrid(
            subjectName: subject.name,
            subjectColor: subjectColor,
            materialsAsync: materialsAsync,
            logState: logState,
            replayKey: effectiveReplayKey,
            onRetry: () => unawaited(
              ref.refresh(materialsForSubjectProvider(subject.id).future),
            ),
            onAddMaterial: () => unawaited(
              _handleAddMaterial(context, subjectColor),
            ),
            onEditMaterial: (item) => unawaited(
              _handleEditMaterial(context, item, subjectColor),
            ),
            onDeleteMaterial: (item) => unawaited(
              _handleDeleteMaterial(context, item),
            ),
            onQuickLog: (item, delta) => unawaited(
              ref
                  .read(prepProgressLogControllerProvider.notifier)
                  .logUnits(material: item, units: delta),
            ),
            onOpenLogs: (item) => unawaited(
              showMaterialLogsDialog(
                context,
                material: item,
                subjectColor: subjectColor,
              ),
            ),
            onOpenBookView: (book) => unawaited(
              showBookProgressDialog(
                context,
                material: book,
                subjectColor: subjectColor,
              ),
            ),
            onFlagRevision: (item) => unawaited(
              showRevisionFlagDialog(
                context,
                subjectId: item.subjectId,
                materialId: item.id,
                initialPageNumber:
                    item.kind == MaterialKind.book && item.completedUnits > 0
                        ? item.completedUnits
                        : null,
              ),
            ),
          ),
        SizedBox(height: spacing.xl),
        SubjectMockTestsSection(
          subject: subject,
          subjectColor: subjectColor,
          replayKey: effectiveReplayKey,
        ),
      ],
    );
  }
}
