import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_composer.dart';

/// Opens the finish sheet to save the active [StudySession], optionally log
/// completed units for [material] via `PrepProgressLogNotifier`, and
/// optionally open the inline `RevisionFlagComposer` from Phase 6G.
Future<bool> showStudySessionFinishSheet(
  BuildContext context, {
  required StudySession activeSession,
  required int studiedSeconds,
  required Subject? subject,
  PrepMaterial? material,
}) async {
  final saved = await showGlassDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _StudySessionFinishDialog(
      activeSession: activeSession,
      studiedSeconds: studiedSeconds,
      subject: subject,
      material: material,
    ),
  );
  return saved ?? false;
}

class _StudySessionFinishDialog extends ConsumerStatefulWidget {
  const _StudySessionFinishDialog({
    required this.activeSession,
    required this.studiedSeconds,
    required this.subject,
    required this.material,
  });

  final StudySession activeSession;
  final int studiedSeconds;
  final Subject? subject;
  final PrepMaterial? material;

  @override
  ConsumerState<_StudySessionFinishDialog> createState() =>
      _StudySessionFinishDialogState();
}

class _StudySessionFinishDialogState
    extends ConsumerState<_StudySessionFinishDialog> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  String? _unitsError;
  bool _wantMarkForRevision = false;
  bool _isSaving = false;
  StudySession? _savedSession;
  ProgressLog? _savedLog;

  @override
  void dispose() {
    _noteController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    final l10n = context.l10n;

    int? parsedUnits;
    final rawUnits =
        AppFormatters.toEnglishDigits(_unitsController.text.trim());
    if (widget.material != null && rawUnits.isNotEmpty) {
      final candidate = int.tryParse(rawUnits);
      if (candidate == null || candidate <= 0) {
        setState(() => _unitsError = l10n.prepTimerFinishUnitsError);
        return;
      }
      parsedUnits = candidate;
    }

    setState(() {
      _unitsError = null;
      _isSaving = true;
    });

    final savedSession = await ref
        .read(studyTimerControllerProvider.notifier)
        .finishActiveSession(note: _noteController.text);
    if (!mounted) return;
    if (savedSession == null) {
      setState(() => _isSaving = false);
      return;
    }

    ProgressLog? createdLog;
    if (parsedUnits != null && widget.material != null) {
      createdLog = await ref
          .read(prepProgressLogControllerProvider.notifier)
          .logUnitsAndReturn(
            material: widget.material!,
            units: parsedUnits,
            loggedOn: savedSession.endedAt,
            note: _noteController.text,
          );
    }
    if (!mounted) return;

    if (!_wantMarkForRevision) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
      _savedSession = savedSession;
      _savedLog = createdLog;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final timerError = ref.watch(studyTimerControllerProvider).error;

    final formattedDuration = StudyTimerL10n.formatClock(
      widget.studiedSeconds,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    if (_savedSession != null) {
      return GlassDialog(
        key: const ValueKey('timer-finish-saved-dialog'),
        maxWidth: 540,
        title: Text(l10n.prepTimerFinishSavedHeading),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RevisionFlagComposer(
                subjectId: _savedSession!.subjectId,
                materialId: _savedSession!.materialId,
                progressLogId: _savedLog?.id,
                source: _savedLog != null
                    ? RevisionSource.log
                    : RevisionSource.manual,
              ),
            ],
          ),
        ),
        actions: [
          GlassButton(
            key: const ValueKey('timer-finish-done-btn'),
            variant: GlassButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.prepTimerFinishDoneButton),
          ),
        ],
      );
    }

    return GlassDialog(
      key: const ValueKey('timer-finish-dialog'),
      maxWidth: 520,
      title: Text(l10n.prepTimerFinishDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: tokens.radii.cardRadius,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: spacing.xl,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.prepTimerFinishDurationLabel,
                          style: tokens.textStyles.bodySmall,
                        ),
                        Text(
                          formattedDuration,
                          key: const ValueKey('timer-finish-duration-text'),
                          style: tokens.textStyles.headlineMedium.copyWith(
                            color: colors.goldAccent,
                          ),
                        ),
                        if (widget.subject != null)
                          Text(
                            widget.material != null
                                ? '${widget.subject!.name} • '
                                    '${widget.material!.title}'
                                : widget.subject!.name,
                            style: tokens.textStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.md),
            GlassTextField(
              key: const ValueKey('timer-finish-note-field'),
              controller: _noteController,
              enabled: !_isSaving,
              labelText: l10n.prepTimerFinishNoteLabel,
              hintText: l10n.prepTimerFinishNoteHint,
            ),
            if (widget.material != null) ...[
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('timer-finish-units-field'),
                controller: _unitsController,
                enabled: !_isSaving,
                labelText:
                    l10n.prepTimerFinishUnitsLabel(widget.material!.title),
                hintText: l10n.prepTimerFinishUnitsHint,
                errorText: _unitsError,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  if (_unitsError != null) setState(() => _unitsError = null);
                },
              ),
            ],
            SizedBox(height: spacing.sm),
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                key: const ValueKey('timer-finish-revision-checkbox'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _wantMarkForRevision,
                onChanged: _isSaving
                    ? null
                    : (v) => setState(() => _wantMarkForRevision = v ?? false),
                title: Text(
                  l10n.prepTimerFinishFlagRevisionCheck,
                  style: tokens.textStyles.bodyMedium,
                ),
              ),
            ),
            if (timerError != null) ...[
              SizedBox(height: spacing.xs),
              Text(
                PrepL10n.failureMessage(timerError, l10n),
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
          key: const ValueKey('timer-finish-cancel-btn'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('timer-finish-save-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _isSaving ? null : _handleSave,
          child: Text(l10n.prepTimerFinishSaveButton),
        ),
      ],
    );
  }
}
