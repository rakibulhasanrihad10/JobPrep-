import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Weak topics selector allowing picking from syllabus topics with
/// free-text fallback.
class MockTestWeakTopicsField extends StatelessWidget {
  /// Creates a [MockTestWeakTopicsField].
  const MockTestWeakTopicsField({
    required this.controller,
    required this.syllabusTopics,
    required this.selectedWeakTopicIds,
    required this.onToggleWeakTopic,
    required this.isBusy,
    super.key,
  });

  /// Text controller for free-text weak topics notes.
  final TextEditingController controller;

  /// Topics available from the active subject's syllabus.
  final List<Topic> syllabusTopics;

  /// Set of topic IDs marked as weak from the syllabus.
  final Set<String> selectedWeakTopicIds;

  /// Callback when a syllabus topic is toggled.
  final ValueChanged<Topic> onToggleWeakTopic;

  /// Disables inputs when busy.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.prepMockFormWeakTopicsLabel,
          style: tokens.textStyles.labelLarge,
        ),
        if (syllabusTopics.isNotEmpty) ...[
          SizedBox(height: spacing.xs),
          Text(
            l10n.prepMockWeakTopicsSyllabusLabel,
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.xs),
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: syllabusTopics.map((topic) {
              final isSelected = selectedWeakTopicIds.contains(topic.id);
              return FilterChip(
                key: ValueKey('weak-topic-chip-${topic.id}'),
                label: Text(topic.title),
                selected: isSelected,
                selectedColor: colors.warning.withValues(alpha: 0.25),
                checkmarkColor: colors.warning,
                labelStyle: tokens.textStyles.bodySmall.copyWith(
                  color: isSelected ? colors.warning : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: isBusy ? null : (_) => onToggleWeakTopic(topic),
              );
            }).toList(),
          ),
          SizedBox(height: spacing.sm),
        ],
        GlassTextField(
          key: const ValueKey('mock-form-weak-topics-field'),
          controller: controller,
          enabled: !isBusy,
          labelText: l10n.prepMockFormWeakTopicsFallbackLabel,
          hintText: l10n.prepMockFormWeakTopicsHint,
        ),
      ],
    );
  }
}
