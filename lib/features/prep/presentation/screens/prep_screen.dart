import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_subject_detail_screen.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_template_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_delete_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_overview_header_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_view.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subjects_section.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_templates_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_form_dialog.dart';

/// Main animated preparation dashboard and Subject & Material Manager screen.
class PrepScreen extends ConsumerStatefulWidget {
  /// Creates a [PrepScreen].
  const PrepScreen({
    super.key,
    this.selectedSubjectId,
    this.initialMaterialId,
  });

  /// Optional pre-selected subject displayed in desktop master-detail mode.
  final String? selectedSubjectId;

  /// Optional material identifier to open immediately when focused.
  final String? initialMaterialId;

  @override
  ConsumerState<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends ConsumerState<PrepScreen> {
  static int _nextTabVisitId = 0;

  late final int _tabVisitId;
  String? _localSelectedId;

  @override
  void initState() {
    super.initState();
    _tabVisitId = ++_nextTabVisitId;
    _localSelectedId = widget.selectedSubjectId;
  }

  @override
  void didUpdateWidget(PrepScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSubjectId != oldWidget.selectedSubjectId) {
      _localSelectedId = widget.selectedSubjectId;
    }
  }

  void _refreshAll() {
    unawaited(ref.read(subjectsProvider.notifier).refresh());
    unawaited(ref.read(allMaterialsProvider.notifier).refresh());
    unawaited(ref.read(prepTemplatesProvider.notifier).refresh());
  }

  Future<void> _openCreateSubject({required bool selectCreated}) async {
    final created = await showSubjectFormDialog(context);
    if (!mounted || created == null) return;
    if (selectCreated) {
      setState(() => _localSelectedId = created.id);
    }
  }

