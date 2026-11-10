import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/apply_template_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/save_personal_template_dialog.dart';

/// Shared template apply/customize/save/delete coordination helpers used across
/// `PrepScreen` and `PrepTemplatesDialog`.
abstract final class PrepTemplateUiHelpers {
  /// Applies [template] directly with idempotent deduplication and announces
  /// created counts via [ScaffoldMessenger].
  static Future<void> applyAndNotify(
    BuildContext context,
    WidgetRef ref,
    PrepTemplate template,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final result = await ref
        .read(prepTemplateActionControllerProvider.notifier)
        .applyTemplate(template);
    if (result == null) return;
    messenger
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            PrepL10n.applyResultMessage(result, template, l10n, locale),
          ),
        ),
      );
  }

  /// Opens unit customization dialog for [template] and announces copy summary.
  static Future<void> customizeAndNotify(
    BuildContext context,
    PrepTemplate template,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final result = await showApplyTemplateDialog(context, template: template);
    if (result == null) return;
    messenger
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            PrepL10n.applyResultMessage(result, template, l10n, locale),
          ),
        ),
      );
  }

  /// Opens personal-template snapshot dialog for [subjects] and [materials].
  static Future<void> savePersonalAndNotify(
    BuildContext context, {
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final saved = await showSavePersonalTemplateDialog(
      context,
      subjects: subjects,
      materials: materials,
    );
    if (saved == null) return;
    messenger
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.prepSaveTemplateSavedSnackbar(saved.title)),
        ),
      );
  }

  /// Prompts confirmation before deleting a user-owned personal [template].
  static Future<void> confirmAndDeleteTemplate(
    BuildContext context,
    WidgetRef ref,
    PrepTemplate template,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final title = PrepL10n.templateTitle(template, l10n);

    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (dialogContext) => GlassDialog(
        title: Text(l10n.prepDeleteTemplateTitle),
        content: Text(
          l10n.prepDeleteTemplateMessage(title),
          style: dialogContext.tokens.textStyles.bodyMedium,
        ),
        actions: [
          GlassButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.prepCancelButton),
          ),
          GlassButton(
            key: const ValueKey('confirm-delete-template-button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.prepDeleteConfirmButton,
              style: dialogContext.tokens.textStyles.labelLarge.copyWith(
                color: dialogContext.tokens.colors.danger,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final deleted = await ref
        .read(prepTemplateActionControllerProvider.notifier)
        .deletePersonalTemplate(template);
    if (deleted) {
      messenger
        ?..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.prepDeleteTemplateDeletedSnackbar(title)),
          ),
        );
    }
  }
}
