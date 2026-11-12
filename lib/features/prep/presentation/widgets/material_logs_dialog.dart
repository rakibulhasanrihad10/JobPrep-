import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_log_entry_fields.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_log_summary_header.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_past_logs_section.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_composer.dart';

/// Opens the custom progress logging and past logs history dialog.
Future<void> showMaterialLogsDialog(
  BuildContext context, {
  required PrepMaterial material,
  required Color subjectColor,
}) {
  return showGlassDialog<void>(
    context: context,
    builder: (_) => MaterialLogsDialog(
      material: material,
      subjectColor: subjectColor,
    ),
  );
}

/// Glass dialog allowing users to record a custom progress log with optional
/// note and date, and to edit or delete past logs for a study material.
class MaterialLogsDialog extends ConsumerStatefulWidget {
  /// Creates a [MaterialLogsDialog].
  const MaterialLogsDialog({
    required this.material,
    required this.subjectColor,
    super.key,
  });

  /// Material whose logs are managed inside this dialog.
  final PrepMaterial material;

  /// Subject accent color used on cover placeholder.
  final Color subjectColor;

  @override
  ConsumerState<MaterialLogsDialog> createState() => _MaterialLogsDialogState();
}

class _MaterialLogsDialogState extends ConsumerState<MaterialLogsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  ProgressLog? _editingLog;
  ProgressLog? _lastSavedLog;
  bool _justSavedLog = false;
  bool _showRevisionComposer = false;

  @override
  void initState() {
    super.initState();
    final now = ref.read(prepNowProvider)();
    _selectedDate = DateTime.utc(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _parsePositiveUnits(String? raw) {
    final normalized = AppFormatters.toEnglishDigits(raw?.trim() ?? '');
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = DateTime.utc(picked.year, picked.month, picked.day);
    });
  }

  void _startEditing(ProgressLog log) {
    ref.read(prepProgressLogControllerProvider.notifier).clearError();
    setState(() {
      _editingLog = log;
      _unitsController.text = log.unitsDone.toString();
      _noteController.text = log.note ?? '';
      _selectedDate = DateTime.utc(
        log.loggedOn.year,
        log.loggedOn.month,
        log.loggedOn.day,
      );
    });
  }

  void _cancelEditing() {
    final now = ref.read(prepNowProvider)();
    ref.read(prepProgressLogControllerProvider.notifier).clearError();
    setState(() {
      _editingLog = null;
      _unitsController.clear();
      _noteController.clear();
      _selectedDate = DateTime.utc(now.year, now.month, now.day);
    });
  }

  Future<void> _submit(PrepMaterial currentMaterial) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final units = _parsePositiveUnits(_unitsController.text)!;
    final controller = ref.read(prepProgressLogControllerProvider.notifier);

    if (_editingLog != null) {
      final ok = await controller.updateLog(
        material: currentMaterial,
        existing: _editingLog!,
        unitsDone: units,
        loggedOn: _selectedDate,
        note: _noteController.text,
      );
      if (!mounted || !ok) return;
      _cancelEditing();
      return;
    }

    final saved = await controller.logUnitsAndReturn(
      material: currentMaterial,
      units: units,
      loggedOn: _selectedDate,
      note: _noteController.text,
    );
    if (!mounted || saved == null) return;
    _cancelEditing();
    setState(() {
      _lastSavedLog = saved;
      _justSavedLog = true;
    });
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

    final logsAsync =
        ref.watch(progressLogsForMaterialProvider(widget.material.id));
    final mutationState = ref.watch(prepProgressLogControllerProvider);

    return GlassDialog(
      maxWidth: 520,
      title: Text(l10n.prepLogDialogTitle, style: tokens.textStyles.titleLarge),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialLogSummaryHeader(
                material: currentMaterial,
                subjectColor: widget.subjectColor,
              ),
              SizedBox(height: spacing.lg),
              MaterialLogEntryFields(
                unitsController: _unitsController,
                noteController: _noteController,
                selectedDate: _selectedDate,
                isEditing: _editingLog != null,
                isSaving: mutationState.isSaving,
                validateUnits: (value) => _parsePositiveUnits(value) == null
                    ? l10n.prepCustomUnitsInvalid
                    : null,
                onPickDate: _pickDate,
                onCancelEdit: _cancelEditing,
                onSubmit: () => _submit(currentMaterial),
                errorText: mutationState.error != null
                    ? PrepL10n.failureMessage(mutationState.error!, l10n)
                    : null,
              ),
              SizedBox(height: spacing.md),
              if (_justSavedLog && !_showRevisionComposer) ...[
                Container(
                  key: const ValueKey('log-post-save-revision-banner'),
                  padding: spacing.insetsAllMd,
                  decoration: BoxDecoration(
                    color: tokens.colors.goldAccentSubtle,
                    borderRadius: tokens.radii.buttonRadius,
                    border: Border.all(
                      color: tokens.colors.goldAccent.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.prepRevisionPostSavePrompt,
                        style: tokens.textStyles.bodySmall.copyWith(
                          color: tokens.colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlassButton(
                          key: const ValueKey(
                            'log-mark-for-revision-button',
                          ),
                          variant: GlassButtonVariant.primary,
                          leading: Icon(
                            Icons.flag_outlined,
                            size: spacing.lg,
                            color: tokens.colors.goldAccent,
                          ),
                          onPressed: () =>
                              setState(() => _showRevisionComposer = true),
                          child: Text(l10n.prepRevisionMarkAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!_showRevisionComposer) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: GlassButton(
                    key: const ValueKey('log-mark-for-revision-button'),
                    leading: Icon(
                      Icons.flag_outlined,
                      size: spacing.lg,
                      color: tokens.colors.goldAccent,
                    ),
                    onPressed: () =>
                        setState(() => _showRevisionComposer = true),
                    child: Text(l10n.prepRevisionMarkAction),
                  ),
                ),
              ],
              if (_showRevisionComposer) ...[
                SizedBox(height: spacing.sm),
                RevisionFlagComposer(
                  subjectId: currentMaterial.subjectId,
                  materialId: currentMaterial.id,
                  progressLogId: _lastSavedLog?.id,
                  source: _lastSavedLog != null
                      ? RevisionSource.log
                      : RevisionSource.manual,
                  initialReference: currentMaterial.completedUnits > 0 &&
                          currentMaterial.kind == MaterialKind.book
                      ? l10n.prepRevisionPageChip(
                          currentMaterial.completedUnits.toString(),
                        )
                      : '',
                  initialPageNumber:
                      currentMaterial.kind == MaterialKind.book &&
                              currentMaterial.completedUnits > 0
                          ? currentMaterial.completedUnits
                          : null,
                  onClose: () => setState(() => _showRevisionComposer = false),
                ),
              ],
              SizedBox(height: spacing.xl),
              Text(
                l10n.prepPastLogsTitle,
                style: tokens.textStyles.titleMedium,
              ),
              SizedBox(height: spacing.sm),
              MaterialPastLogsSection(
                logsAsync: logsAsync,
                unitLabel: currentMaterial.unitLabel,
                isBusy: mutationState.isSaving,
                onEditLog: _startEditing,
                onDeleteLog: (entry) => ref
                    .read(prepProgressLogControllerProvider.notifier)
                    .deleteLog(material: currentMaterial, log: entry),
              ),
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          onPressed: () {
            ref.read(prepProgressLogControllerProvider.notifier).clearError();
            Navigator.of(context).pop();
          },
          child: Text(l10n.prepCancelButton),
        ),
      ],
    );
  }
}
