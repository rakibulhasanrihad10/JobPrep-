import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_planner.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Localization, formatted number, and suggestion helpers for Preparation UI.
abstract final class PrepL10n {
  /// Localized display label for a [MaterialKind].
  static String materialKindLabel(MaterialKind kind, AppLocalizations l10n) {
    return switch (kind) {
      MaterialKind.book => l10n.prepMaterialKindBook,
      MaterialKind.videoCourse => l10n.prepMaterialKindVideoCourse,
      MaterialKind.lectureSheet => l10n.prepMaterialKindLectureSheet,
      MaterialKind.questionBank => l10n.prepMaterialKindQuestionBank,
      MaterialKind.notes => l10n.prepMaterialKindNotes,
      MaterialKind.mockTest => l10n.prepMaterialKindMockTest,
      MaterialKind.other => l10n.prepMaterialKindOther,
    };
  }

  /// Localized validation error message for cover file uploads or URLs.
  static String coverValidationMessage(
    MaterialCoverValidationError error,
    AppLocalizations l10n,
    Locale locale,
  ) {
    final maxMb = AppFormatters.formatNumber(
      MaterialCoverValidator.maxCoverFileSizeBytes ~/ (1024 * 1024),
      locale: locale,
    );
    return switch (error) {
      MaterialCoverValidationError.unsupportedType =>
        l10n.prepCoverErrorUnsupportedType,
      MaterialCoverValidationError.emptyFile => l10n.prepCoverErrorEmptyFile,
      MaterialCoverValidationError.fileTooLarge =>
        l10n.prepCoverErrorTooLarge('$maxMb MB'),
      MaterialCoverValidationError.invalidUrl => l10n.prepCoverErrorInvalidUrl,
    };
  }

  /// Localized error message when a raw cover photo exceeds the pre-resize
  /// browser safety limit.
  static String rawImageTooLargeMessage(
    AppLocalizations l10n,
    Locale locale,
  ) {
    final maxMb = AppFormatters.formatNumber(
      MaterialCoverValidator.maxRawImageInputBytes ~/ (1024 * 1024),
      locale: locale,
    );
    return l10n.prepCoverErrorRawTooLarge('$maxMb MB');
  }

  /// Maps a domain [PrepFailure] or arbitrary error into a localized message.
  static String failureMessage(Object error, AppLocalizations l10n) {
    if (error is PrepValidationFailure) {
      if (error.code == MaterialCoverValidationError.unsupportedType.name) {
        return l10n.prepCoverErrorUnsupportedType;
      }
      if (error.code == MaterialCoverValidationError.emptyFile.name) {
        return l10n.prepCoverErrorEmptyFile;
      }
      if (error.code == MaterialCoverValidationError.invalidUrl.name) {
        return l10n.prepCoverErrorInvalidUrl;
      }
    }
    return switch (error) {
      PrepPermissionFailure() => l10n.prepErrorPermission,
      PrepNetworkFailure() => l10n.prepErrorNetwork,
      PrepNotFoundFailure() => l10n.prepErrorNotFound,
      _ => l10n.prepErrorUnknown,
    };
  }

  /// Formats an integer with localized numerals (e.g. Bangla digits for `bn`).
  static String formatInt(int value, Locale locale) {
    return AppFormatters.formatNumber(value, locale: locale);
  }

  /// Formats a `[0..1]` progress fraction as a rounded percentage string.
  static String formatPercent(double progressFraction, Locale locale) {
    final clamped = progressFraction.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();
    return AppFormatters.formatNumber(percent, locale: locale);
  }

  /// Quick-select suggestions for exam or career tracks (users may type any
  /// custom career track as well).
  static List<String> examTrackSuggestions(AppLocalizations l10n) {
    return <String>[
      l10n.prepExamTrackGeneral,
      l10n.prepExamTrackBcs,
      l10n.prepExamTrackBank,
      l10n.prepExamTrackGovt,
      l10n.prepExamTrackMedical,
      l10n.prepExamTrackEngineering,
      l10n.prepExamTrackIelts,
    ];
  }

  /// Quick-select unit label suggestions (users may type any custom label).
  static List<String> unitLabelSuggestions(AppLocalizations l10n) {
    return <String>[
      l10n.prepUnitPresetPages,
      l10n.prepUnitPresetChapters,
      l10n.prepUnitPresetLectures,
      l10n.prepUnitPresetVideos,
      l10n.prepUnitPresetQuestions,
      l10n.prepUnitPresetTests,
    ];
  }

  /// Localized display title for a seeded system [template] or raw user title.
  static String templateTitle(PrepTemplate template, AppLocalizations l10n) {
    return switch (template.slug) {
      'government_job' => l10n.prepSeededGovJobTitle,
      'software_engineer' => l10n.prepSeededSweTitle,
      _ => template.title,
    };
  }

  /// Localized summary for a seeded system [template] or stored description.
  static String templateDescription(
    PrepTemplate template,
    AppLocalizations l10n,
  ) {
    return switch (template.slug) {
      'government_job' => l10n.prepSeededGovJobSubtitle,
      'software_engineer' => l10n.prepSeededSweSubtitle,
      _ => template.description ?? '',
    };
  }

  /// Localized snackbar summary emitted after applying a template pack.
  static String applyResultMessage(
    PrepTemplateApplyResult result,
    PrepTemplate template,
    AppLocalizations l10n,
    Locale locale,
  ) {
    final title = templateTitle(template, l10n);
    if (result.alreadyApplied) {
      return l10n.prepTemplateAlreadyAppliedSnackbar(title);
    }
    return l10n.prepTemplateAppliedSnackbar(
      result.subjectsCreated,
      formatInt(result.subjectsCreated, locale),
      result.materialsCreated,
      formatInt(result.materialsCreated, locale),
      title,
    );
  }
}
