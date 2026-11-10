import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';

/// Prompts for confirmation before deleting [subject], highlighting any
/// logged progress across its materials.
Future<bool> showDeleteSubjectDialog(
  BuildContext context, {
  required Subject subject,
  required List<PrepMaterial> subjectMaterials,
}) async {
  final loggedUnits = subjectMaterials.fold<int>(
    0,
    (sum, item) => sum + item.completedUnits,
  );
  final confirmed = await showGlassDialog<bool>(
    context: context,
    builder: (dialogContext) => _PrepDeleteConfirmationDialog(
      title: dialogContext.l10n.prepDeleteSubjectTitle(subject.name),
      body: dialogContext.l10n.prepDeleteSubjectBody,
      progressWarning: loggedUnits > 0
          ? dialogContext.l10n.prepDeleteSubjectProgressWarning(
              PrepL10n.formatInt(
                loggedUnits,
                Localizations.localeOf(dialogContext),
              ),
            )
          : null,
    ),
  );
  return confirmed ?? false;
}

/// Prompts for confirmation before deleting [material], showing logged progress
/// details whenever `material.completedUnits > 0`.
Future<bool> showDeleteMaterialDialog(
  BuildContext context, {
  required PrepMaterial material,
}) async {
  final locale = Localizations.localeOf(context);
  final l10n = context.l10n;
  final hasProgress = material.completedUnits > 0;
  final warningText = hasProgress
      ? l10n.prepDeleteMaterialProgressWarning(
          PrepL10n.formatInt(material.completedUnits, locale),
          PrepL10n.formatInt(material.totalUnits, locale),
          material.unitLabel,
          PrepL10n.formatPercent(
            calculateMaterialProgress(material),
            locale,
          ),
        )
      : null;

  final confirmed = await showGlassDialog<bool>(
    context: context,
    builder: (dialogContext) => _PrepDeleteConfirmationDialog(
      title: dialogContext.l10n.prepDeleteMaterialTitle(material.title),
      body: dialogContext.l10n.prepDeleteMaterialBody,
      progressWarning: warningText,
    ),
  );
  return confirmed ?? false;
}

class _PrepDeleteConfirmationDialog extends StatelessWidget {
  const _PrepDeleteConfirmationDialog({
    required this.title,
    required this.body,
    this.progressWarning,
  });

  final String title;
  final String body;
  final String? progressWarning;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    return GlassDialog(
      title: Text(title, style: tokens.textStyles.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(body, style: tokens.textStyles.bodyMedium),
          if (progressWarning != null) ...[
            SizedBox(height: spacing.md),
            Container(
              key: const ValueKey('prep-delete-progress-warning'),
              padding: spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.14),
                borderRadius: radii.buttonRadius,
                border: Border.all(color: colors.warning),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colors.warning,
                    size: spacing.lg + spacing.xs,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      progressWarning!,
                      style: tokens.textStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        GlassButton(
          key: const ValueKey('prep-delete-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('prep-delete-confirm'),
          variant: GlassButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.prepDeleteConfirmButton),
        ),
      ],
    );
  }
}
