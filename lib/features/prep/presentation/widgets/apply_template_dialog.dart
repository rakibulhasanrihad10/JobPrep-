import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';

/// Opens a customization dialog letting the user adjust target unit counts of
/// a template's materials before copying them into their own prep workspace.
Future<PrepTemplateApplyResult?> showApplyTemplateDialog(
  BuildContext context, {
  required PrepTemplate template,
}) {
  return showGlassDialog<PrepTemplateApplyResult?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ApplyTemplateDialog(template: template),
  );
}

/// Preview and customize-units dialog before copying a [PrepTemplate].
class ApplyTemplateDialog extends ConsumerStatefulWidget {
  /// Creates an [ApplyTemplateDialog].
  const ApplyTemplateDialog({
    required this.template,
    super.key,
  });

  /// Template pack to inspect and apply.
  final PrepTemplate template;

  @override
  ConsumerState<ApplyTemplateDialog> createState() =>
      _ApplyTemplateDialogState();
}

class _ApplyTemplateDialogState extends ConsumerState<ApplyTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _unitControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final item in widget.template.items) {
      if (!item.hasMaterial) continue;
      final key = _overrideKeyForItem(item);
      _unitControllers[key] = TextEditingController(
        text: item.totalUnits.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _unitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  static String _overrideKeyForItem(PrepTemplateItem item) {
    if (item.id.trim().isNotEmpty) return item.id.trim();
    return PrepTemplatePlanner.subjectMaterialOverrideKey(item);
  }

  static int? _parseUnits(String raw) {
    final normalized = AppFormatters.toEnglishDigits(raw).trim();
    if (normalized.isEmpty) return null;
    final value = int.tryParse(normalized);
    if (value == null || value < 0) return null;
    return value;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final overrides = <String, int>{};
    for (final entry in _unitControllers.entries) {
      final parsed = _parseUnits(entry.value.text);
      if (parsed != null) {
        overrides[entry.key] = parsed;
      }
    }

    final result = await ref
        .read(prepTemplateActionControllerProvider.notifier)
        .applyTemplate(widget.template, unitOverrides: overrides);
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final actionState = ref.watch(prepTemplateActionControllerProvider);
    final groups = widget.template.groupedSubjects;
    final title = PrepL10n.templateTitle(widget.template, l10n);

    return GlassDialog(
      maxWidth: 620,
      title: Text(l10n.prepTemplateApplyConfirmTitle(title)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.prepTemplateApplyConfirmSubtitle,
                style: tokens.textStyles.bodySmall,
              ),
              SizedBox(height: spacing.md),
              for (final group in groups)
                Container(
                  margin: EdgeInsets.only(bottom: spacing.md),
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
                        children: [
                          Icon(
                            PrepStyleTokens.resolveSubjectIcon(
                              group.subjectIcon,
                            ),
                            size: spacing.lg,
                            color: PrepStyleTokens.resolveSubjectColor(
                              group.subjectColor,
                              colors,
                            ),
                          ),
                          SizedBox(width: spacing.xs),
                          Expanded(
                            child: Text(
                              group.subjectName,
                              style: tokens.textStyles.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      if (group.materials.isNotEmpty) ...[
                        SizedBox(height: spacing.sm),
                        for (final item in group.materials) ...[
                          Padding(
                            padding: EdgeInsets.only(bottom: spacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.materialTitle ?? '',
                                        style: tokens.textStyles.bodyMedium,
                                      ),
                                      SizedBox(height: spacing.xxs),
                                      Text(
                                        '${PrepL10n.materialKindLabel(
                                          item.materialKind,
                                          l10n,
                                        )} · ${item.unitLabel}',
                                        style: tokens.textStyles.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: spacing.md),
                                SizedBox(
                                  width: 120,
                                  child: GlassTextField(
                                    key: ValueKey(
                                      'template-unit-field-'
                                      '${_overrideKeyForItem(item)}',
                                    ),
                                    controller: _unitControllers[
                                        _overrideKeyForItem(item)],
                                    labelText: l10n.prepTotalUnitsLabel,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (_parseUnits(value ?? '') == null) {
                                        return l10n.prepTemplateUnitsInvalid;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              if (actionState.error != null) ...[
                Text(
                  PrepL10n.failureMessage(actionState.error!, l10n),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          onPressed:
              actionState.isBusy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('confirm-apply-template-button'),
          variant: GlassButtonVariant.primary,
          onPressed: actionState.isBusy ? null : _submit,
          child: actionState.isBusy
              ? SizedBox(
                  width: spacing.lg,
                  height: spacing.lg,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.prepTemplateConfirmApplyAction),
        ),
      ],
    );
  }
}