  void _selectSubject(Subject subject, {required bool isExpanded}) {
    if (isExpanded) {
      setState(() => _localSelectedId = subject.id);
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go('/prep/${subject.id}');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: PrepSubjectDetailScreen(subjectId: subject.id),
        ),
      ),
    );
  }

  Future<void> _handleDeleteSubject(
    Subject subject,
    List<PrepMaterial> subjectMaterials,
  ) async {
    final confirmed = await showDeleteSubjectDialog(
      context,
      subject: subject,
      subjectMaterials: subjectMaterials,
    );
    if (!confirmed || !mounted) return;
    final ok = await ref
        .read(prepSubjectsControllerProvider.notifier)
        .deleteSubject(subject);
    if (ok && mounted && _localSelectedId == subject.id) {
      setState(() => _localSelectedId = null);
    }
  }

  Future<void> _handleReorderItem(
    List<Subject> subjects,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex == oldIndex || newIndex < 0 || newIndex >= subjects.length) {
      return;
    }
    final updated = List<Subject>.of(subjects);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    await ref
        .read(prepSubjectsControllerProvider.notifier)
        .reorderSubjects(updated);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final breakpoints = tokens.breakpoints;

    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isExpanded = breakpoints.isExpanded(viewportWidth);
    final horizontalPad =
        breakpoints.isCompact(viewportWidth) ? spacing.lg : spacing.xl;

    final subjectsAsync = ref.watch(subjectsProvider);
    final templatesAsync = ref.watch(prepTemplatesProvider);
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final overallProgress =
        ref.watch(overallPrepProgressProvider).asData?.value ?? 0.0;
    final templateActionState = ref.watch(prepTemplateActionControllerProvider);

    final subjects = List<Subject>.of(
      subjectsAsync.asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final appliedTemplateKeys = <String>{
      for (final template
          in templatesAsync.asData?.value ?? const <PrepTemplate>[])
        if (PrepTemplatePlanner.isAlreadyApplied(
          template: template,
          existingSubjects: subjects,
          existingMaterials: materials,
        ))
          template.stableKey,
    };

    final materialsBySubject = <String, List<PrepMaterial>>{};
    var completedUnitsTotal = 0;
    var plannedUnitsTotal = 0;
    for (final mat in materials) {
      materialsBySubject.putIfAbsent(mat.subjectId, () => []).add(mat);
      if (mat.totalUnits > 0) {
        plannedUnitsTotal += mat.totalUnits;
        completedUnitsTotal += mat.completedUnits.clamp(0, mat.totalUnits);
      }
    }

    final activeId = _localSelectedId ?? widget.selectedSubjectId;
    final selectedSubject = subjects.isEmpty
        ? null
        : subjects.where((s) => s.id == activeId).firstOrNull ?? subjects.first;

    final headerCard = PrepOverviewHeaderCard(
      overallProgress: overallProgress,
      subjectCount: subjects.length,
      materialCount: materials.length,
      completedUnitsTotal: completedUnitsTotal,
      plannedUnitsTotal: plannedUnitsTotal,
      replayKey: 'prep-overall-visit-$_tabVisitId',
      onAddSubject: () => _openCreateSubject(selectCreated: isExpanded),
      onRefresh: _refreshAll,
      onOpenTemplates: () => unawaited(showPrepTemplatesDialog(context)),
      onSaveAsTemplate: subjects.isEmpty
          ? null
          : () => unawaited(
                PrepTemplateUiHelpers.savePersonalAndNotify(
                  context,
                  subjects: subjects,
                  materials: materials,
                ),
              ),
    );

    final subjectsSection = PrepSubjectsSection(
      subjectsAsync: subjectsAsync,
      templatesAsync: templatesAsync,
      orderedSubjects: subjects,
      materialsBySubject: materialsBySubject,
      selectedSubjectId: selectedSubject?.id,
      isExpandedViewport: isExpanded,
      tabVisitId: _tabVisitId,
      isApplyingTemplate: templateActionState.isBusy,
      activeTemplateKey: templateActionState.activeTemplateId,
      appliedTemplateKeys: appliedTemplateKeys,
      onRefresh: _refreshAll,
      onRetryTemplates: () =>
          unawaited(ref.read(prepTemplatesProvider.notifier).refresh()),
      onApplyTemplate: (template) => unawaited(
        PrepTemplateUiHelpers.applyAndNotify(context, ref, template),
      ),
      onCustomizeTemplate: (template) => unawaited(
        PrepTemplateUiHelpers.customizeAndNotify(context, template),
      ),
      onDeleteTemplate: (template) => unawaited(
        PrepTemplateUiHelpers.confirmAndDeleteTemplate(context, ref, template),
      ),
      onSelectSubject: (subject) =>
          _selectSubject(subject, isExpanded: isExpanded),
      onEditSubject: (subject) =>
          showSubjectFormDialog(context, existing: subject),
      onDeleteSubject: _handleDeleteSubject,
      onReorderItem: (oldIndex, newIndex) =>
          _handleReorderItem(subjects, oldIndex, newIndex),
      onMoveSubjectByOffset: (index, offset) =>
          ref.read(prepSubjectsControllerProvider.notifier).moveSubjectByOffset(
                subjects: subjects,
                index: index,
                offset: offset,
              ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        spacing.xl,
        horizontalPad,
        spacing.xl + spacing.xxxl,
      ),
      child: FadeSlideIn(
        child: isExpanded && subjects.isNotEmpty && selectedSubject != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        headerCard,
                        SizedBox(height: spacing.lg),
                        subjectsSection,
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.xl),
                  Expanded(
                    flex: 8,
                    child: PrepSubjectDetailView(
                      subject: selectedSubject,
                      initialMaterialId:
                          selectedSubject.id == widget.selectedSubjectId
                              ? widget.initialMaterialId
                              : null,
                      replayKey:
                          'detail-visit-$_tabVisitId-${selectedSubject.id}',
                      onSubjectDeleted: () =>
                          setState(() => _localSelectedId = null),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  headerCard,
                  SizedBox(height: spacing.lg),
                  subjectsSection,
                ],
              ),
      ),
    );
  }
}
