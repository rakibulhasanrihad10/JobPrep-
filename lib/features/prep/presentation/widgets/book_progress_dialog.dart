import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/book_progress_view.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_logs_dialog.dart';

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

/// Interactive dialog hosting [BookProgressView] wired to live Prep materials
/// and [PrepProgressLogNotifier] so position updates refresh books, subjects,
/// study plans, and the dashboard immediately.
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

  @override
  void initState() {
    super.initState();
    _openVisitId = ++_nextOpenId;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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

    final logState = ref.watch(prepProgressLogControllerProvider);
    final isSaving =
        logState.isSaving && logState.activeMaterialId == currentMaterial.id;
    final controllerError = logState.error != null
        ? PrepL10n.failureMessage(logState.error!, l10n)
        : null;

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
          cover: MaterialCoverThumbnail(
            title: currentMaterial.title,
            subjectColor: widget.subjectColor,
            coverImagePath: currentMaterial.coverImagePath,
            coverImageUrl: currentMaterial.coverImageUrl,
            expand: true,
          ),
          trailingAction: GlassButton(
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
          onCommitPosition: (targetPage, {required isCorrection}) async {
            final change = await ref
                .read(prepProgressLogControllerProvider.notifier)
                .setBookPosition(
                  material: currentMaterial,
                  targetPage: targetPage,
                  confirmCorrection: isCorrection,
                );
            return change != null;
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
