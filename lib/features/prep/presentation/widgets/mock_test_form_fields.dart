import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';

/// Text and numeric input fields section inside the mock test create/edit form.
class MockTestFormFields extends StatelessWidget {
  /// Creates a [MockTestFormFields].
  const MockTestFormFields({
    required this.titleController,
    required this.sourceController,
    required this.marksObtainedController,
    required this.totalMarksController,
    required this.negativeMarksController,
    required this.timeTakenController,
    required this.timeLimitController,
    required this.weakTopicsController,
    required this.notesController,
    required this.formattedDate,
    required this.isBusy,
    required this.onPickDate,
    super.key,
  });

  /// Controller for required test title.
  final TextEditingController titleController;

  /// Controller for optional guidebook/platform source name.
  final TextEditingController sourceController;

  /// Controller for marks obtained before penalty deduction.
  final TextEditingController marksObtainedController;

  /// Controller for maximum possible marks.
  final TextEditingController totalMarksController;

  /// Controller for optional negative marks penalty.
  final TextEditingController negativeMarksController;

  /// Controller for optional actual duration in minutes.
  final TextEditingController timeTakenController;

  /// Controller for optional time limit in minutes.
  final TextEditingController timeLimitController;

  /// Controller for optional weak topics notes.
  final TextEditingController weakTopicsController;

  /// Controller for optional post-test review notes.
  final TextEditingController notesController;

  /// Localized formatted test date label.
  final String formattedDate;

  /// Disables inputs while saving.
  final bool isBusy;

  /// Opens calendar date picker for test `taken_on`.
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassTextField(
          key: const ValueKey('mock-form-title-field'),
          controller: titleController,
          enabled: !isBusy,
          labelText: l10n.prepMockFormTitleLabel,
          hintText: l10n.prepMockFormTitleHint,
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('mock-form-source-field'),
          controller: sourceController,
          enabled: !isBusy,
          labelText: l10n.prepMockFormSourceLabel,
          hintText: l10n.prepMockFormSourceHint,
        ),
        SizedBox(height: spacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.prepMockFormTakenOnLabel(formattedDate),
                style: tokens.textStyles.bodyMedium,
              ),
            ),
            GlassButton(
              key: const ValueKey('mock-form-date-button'),
              onPressed: isBusy ? null : onPickDate,
              child: Text(l10n.prepMockFormPickDate),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                key: const ValueKey('mock-form-marks-obtained-field'),
                controller: marksObtainedController,
                enabled: !isBusy,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                labelText: l10n.prepMockFormMarksObtainedLabel,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: GlassTextField(
                key: const ValueKey('mock-form-total-marks-field'),
                controller: totalMarksController,
                enabled: !isBusy,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                labelText: l10n.prepMockFormTotalMarksLabel,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('mock-form-negative-marks-field'),
          controller: negativeMarksController,
          enabled: !isBusy,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          labelText: l10n.prepMockFormNegativeMarksLabel,
        ),
        SizedBox(height: spacing.md),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                key: const ValueKey('mock-form-time-taken-field'),
                controller: timeTakenController,
                enabled: !isBusy,
                keyboardType: TextInputType.number,
                labelText: l10n.prepMockFormTimeTakenLabel,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: GlassTextField(
                key: const ValueKey('mock-form-time-limit-field'),
                controller: timeLimitController,
                enabled: !isBusy,
                keyboardType: TextInputType.number,
                labelText: l10n.prepMockFormTimeLimitLabel,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('mock-form-weak-topics-field'),
          controller: weakTopicsController,
          enabled: !isBusy,
          labelText: l10n.prepMockFormWeakTopicsLabel,
          hintText: l10n.prepMockFormWeakTopicsHint,
        ),
        SizedBox(height: spacing.md),
        GlassTextField(
          key: const ValueKey('mock-form-notes-field'),
          controller: notesController,
          enabled: !isBusy,
          maxLines: 3,
          labelText: l10n.prepMockFormNotesLabel,
        ),
      ],
    );
  }
}
