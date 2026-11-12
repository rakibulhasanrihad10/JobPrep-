import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_chip.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/presentation/utils/revision_l10n.dart';

/// Quick-fill weak-topic chips and "Add all" control rendered inside
/// `RevisionFlagComposer` when flagging from mock test results.
class RevisionWeakTopicSuggestionsRow extends StatelessWidget {
  /// Creates a [RevisionWeakTopicSuggestionsRow].
  const RevisionWeakTopicSuggestionsRow({
    required this.suggestions,
    required this.currentText,
    required this.isBusy,
    required this.locale,
    required this.useBanglaDigits,
    required this.onSelectSuggestion,
    required this.onAddAll,
    super.key,
  });

  /// Weak topic labels extracted from a mock test.
  final List<String> suggestions;

  /// Current trimmed value in the reference input box.
  final String currentText;

  /// Disables actions while saving.
  final bool isBusy;

  /// Active locale for formatting the batch count.
  final Locale locale;

  /// Whether Bangla numerals are active.
  final bool useBanglaDigits;

  /// Copies the tapped suggestion into the reference field.
  final ValueChanged<String> onSelectSuggestion;

  /// Batch-adds all suggestions cleanly.
  final VoidCallback onAddAll;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.prepRevisionWeakTopicsQuickFill,
          style: tokens.textStyles.bodySmall,
        ),
        for (final suggestion in suggestions)
          GlassChip(
            key: ValueKey('revision-weak-chip-$suggestion'),
            label: Text(suggestion),
            isSelected: currentText == suggestion,
            onTap: isBusy ? null : () => onSelectSuggestion(suggestion),
          ),
        if (suggestions.length > 1)
          GlassButton(
            key: const ValueKey('revision-add-all-weak-topics-button'),
            onPressed: isBusy ? null : onAddAll,
            child: Text(
              l10n.prepRevisionAddAllWeakTopics(
                AppFormatters.formatNumber(
                  suggestions.length,
                  locale: locale,
                  useBanglaDigits: useBanglaDigits,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Summary pill and chips listing revision items flagged in the current
/// session without leaving the active logging dialog.
class RevisionSessionAddedSummary extends StatelessWidget {
  /// Creates a [RevisionSessionAddedSummary].
  const RevisionSessionAddedSummary({
    required this.addedItems,
    required this.locale,
    required this.useBanglaDigits,
    super.key,
  });

  /// Revision marks added during this dialog session.
  final List<RevisionItem> addedItems;

  /// Active locale for formatting counts.
  final Locale locale;

  /// Whether Bangla numerals are enabled.
  final bool useBanglaDigits;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        for (final added in addedItems)
          GlassChip(
            label: Text(
              '${added.referenceLabel} '
              '(${RevisionL10n.reasonLabel(added.reason, l10n)})',
            ),
          ),
      ],
    );
  }
}
