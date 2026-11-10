import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_mutation_state.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_option_chip.dart';

/// Selected cover source mode inside `MaterialFormDialog`.
enum MaterialCoverMode { none, upload, url }

/// Cover image selector, uploader preview, URL input, and live glass
/// initial preview section inside the material form dialog.
class MaterialCoverEditor extends StatelessWidget {
  /// Creates a [MaterialCoverEditor].
  const MaterialCoverEditor({
    required this.titlePreview,
    required this.subjectColor,
    required this.mode,
    required this.urlController,
    required this.mutationState,
    required this.onModeChanged,
    required this.onPickImage,
    super.key,
    this.existingCoverPath,
    this.pendingUpload,
  });

  /// Live material title used for the glass initial placeholder preview.
  final String titlePreview;

  /// Subject color token displayed behind the glass placeholder preview.
  final Color subjectColor;

  /// Active cover selection mode.
  final MaterialCoverMode mode;

  /// Controller for optional pasted external image URL.
  final TextEditingController urlController;

  /// Controller state reporting upload progress and validation errors.
  final PrepMutationState mutationState;

  /// Invoked when the user switches cover mode.
  final ValueChanged<MaterialCoverMode> onModeChanged;

  /// Invoked when the user picks or replaces an uploaded cover photo.
  final VoidCallback onPickImage;

  /// Existing private Storage path on the material being edited, if any.
  final String? existingCoverPath;

  /// Newly picked and resized cover image ready to upload on save.
  final PreparedCoverImageResult? pendingUpload;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final effectivePath =
        mode == MaterialCoverMode.upload && pendingUpload == null
            ? existingCoverPath
            : null;
    final effectiveUrl =
        mode == MaterialCoverMode.url ? urlController.text.trim() : null;

    String? validationMessage;
    if (mutationState.isRawImageTooLarge) {
      validationMessage = PrepL10n.rawImageTooLargeMessage(l10n, locale);
    } else if (mutationState.coverValidationError != null) {
      validationMessage = PrepL10n.coverValidationMessage(
        mutationState.coverValidationError!,
        l10n,
        locale,
      );
    }

    return Container(
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.prepCoverSectionLabel,
            style: tokens.textStyles.labelMedium,
          ),
          SizedBox(height: spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialCoverThumbnail(
                title: titlePreview,
                subjectColor: subjectColor,
                previewBytes: mode == MaterialCoverMode.upload
                    ? pendingUpload?.bytes
                    : null,
                coverImagePath: effectivePath,
                coverImageUrl: effectiveUrl,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xs,
                      children: [
                        _buildModeChip(
                          context,
                          modeValue: MaterialCoverMode.none,
                          label: l10n.prepCoverModeNone,
                        ),
                        _buildModeChip(
                          context,
                          modeValue: MaterialCoverMode.upload,
                          label: l10n.prepCoverModeUpload,
                        ),
                        _buildModeChip(
                          context,
                          modeValue: MaterialCoverMode.url,
                          label: l10n.prepCoverModeUrl,
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    if (mode == MaterialCoverMode.none)
                      Text(
                        l10n.prepCoverPlaceholderHint,
                        style: tokens.textStyles.bodySmall,
                      ),
                    if (mode == MaterialCoverMode.upload) ...[
                      GlassButton(
                        key: const ValueKey('material-pick-cover-button'),
                        leading: Icon(
                          Icons.photo_library_outlined,
                          size: spacing.lg,
                          color: colors.goldAccent,
                        ),
                        onPressed: mutationState.isBusy ? null : onPickImage,
                        child: Text(
                          pendingUpload != null ||
                                  (existingCoverPath?.isNotEmpty ?? false)
                              ? l10n.prepCoverReplaceButton
                              : l10n.prepCoverPickButton,
                        ),
                      ),
                      if (pendingUpload != null) ...[
                        SizedBox(height: spacing.xs),
                        Text(
                          l10n.prepCoverResizedNote(
                            PrepL10n.formatInt(pendingUpload!.width, locale),
                          ),
                          style: tokens.textStyles.bodySmall.copyWith(
                            color: colors.success,
                          ),
                        ),
                      ],
                    ],
                    if (mode == MaterialCoverMode.url)
                      GlassTextField(
                        key: const ValueKey('material-cover-url-field'),
                        controller: urlController,
                        labelText: l10n.prepCoverUrlLabel,
                        hintText: l10n.prepCoverUrlHint,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (mode != MaterialCoverMode.url) return null;
                          final err = MaterialCoverValidator.validateCoverUrl(
                            value,
                          );
                          if (err == null) return null;
                          return PrepL10n.coverValidationMessage(
                            err,
                            l10n,
                            locale,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (mutationState.isUploadingCover) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.prepCoverUploadProgress,
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.goldAccent,
              ),
            ),
            SizedBox(height: spacing.xs),
            LinearProgressIndicator(
              color: colors.goldAccent,
              backgroundColor: colors.glassFillSolid,
            ),
          ],
          if (validationMessage != null) ...[
            SizedBox(height: spacing.sm),
            Text(
              validationMessage,
              key: const ValueKey('material-cover-error'),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeChip(
    BuildContext context, {
    required MaterialCoverMode modeValue,
    required String label,
  }) {
    return PrepOptionChip(
      key: ValueKey('material-cover-mode-${modeValue.name}'),
      label: label,
      isSelected: mode == modeValue,
      useElevatedUnselectedFill: false,
      onTap: mutationState.isBusy ? null : () => onModeChanged(modeValue),
    );
  }
}
