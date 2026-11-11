import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/book_progress_3d_parts.dart';
import 'package:job_prep/core/widgets/book_progress_view.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_logs_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_composer.dart';

/// Opens the interactive 3D book progress view dialog for [material].
Future<void> showBookProgressDialog(
  BuildContext context, {
  required PrepMaterial material,
  required Color subjectColor,
}) {
  return showGlassDialog<void>(
    context: context,
    builder: (_) => BookProgressDialog(
      material: material,
      subjectColor: subjectColor,
    ),
  );
}

/// Interactive dialog hosting [BookProgressView] wired to live Prep materials,
/// [PrepProgressLogNotifier], active page flag pins, and inline revision marks.
class BookProgressDialog extends ConsumerStatefulWidget {
  /// Creates a [BookProgressDialog].
  const BookProgressDialog({
    required this.material,
    required this.subjectColor,
    super.key,
  });

  /// Target book displayed in this dialog.
  final PrepMaterial material;

  /// Resolved subject accent color.
  final Color subjectColor;

  @override
  ConsumerState<BookProgressDialog> createState() => _BookProgressDialogState();
}

class _BookProgressDialogState extends ConsumerState<BookProgressDialog> {
  static int _nextOpenId = 0;
  late final int _openVisitId;
  String? _lastSavedLogId;
  bool _justSavedPosition = false;
  bool _showRevisionComposer = false;

  @override
  void initState() {
    super.initState();
    _openVisitId = ++_nextOpenId;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final subjectMaterials = ref
            .watch(materialsForSubjectProvider(widget.material.subjectId))
            .asData
            ?.value ??
        const <PrepMaterial>[];
    final currentMaterial =
        subjectMaterials.where((m) => m.id == widget.material.id).firstOrNull ??
            widget.material;

    final revisionItems =
        ref.watch(revisionItemsForMaterialProvider(currentMaterial.id));
    final flagMarkers = <BookFlagMarker>[
      for (final item in revisionItems)
        if (item.pageNumber != null)
          BookFlagMarker(
            page: item.pageNumber!,
            label: item.referenceLabel,
          ),
    ];

    final logState = ref.watch(prepProgressLogControllerProvider);
    final isSaving =
        logState.isSaving && logState.activeMaterialId == currentMaterial.id;
    final controllerError = logState.error != null
        ? PrepL10n.failureMessage(logState.error!, l10n)
        : null;

    Widget? bottomRevisionSection;
    if (_showRevisionComposer) {
      bottomRevisionSection = RevisionFlagComposer(
        subjectId: currentMaterial.subjectId,
        materialId: currentMaterial.id,
        progressLogId: _lastSavedLogId,
        source: _lastSavedLogId != null
            ? RevisionSource.log
            : RevisionSource.manual,
        initialReference: currentMaterial.completedUnits > 0
            ? l10n.prepRevisionPageChip(
                currentMaterial.completedUnits.toString(),
              )
            : '',
        initialPageNumber: currentMaterial.completedUnits > 0
            ? currentMaterial.completedUnits
            : null,
        onClose: () => setState(() => _showRevisionComposer = false),
      );
    } else if (_justSavedPosition) {
      bottomRevisionSection = Container(
        key: const ValueKey('book-post-save-revision-banner'),
        padding: spacing.insetsAllMd,
        decoration: BoxDecoration(
          color: colors.goldAccentSubtle,
          borderRadius: tokens.radii.buttonRadius,
          border: Border.all(
            color: colors.goldAccent.withValues(alpha: 0.65),
          ),
        ),
        child: Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.prepRevisionPostSavePrompt,
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            GlassButton(
              key: const ValueKey('book-post-save-mark-revision-button'),
              variant: GlassButtonVariant.primary,
              leading: Icon(
                Icons.flag_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              onPressed: () => setState(() => _showRevisionComposer = true),
              child: Text(l10n.prepRevisionMarkAction),
            ),
          ],
        ),
      );
    }

    return GlassDialog(
      key: ValueKey('book-progress-dialog-${currentMaterial.id}'),
      maxWidth: 680,
      content: SingleChildScrollView(
        child: BookProgressView(
          title: currentMaterial.title,
          completedUnits: currentMaterial.completedUnits,
          totalUnits: currentMaterial.totalUnits,
          unitLabel: currentMaterial.unitLabel,
          accentColor: widget.subjectColor,
          lastUpdatedAt: currentMaterial.updatedAt ?? currentMaterial.createdAt,
          replayKey: 'book-dialog-${currentMaterial.id}-$_openVisitId',
          isSaving: isSaving,
          errorText: controllerError,
          flagMarkers: flagMarkers,
          bottomSection: bottomRevisionSection,
          cover: MaterialCoverThumbnail(
            title: currentMaterial.title,
            subjectColor: widget.subjectColor,
            coverImagePath: currentMaterial.coverImagePath,
            coverImageUrl: currentMaterial.coverImageUrl,
            expand: true,
          ),
          trailingAction: Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              if (!_showRevisionComposer)
                GlassButton(
                  key: const ValueKey('book-mark-for-revision-button'),
                  leading: Icon(
                    Icons.flag_outlined,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  onPressed: isSaving
                      ? null
                      : () => setState(() => _showRevisionComposer = true),
                  child: Text(l10n.prepRevisionMarkAction),
                ),
              GlassButton(
                key: ValueKey('book-open-history-${currentMaterial.id}'),
                leading: Icon(Icons.history, size: spacing.lg),
                onPressed: isSaving
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        unawaited(
                          showMaterialLogsDialog(
                            context,
                            material: currentMaterial,
                            subjectColor: widget.subjectColor,
                          ),
                        );
                      },
                child: Text(l10n.bookProgressHistoryButton),
              ),
            ],
          ),
          onCommitPosition: (targetPage, {required isCorrection}) async {
            final result = await ref
                .read(prepProgressLogControllerProvider.notifier)
                .setBookPositionAndReturn(
                  material: currentMaterial,
                  targetPage: targetPage,
                  confirmCorrection: isCorrection,
                );
            if (result == null) return false;
            if (mounted && result.savedLog != null) {
              setState(() {
                _lastSavedLogId = result.savedLog!.id;
                _justSavedPosition = !isCorrection;
              });
            }
            return true;
          },
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('book-dialog-close-button'),
          onPressed: () {
            ref.read(prepProgressLogControllerProvider.notifier).clearError();
            Navigator.of(context).pop();
          },
          child: Text(l10n.prepCloseButton),
        ),
      ],
    );
  }
}
