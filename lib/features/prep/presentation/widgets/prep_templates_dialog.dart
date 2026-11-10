import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_template_ui_helpers.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_template_card.dart';

/// Opens the starter packs & personal templates manager dialog.
Future<void> showPrepTemplatesDialog(BuildContext context) {
  return showGlassDialog<void>(
    context: context,
    builder: (_) => const PrepTemplatesDialog(),
  );
}

/// Modal dialog listing read-only seeded packs (`Government Job`, `Software
/// Engineer`) and user-saved personal templates with apply/customize/save/delete.
class PrepTemplatesDialog extends ConsumerWidget {
  /// Creates a [PrepTemplatesDialog].
  const PrepTemplatesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    final templatesAsync = ref.watch(prepTemplatesProvider);
    final subjects =
        ref.watch(subjectsProvider).asData?.value ?? const <Subject>[];
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final actionState = ref.watch(prepTemplateActionControllerProvider);

    return GlassDialog(
      maxWidth: 640,
      title: Row(
        children: [
          Expanded(child: Text(l10n.prepTemplatesDialogTitle)),
          IconButton(
            tooltip: l10n.prepCancelButton,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (subjects.isNotEmpty) ...[
              Container(
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: radii.cardRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.bookmark_add_outlined,
                          color: colors.goldAccent,
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: Text(
                            l10n.prepTemplatesPersonalEmpty,
                            style: tokens.textStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: GlassButton(
                        key: const ValueKey('dialog-save-as-template-button'),
                        variant: GlassButtonVariant.primary,
                        onPressed: actionState.isBusy
                            ? null
                            : () => unawaited(
                                  PrepTemplateUiHelpers.savePersonalAndNotify(
                                    context,
                                    subjects: subjects,
                                    materials: materials,
                                  ),
                                ),
                        child: Text(l10n.prepSaveAsTemplateButton),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
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
                    onPressed: () => unawaited(
                      ref.read(prepTemplatesProvider.notifier).refresh(),
                    ),
                    child: Text(l10n.calendarRetry),
                  ),
                ],
              ),
              data: (templates) {
                final systemPacks =
                    templates.where((t) => t.isSystem).toList(growable: false);
                final personalPacks =
                    templates.where((t) => !t.isSystem).toList(growable: false);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.prepTemplatesSystemSection,
                      style: tokens.textStyles.titleMedium,
                    ),
                    SizedBox(height: spacing.sm),
                    for (final pack in systemPacks)
                      PrepTemplateCard(
                        template: pack,
                        isAlreadyApplied: PrepTemplatePlanner.isAlreadyApplied(
                          template: pack,
                          existingSubjects: subjects,
                          existingMaterials: materials,
                        ),
                        isBusy: actionState.isBusy,
                        isActive:
                            actionState.activeTemplateId == pack.stableKey,
                        onApply: () => unawaited(
                          PrepTemplateUiHelpers.applyAndNotify(
                            context,
                            ref,
                            pack,
                          ),
                        ),
                        onCustomize: () => unawaited(
                          PrepTemplateUiHelpers.customizeAndNotify(
                            context,
                            pack,
                          ),
                        ),
                      ),
                    SizedBox(height: spacing.md),
                    Text(
                      l10n.prepTemplatesPersonalSection,
                      style: tokens.textStyles.titleMedium,
                    ),
                    SizedBox(height: spacing.sm),
                    if (personalPacks.isEmpty)
                      Text(
                        l10n.prepTemplatesPersonalEmpty,
                        style: tokens.textStyles.bodySmall,
                      )
                    else
                      for (final pack in personalPacks)
                        PrepTemplateCard(
                          template: pack,
                          isAlreadyApplied:
                              PrepTemplatePlanner.isAlreadyApplied(
                            template: pack,
                            existingSubjects: subjects,
                            existingMaterials: materials,
                          ),
                          isBusy: actionState.isBusy,
                          isActive:
                              actionState.activeTemplateId == pack.stableKey,
                          onApply: () => unawaited(
                            PrepTemplateUiHelpers.applyAndNotify(
                              context,
                              ref,
                              pack,
                            ),
                          ),
                          onCustomize: () => unawaited(
                            PrepTemplateUiHelpers.customizeAndNotify(
                              context,
                              pack,
                            ),
                          ),
                          onDelete: () => unawaited(
                            PrepTemplateUiHelpers.confirmAndDeleteTemplate(
                              context,
                              ref,
                              pack,
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
      ],
    );
  }
}
