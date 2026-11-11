import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_material_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_logs_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_delete_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_header_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_form_dialog.dart';

/// Displays header, progress ring, and responsive cover cards grid (3-up on
/// desktop, 2-column on mobile) with quick & custom study progress logging.
class PrepSubjectDetailView extends ConsumerStatefulWidget {
  /// Creates a [PrepSubjectDetailView].
  const PrepSubjectDetailView({
    required this.subject,
    super.key,
    this.initialMaterialId,
    this.onBack,
    this.onSubjectDeleted,
    this.replayKey,
  });

  /// Subject currently inspected.
  final Subject subject;

  /// Optional study material identifier to open automatically once loaded.
  final String? initialMaterialId;

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
  String? _handledInitialMaterialId;

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
    final l10n = context.l10n;
    final subject = widget.subject;

    final subjectColor = PrepStyleTokens.resolveSubjectColor(
      subject.color,
      colors,
    );
    final materialsAsync = ref.watch(materialsForSubjectProvider(subject.id));
    final materials = materialsAsync.asData?.value ?? const <PrepMaterial>[];
    _maybeOpenInitialMaterial(
      materials: materials,
      subjectColor: subjectColor,
    );
    final subjectProgress = calculateSubjectProgress(materials);
    final logState = ref.watch(prepProgressLogControllerProvider);
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
        SizedBox(height: spacing.lg),
        materialsAsync.when(
          loading: () => Padding(
            padding: spacing.insetsAllXl,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => GlassCard(
            padding: spacing.insetsAllLg,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    PrepL10n.failureMessage(error, l10n),
                    style: tokens.textStyles.bodyMedium,
                  ),
                ),
                SizedBox(width: spacing.md),
                GlassButton(
                  onPressed: () => unawaited(
                    ref.refresh(materialsForSubjectProvider(subject.id).future),
                  ),
                  child: Text(l10n.calendarRetry),
                ),
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return GlassCard(
                padding: spacing.insetsAllXl,
                child: Column(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: spacing.xxl,
                      color: subjectColor,
                    ),
                    SizedBox(height: spacing.md),
                    Text(
                      l10n.prepEmptyMaterialsTitle(subject.name),
                      style: tokens.textStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.prepEmptyMaterialsBody,
                      style: tokens.textStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.lg),
                    GlassButton(
                      key: const ValueKey('empty-add-material-button'),
                      variant: GlassButtonVariant.primary,
                      onPressed: () =>
                          _handleAddMaterial(context, subjectColor),
                      child: Text(l10n.prepAddMaterialButton),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 560 ? 3 : 2;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < items.length; i += columns) ...[
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var col = 0; col < columns; col++) ...[
                              if (col > 0) SizedBox(width: spacing.md),
                              if (i + col < items.length)
                                Expanded(
                                  child: MaterialCard(
                                    material: items[i + col],
                                    subjectColor: subjectColor,
                                    replayKey: effectiveReplayKey,
                                    isLogging: logState.isSaving &&
                                        logState.activeMaterialId ==
                                            items[i + col].id,
                                    onEdit: () => _handleEditMaterial(
                                      context,
                                      items[i + col],
                                      subjectColor,
                                    ),
                                    onDelete: () => _handleDeleteMaterial(
                                      context,
                                      items[i + col],
                                    ),
                                    onQuickLog: (delta) => unawaited(
                                      ref
                                          .read(
                                            prepProgressLogControllerProvider
                                                .notifier,
                                          )
                                          .logUnits(
                                            material: items[i + col],
                                            units: delta,
                                          ),
                                    ),
                                    onOpenLogs: () => showMaterialLogsDialog(
                                      context,
                                      material: items[i + col],
                                      subjectColor: subjectColor,
                                    ),
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox.shrink()),
                            ],
                          ],
                        ),
                      ),
                      if (i + columns < items.length)
                        SizedBox(height: spacing.md),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
