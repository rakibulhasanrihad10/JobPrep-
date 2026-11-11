import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Result returned by [MockTestFormValidator.validateAndBuildDraft].
@immutable
class MockTestFormValidationResult {
  /// Creates a [MockTestFormValidationResult].
  const MockTestFormValidationResult({
    this.draft,
    this.errorMessage,
  });

  /// Validated entity ready to persist when `errorMessage == null`.
  final MockTest? draft;

  /// Localized validation error shown inside the form dialog when invalid.
  final String? errorMessage;
}

/// Pure form input parser and validator for creating/editing a [MockTest].
abstract final class MockTestFormValidator {
  /// Validates form text inputs and builds a [MockTest] draft cleanly.
  static MockTestFormValidationResult validateAndBuildDraft({
    required AppLocalizations l10n,
    required List<Subject> subjects,
    required String? subjectId,
    required String titleRaw,
    required String sourceRaw,
    required DateTime takenOn,
    required String marksObtainedRaw,
    required String totalMarksRaw,
    required String negativeMarksRaw,
    required String timeTakenRaw,
    required String timeLimitRaw,
    required String weakTopicsRaw,
    required String notesRaw,
    String? circularId,
    String? materialId,
    String? topicId,
    MockTest? existing,
  }) {
    final effectiveSubjectId = resolveSubjectId(subjects, subjectId);
    if (effectiveSubjectId == null) {
      return MockTestFormValidationResult(
        errorMessage: l10n.prepMockValidationSubjectRequired,
      );
    }

    final title = titleRaw.trim();
    if (title.isEmpty) {
      return MockTestFormValidationResult(
        errorMessage: l10n.prepMockValidationTitleRequired,
      );
    }

    final totalMarks = _parseDouble(totalMarksRaw);
    if (totalMarks == null || totalMarks.isNaN || totalMarks <= 0) {
      return MockTestFormValidationResult(
        errorMessage: l10n.prepMockValidationTotalPositive,
      );
    }

    final marksObtained = _parseDouble(marksObtainedRaw);
    if (marksObtained == null ||
        marksObtained.isNaN ||
        marksObtained < 0 ||
        marksObtained > totalMarks) {
      return MockTestFormValidationResult(
        errorMessage: l10n.prepMockValidationMarksRange,
      );
    }

    final negTrimmed = negativeMarksRaw.trim();
    final negativeMarks = negTrimmed.isEmpty ? null : _parseDouble(negTrimmed);
    if (negTrimmed.isNotEmpty &&
        (negativeMarks == null ||
            negativeMarks.isNaN ||
            negativeMarks < 0 ||
            negativeMarks > totalMarks)) {
      return MockTestFormValidationResult(
        errorMessage: l10n.prepMockValidationNegativeMarks,
      );
    }

    final takenTrimmed = timeTakenRaw.trim();
    final limitTrimmed = timeLimitRaw.trim();
    final timeTaken = takenTrimmed.isEmpty ? null : _parseInt(takenTrimmed);
    final timeLimit = limitTrimmed.isEmpty ? null : _parseInt(limitTrimmed);
    if ((takenTrimmed.isNotEmpty && (timeTaken == null || timeTaken < 0)) ||
        (limitTrimmed.isNotEmpty && (timeLimit == null || timeLimit <= 0))) {
      return MockTestFormValidationResult(
        errorMessage: l10n.prepMockValidationDuration,
      );
    }

    final source = sourceRaw.trim();
    final weakTopics = weakTopicsRaw.trim();
    final notes = notesRaw.trim();

    final draft = (existing ??
            MockTest(
              subjectId: effectiveSubjectId,
              title: title,
              takenOn: takenOn,
              marksObtained: marksObtained,
              totalMarks: totalMarks,
            ))
        .copyWith(
      subjectId: effectiveSubjectId,
      circularId: circularId,
      materialId: materialId,
      topicId: topicId,
      title: title,
      source: source.isEmpty ? null : source,
      takenOn: takenOn,
      marksObtained: marksObtained,
      totalMarks: totalMarks,
      negativeMarks: negativeMarks,
      timeTakenMinutes: timeTaken,
      timeLimitMinutes: timeLimit,
      weakTopics: weakTopics.isEmpty ? null : weakTopics,
      notes: notes.isEmpty ? null : notes,
    );
    return MockTestFormValidationResult(draft: draft);
  }

  /// Picks [preferredId] when still present in [subjects], else falls back
  /// to the first subject cleanly.
  static String? resolveSubjectId(
    List<Subject> subjects,
    String? preferredId,
  ) {
    if (subjects.isEmpty) return null;
    if (preferredId != null && subjects.any((s) => s.id == preferredId)) {
      return preferredId;
    }
    return subjects.first.id;
  }

  static double? _parseDouble(String raw) {
    final cleaned = AppFormatters.toEnglishDigits(raw.trim());
    if (cleaned.isEmpty) return null;
    final parsed = double.tryParse(cleaned);
    return (parsed == null || !parsed.isFinite) ? double.nan : parsed;
  }

  static int? _parseInt(String raw) {
    final cleaned = AppFormatters.toEnglishDigits(raw.trim());
    return cleaned.isEmpty ? null : int.tryParse(cleaned);
  }
}
