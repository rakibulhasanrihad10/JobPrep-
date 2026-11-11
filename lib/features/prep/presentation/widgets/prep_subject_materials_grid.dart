import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_card.dart';

/// Responsive grid rendering all study materials for a subject (`3` per row on
/// desktop, `2` per row on mobile) along with loading and empty states.
class PrepSubjectMaterialsGrid extends StatelessWidget {
  /// Creates a [PrepSubjectMaterialsGrid].
  const PrepSubjectMaterialsGrid({
    required this.subjectName,
    required this.subjectColor,
    required this.materialsAsync,
    required this.logState,
    required this.replayKey,
    required this.onRetry,
    required this.onAddMaterial,
    required this.onEditMaterial,
    required this.onDeleteMaterial,
    required this.onQuickLog,
    required this.onOpenLogs,
    required this.onOpenBookView,
    super.key,
  });

  /// Owning subject display name used in empty states.
  final String subjectName;

  /// Resolved subject accent color.
  final Color subjectColor;

  /// Loaded materials async snapshot.
  final AsyncValue<List<PrepMaterial>> materialsAsync;

  /// Active progress log mutation state for disabling busy cards.
  final PrepProgressLogState logState;

  /// Key controlling [MaterialCard] progress bar replay animations.
  final Object replayKey;

  /// Triggered on error retry button tap.
  final VoidCallback onRetry;

  /// Triggered on empty-state Add material CTA tap.
  final VoidCallback onAddMaterial;

  /// Opens material editing dialog.
  final ValueChanged<PrepMaterial> onEditMaterial;

  /// Initiates material deletion confirmation.
  final ValueChanged<PrepMaterial> onDeleteMaterial;

  /// Records a quick increment on a specific material.
  final void Function(PrepMaterial material, int delta) onQuickLog;

  /// Opens custom progress logging & log history dialog.
  final ValueChanged<PrepMaterial> onOpenLogs;

  /// Opens 3D interactive `BookProgressView` dialog for a book material.
  final ValueChanged<PrepMaterial> onOpenBookView;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return materialsAsync.when(
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
              onPressed: onRetry,
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
                  l10n.prepEmptyMaterialsTitle(subjectName),
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
                  onPressed: onAddMaterial,
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
                                replayKey: replayKey,
                                isLogging: logState.isSaving &&
                                    logState.activeMaterialId ==
                                        items[i + col].id,
                                onEdit: () => onEditMaterial(items[i + col]),
                                onDelete: () =>
                                    onDeleteMaterial(items[i + col]),
                                onQuickLog: (delta) =>
                                    onQuickLog(items[i + col], delta),
                                onOpenLogs: () => onOpenLogs(items[i + col]),
                                onOpenBookView:
                                    items[i + col].kind == MaterialKind.book
                                        ? () => onOpenBookView(items[i + col])
                                        : null,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                        ],
                      ],
                    ),
                  ),
                  if (i + columns < items.length) SizedBox(height: spacing.md),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
