import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';

/// Helper coordinating post-save actions for mock tests:
/// 1. Linking topics
/// 2. Offering to mark model_test checkpoint done on linked topics
/// 3. Offering to add weak topics to revision queue
abstract final class MockTestPostSaveHelper {
  /// SharedPreferences key for remembered auto-marking preference.
  static const String autoMarkCheckpointPrefKey =
      'auto_mark_model_test_checkpoint';

  /// Executes post-save linking and interactive automation offers.
  static Future<void> handlePostSaveAutomations(
    BuildContext context,
    WidgetRef ref, {
    required MockTest test,
    required List<String> linkedTopicIds,
    required List<Topic> weakTopics,
  }) async {
    // 1. Persist mock test topic links
    if (linkedTopicIds.isNotEmpty) {
      final topicRepo = ref.read(mockTestTopicRepositoryProvider);
      try {
        await topicRepo.setTopicsForMockTest(test.id, linkedTopicIds);
      } on Object catch (_) {
        // Storage unconfigured or offline
      }

      final prefs = ref.read(sharedPreferencesProvider);
      final autoMark = prefs.getBool(autoMarkCheckpointPrefKey) ?? false;

      var shouldMark = autoMark;
      if (!autoMark && context.mounted) {
        final result = await showGlassDialog<bool>(
          context: context,
          builder: (ctx) => _ConfirmModelTestCheckpointDialog(
            count: linkedTopicIds.length,
            onToggleAuto: (val) {
              unawaited(prefs.setBool(autoMarkCheckpointPrefKey, val));
            },
          ),
        );
        shouldMark = result ?? false;
      }

      if (shouldMark) {
        final syllabusCtrl = ref.read(syllabusControllerProvider);
        final topicRepo = ref.read(topicRepositoryProvider);
        final topics = await topicRepo.getTopicsForSubject(test.subjectId);
        final topicMap = {for (final t in topics) t.id: t};
        for (final topicId in linkedTopicIds) {
          final topic = topicMap[topicId];
          if (topic != null) {
            await syllabusCtrl.updateTopicDate(
              topic: topic,
              checkpoint: SyllabusCheckpoint.modelTest,
              date: test.takenOn,
            );
          }
        }
      }
    }

    // 2. Offer to add weak topics to revision queue
    if (weakTopics.isNotEmpty && context.mounted) {
      final shouldAddToRevision = await showGlassDialog<bool>(
        context: context,
        builder: (ctx) => _ConfirmAddToRevisionDialog(
          topics: weakTopics,
        ),
      );

      if (shouldAddToRevision == true) {
        final revCtrl = ref.read(revisionControllerProvider.notifier);
        for (final topic in weakTopics) {
          await revCtrl.addFlag(
            subjectId: test.subjectId,
            referenceLabel: topic.title,
            materialId: test.materialId,
            topicId: topic.id,
            mockTestId: test.id,
            source: RevisionSource.mockTest,
            reason: RevisionReason.mistake,
          );
        }
      }
    }
  }
}

class _ConfirmModelTestCheckpointDialog extends StatefulWidget {
  const _ConfirmModelTestCheckpointDialog({
    required this.count,
    required this.onToggleAuto,
  });

  final int count;
  final ValueChanged<bool> onToggleAuto;

  @override
  State<_ConfirmModelTestCheckpointDialog> createState() =>
      _ConfirmModelTestCheckpointDialogState();
}

class _ConfirmModelTestCheckpointDialogState
    extends State<_ConfirmModelTestCheckpointDialog> {
  bool _doAutomatically = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('confirm-model-test-checkpoint-dialog'),
      title: Text(
        l10n.prepMockMarkCheckpointsTitle,
        style: tokens.textStyles.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.prepMockMarkCheckpointsPrompt(widget.count),
            style: tokens.textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              Checkbox(
                key: const ValueKey('auto-mark-checkpoint-checkbox'),
                value: _doAutomatically,
                onChanged: (val) {
                  setState(() => _doAutomatically = val ?? false);
                  widget.onToggleAuto(_doAutomatically);
                },
              ),
              Expanded(
                child: Text(
                  l10n.prepMockMarkCheckpointsAuto,
                  style: tokens.textStyles.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GlassButton(
          key: const ValueKey('mark-checkpoint-no-btn'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('mark-checkpoint-yes-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.prepMockMarkCheckpointsAction),
        ),
      ],
    );
  }
}

class _ConfirmAddToRevisionDialog extends StatelessWidget {
  const _ConfirmAddToRevisionDialog({required this.topics});

  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('confirm-add-to-revision-dialog'),
      title: Text(
        l10n.prepMockAddToRevisionPrompt,
        style: tokens.textStyles.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: topics.map((t) {
              return Chip(
                label: Text(t.title),
                labelStyle: tokens.textStyles.bodySmall,
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        GlassButton(
          key: const ValueKey('add-revision-no-btn'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('add-revision-yes-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.prepMockAddToRevisionAction),
        ),
      ],
    );
  }
}
