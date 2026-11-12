import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

/// Optional attachment dropdowns (Circular, Material, Topic) inside the mock
/// test create/edit form dialog.
class MockTestAttachmentFields extends ConsumerWidget {
  /// Creates a [MockTestAttachmentFields].
  const MockTestAttachmentFields({
    required this.selectedSubjectId,
    required this.selectedCircularId,
    required this.selectedMaterialId,
    required this.selectedTopicId,
    required this.isBusy,
    required this.onCircularChanged,
    required this.onMaterialChanged,
    required this.onTopicChanged,
    super.key,
  });

  /// Currently chosen parent subject identifier (used to scope materials/topics).
  final String? selectedSubjectId;

  /// Selected circular ID, if any.
  final String? selectedCircularId;

  /// Selected study material ID, if any.
  final String? selectedMaterialId;

  /// Selected syllabus topic ID, if any.
  final String? selectedTopicId;

  /// Disables inputs while saving.
  final bool isBusy;

  /// Callback invoked when the circular selection changes.
  final ValueChanged<String?> onCircularChanged;

  /// Callback invoked when the material selection changes.
  final ValueChanged<String?> onMaterialChanged;

  /// Callback invoked when the topic selection changes.
  final ValueChanged<String?> onTopicChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final circulars =
        ref.watch(circularsListProvider).asData?.value ?? const <Circular>[];
    final allMaterials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final subjectId = selectedSubjectId?.trim() ?? '';
    final materials = subjectId.isEmpty
        ? const <PrepMaterial>[]
        : allMaterials
            .where((m) => m.subjectId == subjectId)
            .toList(growable: false);
    final topics = subjectId.isEmpty
        ? const <Topic>[]
        : ref.watch(topicsForSubjectProvider(subjectId)).asData?.value ??
            const <Topic>[];

    final effectiveCircularId = circulars.any((c) => c.id == selectedCircularId)
        ? selectedCircularId
        : null;
    final effectiveMaterialId = materials.any((m) => m.id == selectedMaterialId)
        ? selectedMaterialId
        : null;
    final effectiveTopicId =
        topics.any((t) => t.id == selectedTopicId) ? selectedTopicId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (circulars.isNotEmpty) ...[
          Text(
            l10n.prepMockFormCircularLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.xs),
          DropdownButtonFormField<String?>(
            key: const ValueKey('mock-form-circular-dropdown'),
            initialValue: effectiveCircularId,
            isExpanded: true,
            items: [
              DropdownMenuItem<String?>(
                child: Text(l10n.prepMockFormNoneOption),
              ),
              for (final c in circulars)
                DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text(c.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: isBusy ? null : onCircularChanged,
          ),
          SizedBox(height: spacing.md),
        ],
        if (materials.isNotEmpty) ...[
          Text(
            l10n.prepMockFormMaterialLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.xs),
          DropdownButtonFormField<String?>(
            key: const ValueKey('mock-form-material-dropdown'),
            initialValue: effectiveMaterialId,
            isExpanded: true,
            items: [
              DropdownMenuItem<String?>(
                child: Text(l10n.prepMockFormNoneOption),
              ),
              for (final m in materials)
                DropdownMenuItem<String?>(
                  value: m.id,
                  child: Text(m.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: isBusy ? null : onMaterialChanged,
          ),
          SizedBox(height: spacing.md),
        ],
        if (topics.isNotEmpty) ...[
          Text(
            l10n.prepMockFormTopicLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.xs),
          DropdownButtonFormField<String?>(
            key: const ValueKey('mock-form-topic-dropdown'),
            initialValue: effectiveTopicId,
            isExpanded: true,
            items: [
              DropdownMenuItem<String?>(
                child: Text(l10n.prepMockFormNoneOption),
              ),
              for (final t in topics)
                DropdownMenuItem<String?>(
                  value: t.id,
                  child: Text(t.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: isBusy ? null : onTopicChanged,
          ),
        ],
      ],
    );
  }
}
