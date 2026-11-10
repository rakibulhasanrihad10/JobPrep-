import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_file_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_files_controller.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_file_l10n.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_file_preview_dialog.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_file_tile.dart';

/// Displays and manages private file attachments (`public.circular_files` +
/// private Storage bucket `circular-files`) on the circular detail screen.
class CircularFilesSection extends ConsumerWidget {
  /// Creates a [CircularFilesSection].
  const CircularFilesSection({
    required this.circular,
    super.key,
  });

  /// Parent circular whose attachments are displayed.
  final Circular circular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final fileRepo = ref.watch(circularFileRepositoryProvider);
    final filesAsync = ref.watch(circularFilesProvider(circular.id));
    final actionState =
        ref.watch(circularFilesActionStateProvider(circular.id));
    final controller = ref.read(circularFilesControllerProvider.notifier);

    final maxSizeLabel = CircularFileL10n.formatFileSize(
      CircularFileValidator.maxCircularFileSizeBytes,
      l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    final effectiveListForCount = switch (filesAsync) {
      AsyncData<List<CircularFile>>(:final value) =>
        value.isNotEmpty || fileRepo is! UnconfiguredCircularFileRepository
            ? value
            : circular.files,
      _ => circular.files,
    };

    Future<void> handlePreview(CircularFile file) async {
      final signedUri = await controller.createSignedPreviewUrl(file);
      if (signedUri == null || !context.mounted) return;
      await showCircularFilePreviewDialog(
        context,
        file: file,
        signedUri: signedUri,
      );
    }

    Future<void> handleDelete(CircularFile file) async {
      final confirmed = await showDeleteCircularFileDialog(context, file);
      if (!confirmed || !context.mounted) return;
      await controller.deleteFile(file);
    }

    return GlassCard(
      key: const ValueKey('circular-detail-files-card'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: colors.goldAccent,
                      size: spacing.lg,
                    ),
                    Text(
                      l10n.circularFilesTitle,
                      style: textStyles.titleMedium,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: radii.smRadius,
                        border: Border.all(color: colors.glassBorder),
                      ),
                      child: Text(
                        CircularFileL10n.formatFileCount(
                          effectiveListForCount.length,
                          l10n,
                          locale: locale,
                          useBanglaDigits: useBanglaDigits,
                        ),
                        style: textStyles.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                GlassButton(
                  key: const ValueKey('detail-upload-file-btn'),
                  variant: GlassButtonVariant.primary,
                  onPressed: actionState.isUploading
                      ? null
                      : () => unawaited(
                            controller.pickAndUploadFile(circular.id),
                          ),
                  leading: Icon(Icons.upload_file_rounded, size: spacing.lg),
                  child: Text(l10n.circularFilesUploadButton),
                ),
              ],
            ),
            SizedBox(height: spacing.xs),
            Text(
              l10n.circularFilesAllowedHelper(maxSizeLabel),
              style: textStyles.bodySmall.copyWith(color: colors.textMuted),
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            if (actionState.isUploading) ...[
              Container(
                key: const ValueKey('file-upload-progress-box'),
                margin: EdgeInsets.only(bottom: spacing.md),
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: radii.buttonRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.circularFilesUploading(
                        actionState.uploadingFileName ?? '',
                        AppFormatters.formatNumber(
                          (actionState.uploadProgress * 100).round(),
                          locale: locale,
                          useBanglaDigits: useBanglaDigits,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing.sm),
                    AnimatedProgressBar(
                      key: const ValueKey('file-upload-progress-bar'),
                      value: actionState.uploadProgress,
                    ),
                  ],
                ),
              ),
            ],
            if (actionState.error != null) ...[
              Container(
                key: const ValueKey('circular-files-error-banner'),
                margin: EdgeInsets.only(bottom: spacing.md),
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.14),
                  borderRadius: radii.buttonRadius,
                  border: Border.all(
                    color: colors.danger.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        CircularFileL10n.uiErrorMessage(
                          actionState.error!,
                          l10n,
                          locale: locale,
                          useBanglaDigits: useBanglaDigits,
                        ),
                        style: textStyles.bodySmall.copyWith(
                          color: colors.danger,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('circular-files-error-dismiss-btn'),
                      tooltip: l10n.circularFilesCloseAction,
                      onPressed: () => controller.clearError(circular.id),
                      icon: Icon(Icons.close_rounded, color: colors.danger),
                    ),
                  ],
                ),
              ),
            ],
            filesAsync.when(
              loading: () => Center(
                child: Padding(
                  padding: spacing.insetsAllMd,
                  child: CircularProgressIndicator(color: colors.goldAccent),
                ),
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.circularFilesLoadError} '
                    '${CircularL10n.circularErrorMessage(error, l10n)}',
                    style: textStyles.bodySmall.copyWith(color: colors.danger),
                  ),
                  SizedBox(height: spacing.sm),
                  GlassButton(
                    key: const ValueKey('circular-files-retry-btn'),
                    onPressed: () => ref.invalidate(
                      circularFilesProvider(circular.id),
                    ),
                    child: Text(l10n.circularFilesRetry),
                  ),
                ],
              ),
              data: (fetchedFiles) {
                final effectiveFiles = fetchedFiles.isNotEmpty ||
                        fileRepo is! UnconfiguredCircularFileRepository
                    ? fetchedFiles
                    : circular.files;

                if (effectiveFiles.isEmpty) {
                  return Text(
                    l10n.circularFilesEmpty,
                    key: const ValueKey('circular-files-empty-text'),
                    style: textStyles.bodyMedium.copyWith(
                      color: colors.textMuted,
                    ),
                  );
                }

                return Column(
                  key: const ValueKey('circular-files-list'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final file in effectiveFiles)
                      CircularFileTile(
                        file: file,
                        isBusy: actionState.busyFileId == file.id,
                        onPreview: () => unawaited(handlePreview(file)),
                        onDownload: () => unawaited(
                          controller.downloadFile(file),
                        ),
                        onDelete: () => unawaited(handleDelete(file)),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
