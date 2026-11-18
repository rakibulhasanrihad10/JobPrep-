import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Modal dialog configuring tracked syllabus checkpoints on a subject.
class SubjectCheckpointsDialog extends ConsumerStatefulWidget {
  const SubjectCheckpointsDialog({
    required this.subject,
    super.key,
  });

  final Subject subject;

  static Future<void> show(
    BuildContext context, {
    required Subject subject,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => SubjectCheckpointsDialog(subject: subject),
    );
  }

  @override
  ConsumerState<SubjectCheckpointsDialog> createState() =>
      _SubjectCheckpointsDialogState();
}

class _SubjectCheckpointsDialogState
    extends ConsumerState<SubjectCheckpointsDialog> {
  late Set<String> _enabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _enabled = Set<String>.from(widget.subject.enabledCheckpoints);
  }

  bool _hasCompletedDataFor(
    SyllabusCheckpoint checkpoint,
    List<Topic> topics,
  ) {
    return topics.any(
      (t) => switch (checkpoint) {
        SyllabusCheckpoint.study => t.studyDoneAt != null,
        SyllabusCheckpoint.practice => t.practiceDoneAt != null,
        SyllabusCheckpoint.modelTest => t.modelTestDoneAt != null,
        SyllabusCheckpoint.revision => t.revisionDoneAt != null,
      },
    );
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(syllabusControllerProvider).updateSubjectCheckpoints(
            subject: widget.subject,
            enabledCheckpoints: _enabled.toList(),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    final topics =
        ref.watch(topicsForSubjectProvider(widget.subject.id)).asData?.value ??
            const [];

    final hasDisabledWithData = SyllabusCheckpoint.values.any((cp) {
      final wasOriginallyEnabled =
          widget.subject.enabledCheckpoints.contains(cp.value);
      final isNowDisabled = !_enabled.contains(cp.value);
      return wasOriginallyEnabled &&
          isNowDisabled &&
          _hasCompletedDataFor(cp, topics);
    });

    return GlassDialog(
      title: Text(
        l10n.syllabusConfigureCheckpoints,
        style: textStyles.titleMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.syllabusConfigureCheckpointsSubtitle(widget.subject.name),
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.md),
          ...SyllabusCheckpoint.values.map((cp) {
            final isChecked = _enabled.contains(cp.value);
            final label = switch (cp) {
              SyllabusCheckpoint.study => l10n.syllabusCheckpointStudy,
              SyllabusCheckpoint.practice => l10n.syllabusCheckpointPractice,
              SyllabusCheckpoint.modelTest => l10n.syllabusCheckpointModelTest,
              SyllabusCheckpoint.revision => l10n.syllabusCheckpointRevision,
            };
            return Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                key: ValueKey('checkpoint-config-${cp.value}'),
                value: isChecked,
                title: Text(
                  label,
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                activeColor: colors.goldAccent,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _enabled.add(cp.value);
                    } else {
                      _enabled.remove(cp.value);
                    }
                  });
                },
              ),
            );
          }),
          if (hasDisabledWithData) ...[
            SizedBox(height: spacing.sm),
            Container(
              padding: spacing.insetsAllSm,
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.15),
                borderRadius: tokens.radii.smRadius,
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colors.warning,
                    size: 16,
                  ),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      l10n.syllabusConfigureCheckpointsWarning,
                      style: textStyles.bodySmall.copyWith(
                        color: colors.warning,
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
        GlassButton(
          onPressed: _isSaving ? null : _handleSave,
          variant: GlassButtonVariant.primary,
          child: Text(
            MaterialLocalizations.of(context).saveButtonLabel,
          ),
        ),
      ],
    );
  }
}
