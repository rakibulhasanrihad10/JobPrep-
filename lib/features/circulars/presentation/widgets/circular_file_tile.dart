import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_file_l10n.dart';

/// Solid translucent attachment row displaying file metadata and signed
/// preview, download, and delete controls.
///
/// Never applies `BackdropFilter` on individual list rows.
class CircularFileTile extends ConsumerWidget {
  /// Creates a [CircularFileTile].
  const CircularFileTile({
    required this.file,
    required this.isBusy,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
    super.key,
  });

  /// Attachment metadata record.
  final CircularFile file;

  /// Whether a signed URL or delete request is running for this file.
  final bool isBusy;

  /// Callback opening the preview dialog using a temporary signed URL.
  final VoidCallback onPreview;

  /// Callback downloading/opening the file via a download signed URL.
  final VoidCallback onDownload;

  /// Callback confirming and deleting this attachment.
  final VoidCallback onDelete;

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

    final isPdf = CircularFileValidator.isPdfMimeType(file.mimeType);
    final typeLabel =
        isPdf ? l10n.circularFilesTypePdf : l10n.circularFilesTypeImage;
    final formattedSize = CircularFileL10n.formatFileSize(
      file.sizeBytes,
      l10n,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedDate = file.createdAt != null
        ? AppFormatters.formatDate(
            file.createdAt!.toLocal(),
            locale: locale,
            pattern: 'd MMM yyyy',
            useBanglaDigits: useBanglaDigits,
          )
        : null;

    return Container(
      key: ValueKey('circular-file-tile-${file.id}'),
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.glassFillSolid,
        borderRadius: radii.buttonRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: spacing.insetsAllSm,
            decoration: BoxDecoration(
              color: colors.goldAccentSubtle,
              borderRadius: radii.smRadius,
              border: Border.all(color: colors.glassBorder),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: colors.goldAccent,
              size: spacing.lg,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.labelLarge,
                ),
                SizedBox(height: spacing.xs),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
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
                        typeLabel,
                        style: textStyles.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      formattedSize,
                      style: textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (formattedDate != null)
                      Text(
                        formattedDate,
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          if (isBusy)
            Padding(
              padding: spacing.insetsAllSm,
              child: SizedBox(
                width: spacing.lg,
                height: spacing.lg,
                child: CircularProgressIndicator(
                  strokeWidth: spacing.xxs,
                  color: colors.goldAccent,
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: ValueKey('file-preview-btn-${file.id}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.circularFilesPreviewAction,
                  onPressed: onPreview,
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: colors.goldAccent,
                  ),
                ),
                IconButton(
                  key: ValueKey('file-download-btn-${file.id}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.circularFilesDownloadAction,
                  onPressed: onDownload,
                  icon: Icon(
                    Icons.download_rounded,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  key: ValueKey('file-delete-btn-${file.id}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.circularFilesDeleteAction,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.danger,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
