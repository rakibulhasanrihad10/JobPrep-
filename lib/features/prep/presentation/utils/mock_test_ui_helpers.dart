import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';

/// Lookup container translating circular, material, topic, and subject IDs to
/// display titles and semantic colors cleanly.
class MockTestLookupMaps {
  /// Builds lookup maps from loaded Riverpod entities.
  MockTestLookupMaps.fromEntities({
    required List<Subject> subjects,
    required List<Circular> circulars,
    required List<PrepMaterial> materials,
    required List<Topic> topics,
    required AppColorsToken colors,
  })  : subjectsById = {for (final s in subjects) s.id: s},
        subjectColorsById = {
          for (final s in subjects)
            s.id: PrepStyleTokens.resolveSubjectColor(s.color, colors),
        },
        circularTitlesById = {for (final c in circulars) c.id: c.title},
        materialTitlesById = {for (final m in materials) m.id: m.title},
        topicNamesById = {for (final t in topics) t.id: t.name};

  /// Subjects indexed by ID.
  final Map<String, Subject> subjectsById;

  /// Resolved subject semantic colors indexed by subject ID.
  final Map<String, Color> subjectColorsById;

  /// Circular titles indexed by circular ID.
  final Map<String, String> circularTitlesById;

  /// Material titles indexed by material ID.
  final Map<String, String> materialTitlesById;

  /// Topic names indexed by topic ID.
  final Map<String, String> topicNamesById;

  /// Collects loaded topics across subjects referenced by [tests].
  static List<Topic> collectTopicsForTests(
    WidgetRef ref,
    Iterable<MockTest> tests,
  ) {
    final subjectIds = {
      for (final test in tests)
        if (test.topicId != null) test.subjectId,
    };
    return [
      for (final subjectId in subjectIds)
        ...?ref.watch(topicsForSubjectProvider(subjectId)).asData?.value,
    ];
  }
}

/// Prompts for confirmation and deletes [test] if confirmed.
Future<bool> confirmAndDeleteMockTest(
  BuildContext context,
  WidgetRef ref,
  MockTest test,
) async {
  final confirmed = await showGlassDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final tokens = dialogContext.tokens;
      final l10n = dialogContext.l10n;
      return GlassDialog(
        key: const ValueKey('mock-delete-dialog'),
        title: Text(
          l10n.prepMockDeleteTitle,
          style: tokens.textStyles.titleLarge,
        ),
        content: Text(
          l10n.prepMockDeleteBody(test.title),
          style: tokens.textStyles.bodyMedium,
        ),
        actions: [
          GlassButton(
            key: const ValueKey('mock-delete-cancel-button'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.prepCancelButton),
          ),
          GlassButton(
            key: const ValueKey('mock-delete-confirm-button'),
            variant: GlassButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.prepMockDeleteConfirm),
          ),
        ],
      );
    },
  );
  if (confirmed != true) return false;
  return await ref
      .read(mockTestControllerProvider.notifier)
      .deleteTest(test.id);
}
