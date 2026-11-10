import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_files_state.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Typed validation error key plus optional byte limit context for UI mapping.
enum CircularFileUiErrorKind {
  validation,
  rawImageTooLarge,
  openSignedUrlFailed,
}

/// Localization and locale-aware size/count formatting helpers for circular
/// attachments.
abstract final class CircularFileL10n {
  /// Formats [sizeBytes] using localized units (`B`, `KB`, `MB`) and numerals.
  static String formatFileSize(
    int sizeBytes,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final safeBytes = sizeBytes < 0 ? 0 : sizeBytes;
    const kb = 1024;
    const mb = 1024 * 1024;

    if (safeBytes < kb) {
      final count = AppFormatters.formatNumber(
        safeBytes,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
      );
      return l10n.circularFilesSizeBytes(count);
    }

    if (safeBytes < mb) {
      final value = safeBytes / kb;
      final isWhole = safeBytes % kb == 0;
      final count = AppFormatters.formatNumber(
        isWhole ? value.round() : value,
        locale: locale,
        useBanglaDigits: useBanglaDigits,
        decimalDigits: isWhole ? null : 1,
      );
      return l10n.circularFilesSizeKb(count);
    }

    final value = safeBytes / mb;
    final isWhole = safeBytes % mb == 0;
    final count = AppFormatters.formatNumber(
      isWhole ? value.round() : value,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: isWhole ? null : 1,
    );
    return l10n.circularFilesSizeMb(count);
  }

  /// Formats attachment [count] with localized numerals and plural grammar.
  static String formatFileCount(
    int count,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final formatted = AppFormatters.formatNumber(
      count,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.circularFilesCount(count, formatted);
  }

  /// Localized message for [error].
  static String validationMessage(
    CircularFileValidationError error,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final maxSize = formatFileSize(
      CircularFileValidator.maxCircularFileSizeBytes,
      l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return switch (error) {
      CircularFileValidationError.unsupportedType =>
        l10n.circularFilesErrorUnsupportedType,
      CircularFileValidationError.emptyFile => l10n.circularFilesErrorEmptyFile,
      CircularFileValidationError.fileTooLarge =>
        l10n.circularFilesErrorFileTooLarge(maxSize),
    };
  }

  /// Localized message when a raw image exceeds
  /// [CircularFileValidator.maxRawImageInputBytes].
  static String rawImageTooLargeMessage(
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final maxRaw = formatFileSize(
      CircularFileValidator.maxRawImageInputBytes,
      l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return l10n.circularFilesErrorRawImageTooLarge(maxRaw);
  }

  /// Resolves any [CircularFilesUiError] into a localized message.
  static String uiErrorMessage(
    CircularFilesUiError error,
    AppLocalizations l10n, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    return switch (error) {
      CircularFilesValidationUiError(:final validationError) =>
        validationMessage(
          validationError,
          l10n,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        ),
      CircularFilesRawImageTooLargeUiError() => rawImageTooLargeMessage(
          l10n,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        ),
      CircularFilesOpenSignedLinkUiError() =>
        l10n.circularFilesErrorOpenLinkFailed,
      CircularFilesFailureUiError(:final failure) =>
        CircularL10n.circularErrorMessage(failure, l10n),
    };
  }
}
