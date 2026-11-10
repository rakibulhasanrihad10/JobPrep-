import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_material_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_editor.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Opens a dialog to create or edit a [PrepMaterial] under [subjectId].
Future<PrepMaterial?> showMaterialFormDialog(
  BuildContext context, {
  required String subjectId,
  required Color subjectColor,
  PrepMaterial? existing,
}) {
  return showGlassDialog<PrepMaterial?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => MaterialFormDialog(
      subjectId: subjectId,
      subjectColor: subjectColor,
      existing: existing,
    ),
  );
}

/// Glass dialog for creating or editing a user-defined study material with
/// optional uploaded cover photo (~600 px resized) or external image link.
class MaterialFormDialog extends ConsumerStatefulWidget {
  /// Creates a [MaterialFormDialog].
  const MaterialFormDialog({
    required this.subjectId,
    required this.subjectColor,
    super.key,
    this.existing,
  });

  /// Owning subject identifier.
  final String subjectId;

  /// Resolved accent color of the owning subject for glass placeholder preview.
  final Color subjectColor;

  /// Existing material to edit, or `null` when creating a new material.
  final PrepMaterial? existing;

  @override
  ConsumerState<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends ConsumerState<MaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _unitLabelController;
  late final TextEditingController _totalUnitsController;
  late final TextEditingController _coverUrlController;
  late MaterialKind _selectedKind;
  late MaterialCoverMode _coverMode;
  PreparedCoverImageResult? _pendingUpload;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '')
      ..addListener(_onPreviewFieldChanged);
    _unitLabelController = TextEditingController(
      text: existing?.unitLabel ?? '',
    );
    _totalUnitsController = TextEditingController(
      text: existing != null ? existing.totalUnits.toString() : '',
    );
    _coverUrlController = TextEditingController(
      text: existing?.coverImageUrl ?? '',
    )..addListener(_onPreviewFieldChanged);

    _selectedKind = existing?.kind ?? MaterialKind.book;
    if (existing?.coverImagePath?.trim().isNotEmpty ?? false) {
      _coverMode = MaterialCoverMode.upload;
    } else if (existing?.coverImageUrl?.trim().isNotEmpty ?? false) {
      _coverMode = MaterialCoverMode.url;
    } else {
      _coverMode = MaterialCoverMode.none;
    }
  }

  void _onPreviewFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onPreviewFieldChanged)
      ..dispose();
    _unitLabelController.dispose();
    _totalUnitsController.dispose();
    _coverUrlController
      ..removeListener(_onPreviewFieldChanged)
      ..dispose();
    super.dispose();
  }

  int? _parseTotalUnits(String? raw) {
    final normalized = AppFormatters.toEnglishDigits(raw?.trim() ?? '');
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  Future<void> _pickCoverImage() async {
    final picked = await ref.read(materialCoverPickerProvider)();
    if (!mounted || picked == null) return;

    final prepared = await ref
        .read(prepMaterialControllerProvider.notifier)
        .preparePickedCover(picked);
    if (!mounted || prepared == null) return;

    setState(() {
      _pendingUpload = prepared;
      _coverMode = MaterialCoverMode.upload;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final totalUnits = _parseTotalUnits(_totalUnitsController.text) ?? 0;
    final controller = ref.read(prepMaterialControllerProvider.notifier);

    final saved = await controller.saveMaterial(
      subjectId: widget.subjectId,
      existing: widget.existing,
      title: _titleController.text,
      kind: _selectedKind,
      unitLabel: _unitLabelController.text,
      totalUnits: totalUnits,
      pendingCoverUpload:
          _coverMode == MaterialCoverMode.upload ? _pendingUpload : null,
      coverUrl:
          _coverMode == MaterialCoverMode.url ? _coverUrlController.text : null,
      clearCover: _coverMode == MaterialCoverMode.none,
    );
    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final mutationState = ref.watch(prepMaterialControllerProvider);

    return GlassDialog(
      maxWidth: 560,
      title: Text(
        widget.existing == null
            ? l10n.prepCreateMaterialTitle
            : l10n.prepEditMaterialTitle,
        style: tokens.textStyles.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                key: const ValueKey('material-title-field'),
                controller: _titleController,
                labelText: l10n.prepMaterialTitleLabel,
                hintText: l10n.prepMaterialTitleHint,
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.prepMaterialTitleRequired
                    : null,
              ),
              SizedBox(height: spacing.lg),
              Text(
                l10n.prepMaterialKindLabel,
                style: tokens.textStyles.labelMedium,
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (final kind in MaterialKind.values)
                    PrepOptionChip(
                      key: ValueKey('material-kind-${kind.value}'),
                      label: PrepL10n.materialKindLabel(kind, l10n),
                      isSelected: _selectedKind == kind,
                      onTap: () => setState(() => _selectedKind = kind),
                    ),
                ],
              ),
              SizedBox(height: spacing.lg),
              GlassTextField(
                key: const ValueKey('material-unit-label-field'),
                controller: _unitLabelController,
                labelText: l10n.prepUnitLabelFieldLabel,
                hintText: l10n.prepUnitLabelHint,
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.prepUnitLabelRequired
                    : null,
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (final preset in PrepL10n.unitLabelSuggestions(l10n))
                    PrepOptionChip(
                      label: preset,
                      onTap: () => _unitLabelController.text = preset,
                    ),
                ],
              ),
              SizedBox(height: spacing.lg),
              GlassTextField(
                key: const ValueKey('material-total-units-field'),
                controller: _totalUnitsController,
                labelText: l10n.prepTotalUnitsLabel,
                hintText: l10n.prepTotalUnitsHint,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) => _parseTotalUnits(value) == null
                    ? l10n.prepTotalUnitsInvalid
                    : null,
              ),
              SizedBox(height: spacing.lg),
              MaterialCoverEditor(
                titlePreview: _titleController.text,
                subjectColor: widget.subjectColor,
                mode: _coverMode,
                urlController: _coverUrlController,
                existingCoverPath: widget.existing?.coverImagePath,
                pendingUpload: _pendingUpload,
                mutationState: mutationState,
                onPickImage: _pickCoverImage,
                onModeChanged: (next) {
                  ref
                      .read(prepMaterialControllerProvider.notifier)
                      .clearError();
                  setState(() {
                    _coverMode = next;
                    if (next != MaterialCoverMode.upload) {
                      _pendingUpload = null;
                    }
                  });
                },
              ),
              if (mutationState.error != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  PrepL10n.failureMessage(mutationState.error!, l10n),
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
          onPressed: mutationState.isBusy
              ? null
              : () {
                  ref
                      .read(prepMaterialControllerProvider.notifier)
                      .clearError();
                  Navigator.of(context).pop();
                },
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('material-save-button'),
          variant: GlassButtonVariant.primary,
          onPressed: mutationState.isBusy ? null : _submit,
          child: Text(l10n.prepSaveButton),
        ),
      ],
    );
  }
}
