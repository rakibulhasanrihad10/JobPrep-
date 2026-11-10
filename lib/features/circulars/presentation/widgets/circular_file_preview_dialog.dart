import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_file_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_files_controller.dart';

/// Opens a frosted glass preview dialog backed by a temporary [signedUri].
Future<void> showCircularFilePreviewDialog(
  BuildContext context, {
  required CircularFile file,
  required Uri signedUri,
}) {
  return showGlassDialog<void>(
    context: context,
    builder: (dialogContext) => CircularFilePreviewDialog(
      file: file,
      signedUri: signedUri,
    ),
  );
}

/// Modal preview dialog for an uploaded image or PDF using a private signed
/// Storage URL (never a public bucket URL).
class CircularFilePreviewDialog extends ConsumerWidget {
  /// Creates a [CircularFilePreviewDialog].
  const CircularFilePreviewDialog({
    required this.file,
    required this.signedUri,
    super.key,
  });

  /// Attachment record being previewed.
  final CircularFile file;

  /// Short-lived signed URL returned by Supabase Storage.
  final Uri signedUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final controller = ref.read(circularFilesControllerProvider.notifier);
    final customImageBuilder = ref.watch(circularPreviewImageBuilderProvider);
    final isImage = CircularFileValidator.isImageMimeType(file.mimeType);

    void openExternally() {
      unawaited(controller.openSignedUri(file.circularId, signedUri));
    }

    Widget buildFallbackBox(String message) {
      return Container(
        padding: spacing.insetsAllLg,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radii.buttonRadius,
          border: Border.all(color: colors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              color: colors.goldAccent,
              size: spacing.xxl,
            ),
            SizedBox(height: spacing.md),
            Text(
              file.fileName,
              textAlign: TextAlign.center,
              style: textStyles.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBodyContent() {
      if (!isImage) {
        return buildFallbackBox(l10n.circularFilesPreviewPdfMessage);
      }
      if (customImageBuilder != null) {
        return ClipRRect(
          borderRadius: radii.buttonRadius,
          child: customImageBuilder(context, signedUri),
        );
      }
      return ClipRRect(
        borderRadius: radii.buttonRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: spacing.xxxl * 6),
          child: InteractiveViewer(
            child: Image.network(
              signedUri.toString(),
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Padding(
                  padding: spacing.insetsAllXl,
                  child: Center(
                    child: CircularProgressIndicator(color: colors.goldAccent),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return buildFallbackBox(l10n.circularFilesPreviewLoadError);
              },
            ),
          ),
        ),
      );
    }

    return GlassDialog(
      key: const ValueKey('circular-file-preview-dialog'),
      maxWidth: spacing.xxxl * 12,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.circularFilesPreviewTitle),
          SizedBox(height: spacing.xs),
          Text(
            file.fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyles.labelLarge.copyWith(color: colors.goldAccent),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildBodyContent(),
            SizedBox(height: spacing.md),
            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: spacing.lg,
                  color: colors.textMuted,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    l10n.circularFilesSignedUrlSecurityNote,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('preview-open-signed-link-btn'),
          onPressed: openExternally,
          leading: Icon(Icons.open_in_new_rounded, size: spacing.lg),
          child: Text(l10n.circularFilesOpenSignedLink),
        ),
        GlassButton(
          key: const ValueKey('preview-download-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: () => unawaited(controller.downloadFile(file)),
          leading: Icon(Icons.download_rounded, size: spacing.lg),
          child: Text(l10n.circularFilesDownloadAction),
        ),
        GlassButton(
          key: const ValueKey('preview-close-btn'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.circularFilesCloseAction),
        ),
      ],
    );
  }
}

/// Shows a glassmorphic confirmation dialog before deleting an attachment
/// [file].
Future<bool> showDeleteCircularFileDialog(
  BuildContext context,
  CircularFile file,
) async {
  final l10n = context.l10n;
  final colors = context.tokens.colors;
  final confirmed = await showGlassDialog<bool>(
    context: context,
    builder: (dialogContext) => GlassDialog(
      key: const ValueKey('circular-file-delete-dialog'),
      title: Text(l10n.circularFilesDeleteConfirmTitle),
      content: Text(l10n.circularFilesDeleteConfirmBody(file.fileName)),
      actions: [
        GlassButton(
          key: const ValueKey('file-delete-cancel-btn'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.circularFilesCancelAction),
        ),
        GlassButton(
          key: const ValueKey('file-delete-confirm-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            l10n.circularFilesConfirmDeleteAction,
            style: context.tokens.textStyles.labelLarge.copyWith(
              color: colors.danger,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
