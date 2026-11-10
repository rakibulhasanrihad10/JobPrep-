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
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_subjects_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_delete_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_subject_detail_header_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_form_dialog.dart';

/// Displays header, progress ring, and study materials for [subject].
class PrepSubjectDetailView extends ConsumerWidget {
  /// Creates a [PrepSubjectDetailView].
  const PrepSubjectDetailView({
    required this.subject,
    super.key,
    this.onBack,
    this.onSubjectDeleted,
    this.replayKey,
  });

  /// Subject currently inspected.
  final Subject subject;

  /// Optional back action shown on compact mobile routes.
  final VoidCallback? onBack;

  /// Invoked after deleting [subject] successfully.
  final VoidCallback? onSubjectDeleted;

  /// Optional key controlling progress animations.
  final Object? replayKey;

  Future<void> _handleAddMaterial(
    BuildContext context,
    Color subjectColor,
  ) async {
    await showMaterialFormDialog(
      context,
      subjectId: subject.id,
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
      subjectId: subject.id,
      subjectColor: subjectColor,
      existing: material,
    );
  }

  Future<void> _handleDeleteMaterial(
    BuildContext context,
    WidgetRef ref,
    PrepMaterial material,
  ) async {
    final confirmed = await showDeleteMaterialDialog(
      context,
      material: material,
    );
    if (!confirmed || !context.mounted) return;
    await ref
        .read(prepMaterialControllerProvider.notifier)
        .deleteMaterial(material);
  }

  Future<void> _handleDeleteSubject(
    BuildContext context,
    WidgetRef ref,
    List<PrepMaterial> materials,
  ) async {
    final confirmed = await showDeleteSubjectDialog(
      context,
      subject: subject,
      subjectMaterials: materials,
    );
    if (!confirmed || !context.mounted) return;
    final deleted = await ref
        .read(prepSubjectsControllerProvider.notifier)
        .deleteSubject(subject);
    if (deleted) {
      onSubjectDeleted?.call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final subjectColor = PrepStyleTokens.resolveSubjectColor(
      subject.color,
      colors,
    );
    final materialsAsync = ref.watch(materialsForSubjectProvider(subject.id));
    final materials = materialsAsync.asData?.value ?? const <PrepMaterial>[];
    final subjectProgress = calculateSubjectProgress(materials);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrepSubjectDetailHeaderCard(
          subject: subject,
          subjectColor: subjectColor,
          subjectProgress: subjectProgress,
          materialCount: materials.length,
          onBack: onBack,
          replayKey: replayKey,
          onAddMaterial: () => _handleAddMaterial(context, subjectColor),
          onEditSubject: () =>
              showSubjectFormDialog(context, existing: subject),
          onDeleteSubject: () => _handleDeleteSubject(context, ref, materials),
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
                final columns = constraints.maxWidth >= 680 ? 2 : 1;
                if (columns == 1) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items) ...[
                        MaterialCard(
                          material: item,
                          subjectColor: subjectColor,
                          replayKey: replayKey,
                          onEdit: () => _handleEditMaterial(
                            context,
                            item,
                            subjectColor,
                          ),
                          onDelete: () =>
                              _handleDeleteMaterial(context, ref, item),
                        ),
                        SizedBox(height: spacing.md),
                      ],
                    ],
                  );
                }

                final tileWidth = (constraints.maxWidth - spacing.md) / 2;
                return Wrap(
                  spacing: spacing.md,
                  runSpacing: spacing.md,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: tileWidth,
                        child: MaterialCard(
                          material: item,
                          subjectColor: subjectColor,
                          replayKey: replayKey,
                          onEdit: () => _handleEditMaterial(
                            context,
                            item,
                            subjectColor,
                          ),
                          onDelete: () =>
                              _handleDeleteMaterial(context, ref, item),
                        ),
                      ),
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
