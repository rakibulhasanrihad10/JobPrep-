import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/presentation/utils/today_l10n.dart';

/// Opens a focused Quick Log dialog for logging progress units on [row]
/// directly from Today's study targets.
Future<bool> showTodayQuickLogDialog(
  BuildContext context, {
  required TodayStudyTargetRow row,
}) async {
  final saved = await showGlassDialog<bool>(
    context: context,
    builder: (_) => _TodayQuickLogDialog(row: row),
  );
  return saved ?? false;
}

class _TodayQuickLogDialog extends ConsumerStatefulWidget {
  const _TodayQuickLogDialog({required this.row});

  final TodayStudyTargetRow row;

  @override
  ConsumerState<_TodayQuickLogDialog> createState() =>
      _TodayQuickLogDialogState();
}

class _TodayQuickLogDialogState extends ConsumerState<_TodayQuickLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  late String? _selectedMaterialId;

  @override
  void initState() {
    super.initState();
    _selectedMaterialId = widget.row.defaultLogMaterial?.id ??
        (widget.row.scopedMaterials.isNotEmpty
            ? widget.row.scopedMaterials.first.id
            : null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(prepProgressLogControllerProvider.notifier).clearError();
      }
    });
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  int? _parsePositiveUnits(String? raw) {
    final normalized = AppFormatters.toEnglishDigits(raw?.trim() ?? '');
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  PrepMaterial? get _selectedMaterial {
    final id = _selectedMaterialId;
    if (id == null) return null;
    for (final mat in widget.row.scopedMaterials) {
      if (mat.id == id) return mat;
    }
    return null;
  }

  Future<void> _submit() async {
    final material = _selectedMaterial;
    if (material == null) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final units = _parsePositiveUnits(_unitsController.text);
    if (units == null) return;

    final now = ref.read(prepNowProvider)();
    final ok =
        await ref.read(prepProgressLogControllerProvider.notifier).logUnits(
              material: material,
              units: units,
              loggedOn: DateTime.utc(now.year, now.month, now.day),
            );
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final logState = ref.watch(prepProgressLogControllerProvider);
    final router = GoRouter.maybeOf(context);

    final scopeTitle = TodayL10n.planScopeTitle(
      isAllSubjects: widget.row.isAllSubjects,
      subject: widget.row.subject,
      l10n: l10n,
    );
    final materials = widget.row.scopedMaterials;

    return GlassDialog(
      key: const ValueKey('today-quick-log-dialog'),
      maxWidth: 440,
      title: Text(l10n.todayQuickLogTitle(scopeTitle)),
      content: materials.isEmpty
          ? Text(
              l10n.todayQuickLogNoMaterialsBody,
              style: tokens.textStyles.bodyMedium,
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    key: const ValueKey('today-quick-log-material-dropdown'),
                    initialValue: _selectedMaterial?.id,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.prepRevisionMaterialOptionalLabel,
                      border:
                          OutlineInputBorder(borderRadius: radii.buttonRadius),
                    ),
                    dropdownColor: colors.surfaceElevated,
                    items: [
                      for (final mat in materials)
                        DropdownMenuItem<String>(
                          value: mat.id,
                          child: Text(
                            mat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: logState.isSaving
                        ? null
                        : (id) => setState(() => _selectedMaterialId = id),
                  ),
                  SizedBox(height: spacing.md),
                  Wrap(
                    spacing: spacing.xs,
                    runSpacing: spacing.xs,
                    children: [
                      for (final preset in const [5, 10, 20, 50])
                        PrepOptionChip(
                          key: ValueKey('today-quick-log-preset-$preset'),
                          label: l10n.todayQuickLogPresetChip(
                            TodayL10n.formatCount(
                              preset,
                              locale: locale,
                              useBanglaDigits: useBanglaDigits,
                            ),
                          ),
                          isSelected:
                              _parsePositiveUnits(_unitsController.text) ==
                                  preset,
                          onTap: logState.isSaving
                              ? null
                              : () => setState(() {
                                    _unitsController.text = preset.toString();
                                  }),
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  GlassTextField(
                    key: const ValueKey('today-quick-log-units-field'),
                    controller: _unitsController,
                    labelText: l10n.prepCustomUnitsLabel,
                    keyboardType: TextInputType.number,
                    enabled: !logState.isSaving,
                    validator: (value) {
                      if (_parsePositiveUnits(value) == null) {
                        return l10n.prepCustomUnitsInvalid;
                      }
                      return null;
                    },
                  ),
                  if (logState.error != null) ...[
                    SizedBox(height: spacing.sm),
                    Text(
                      PrepL10n.failureMessage(logState.error!, l10n),
                      style: tokens.textStyles.bodySmall.copyWith(
                        color: colors.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        GlassButton(
          onPressed:
              logState.isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        if (materials.isEmpty)
          GlassButton(
            key: const ValueKey('today-quick-log-open-subject-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: () {
              Navigator.of(context).pop(false);
              final subjectId = widget.row.subject?.id;
              router?.go(subjectId == null ? '/prep' : '/prep/$subjectId');
            },
            child: Text(l10n.todayQuickLogOpenSubjectButton),
          )
        else
          GlassButton(
            key: const ValueKey('today-quick-log-submit-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: logState.isSaving ? null : () => unawaited(_submit()),
            child: Text(l10n.prepSaveButton),
          ),
      ],
    );
  }
}
