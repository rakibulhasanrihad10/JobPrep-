import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_mutation_state.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';

/// Controller managing study material CRUD, 600 px cover photo resizing,
/// private bucket upload, and cover cleanup.
class PrepMaterialNotifier extends Notifier<PrepMutationState> {
  @override
  PrepMutationState build() => const PrepMutationState();

  /// Clears transient error and cover validation flags.
  void clearError() {
    state = state.copyWith(
      error: null,
      coverValidationError: null,
      isRawImageTooLarge: false,
    );
  }

  /// Validates a picked cover file and resizes it to max ~600 px width.
  Future<PreparedCoverImageResult?> preparePickedCover(
    PickedMaterialCover picked,
  ) async {
    state = state.copyWith(
      error: null,
      coverValidationError: null,
      isRawImageTooLarge: false,
    );

    final typeError = MaterialCoverValidator.validateFileType(picked.name);
    if (typeError != null) {
      state = state.copyWith(coverValidationError: typeError);
      return null;
    }

    final reportedSize = picked.sizeBytes;
    if (reportedSize != null && reportedSize <= 0) {
      state = state.copyWith(
        coverValidationError: MaterialCoverValidationError.emptyFile,
      );
      return null;
    }
    if (reportedSize != null &&
        reportedSize > MaterialCoverValidator.maxRawImageInputBytes) {
      state = state.copyWith(isRawImageTooLarge: true);
      return null;
    }

    try {
      final rawBytes = await picked.readBytes();
      if (rawBytes.isEmpty) {
        state = state.copyWith(
          coverValidationError: MaterialCoverValidationError.emptyFile,
        );
        return null;
      }
      if (rawBytes.length > MaterialCoverValidator.maxRawImageInputBytes) {
        state = state.copyWith(isRawImageTooLarge: true);
        return null;
      }

      final mimeType = MaterialCoverValidator.resolveMimeType(picked.name)!;
      final resizer = ref.read(materialCoverResizerProvider);
      final prepared = await resizer(
        bytes: rawBytes,
        fileName: picked.name,
        mimeType: mimeType,
        maxWidth: MaterialCoverValidator.targetMaxWidth,
      );

      final finalError = MaterialCoverValidator.validateFile(
        fileName: prepared.fileName,
        sizeBytes: prepared.bytes.length,
      );
      if (finalError != null) {
        state = state.copyWith(coverValidationError: finalError);
        return null;
      }
      return prepared;
    } on PrepFailure catch (error) {
      state = state.copyWith(error: error);
      return null;
    } on Object catch (error) {
      state = state.copyWith(error: error);
      return null;
    }
  }

  /// Creates or updates [PrepMaterial], uploading any [pendingCoverUpload]
  /// into `material-covers`.
  Future<PrepMaterial?> saveMaterial({
    required String subjectId,
    required String title,
    required MaterialKind kind,
    required String unitLabel,
    required int totalUnits,
    PrepMaterial? existing,
    PreparedCoverImageResult? pendingCoverUpload,
    String? coverUrl,
    bool clearCover = false,
  }) async {
    final trimmedUrl = coverUrl?.trim() ?? '';
    final urlValidationError = MaterialCoverValidator.validateCoverUrl(
      trimmedUrl,
    );
    if (pendingCoverUpload == null && urlValidationError != null) {
      state = state.copyWith(coverValidationError: urlValidationError);
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      isUploadingCover: pendingCoverUpload != null,
      activeId: existing?.id ?? subjectId,
      error: null,
      coverValidationError: null,
      isRawImageTooLarge: false,
    );

    final coverRepo = ref.read(materialCoverRepositoryProvider);
    final oldPath = existing?.coverImagePath?.trim();
    String? newlyUploadedPath;

    try {
      var nextCoverPath = existing?.coverImagePath;
      var nextCoverUrl = existing?.coverImageUrl;

      if (pendingCoverUpload != null) {
        final folderKey = (existing?.id.trim().isNotEmpty ?? false)
            ? existing!.id
            : subjectId;
        newlyUploadedPath = await coverRepo.uploadCover(
          folderKey: folderKey,
          fileName: pendingCoverUpload.fileName,
          mimeType: pendingCoverUpload.mimeType,
          bytes: pendingCoverUpload.bytes,
        );
        nextCoverPath = newlyUploadedPath;
        nextCoverUrl = null;
      } else if (trimmedUrl.isNotEmpty) {
        nextCoverPath = null;
        nextCoverUrl = trimmedUrl;
      } else if (clearCover) {
        nextCoverPath = null;
        nextCoverUrl = null;
      }

      state = state.copyWith(isUploadingCover: false);

      final repo = ref.read(materialRepositoryProvider);
      final clampedTotal = totalUnits < 0 ? 0 : totalUnits;
      final saved = existing == null
          ? await repo.createMaterial(
              PrepMaterial(
                subjectId: subjectId,
                title: title.trim(),
                kind: kind,
                unitLabel: unitLabel.trim(),
                totalUnits: clampedTotal,
                coverImagePath: nextCoverPath,
                coverImageUrl: nextCoverUrl,
              ),
            )
          : await repo.updateMaterial(
              existing.copyWith(
                title: title.trim(),
                kind: kind,
                unitLabel: unitLabel.trim(),
                totalUnits: clampedTotal,
                coverImagePath: nextCoverPath,
                coverImageUrl: nextCoverUrl,
              ),
            );

      if (oldPath != null && oldPath.isNotEmpty && oldPath != nextCoverPath) {
        unawaited(coverRepo.deleteCover(oldPath).catchError((_) {}));
        ref.invalidate(materialCoverSignedUrlProvider(oldPath));
      }

      ref
        ..invalidate(allMaterialsProvider)
        ..invalidate(materialsForSubjectProvider(subjectId));
      state = state.copyWith(
        isSubmitting: false,
        isUploadingCover: false,
        activeId: null,
      );
      return saved;
    } on Object catch (error) {
      if (newlyUploadedPath != null && newlyUploadedPath.isNotEmpty) {
        unawaited(coverRepo.deleteCover(newlyUploadedPath).catchError((_) {}));
      }
      state = state.copyWith(
        isSubmitting: false,
        isUploadingCover: false,
        activeId: null,
        error: error,
      );
      return null;
    }
  }

  /// Deletes [material] and best-effort cleans up any uploaded cover file.
  Future<bool> deleteMaterial(PrepMaterial material) async {
    state = state.copyWith(
      isSubmitting: true,
      activeId: material.id,
      error: null,
    );
    try {
      await ref.read(materialRepositoryProvider).deleteMaterial(material.id);
      final path = material.coverImagePath?.trim();
      if (path != null && path.isNotEmpty) {
        unawaited(
          ref
              .read(materialCoverRepositoryProvider)
              .deleteCover(path)
              .catchError((_) {}),
        );
        ref.invalidate(materialCoverSignedUrlProvider(path));
      }
      ref
        ..invalidate(allMaterialsProvider)
        ..invalidate(materialsForSubjectProvider(material.subjectId));
      state = state.copyWith(isSubmitting: false, activeId: null);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        activeId: null,
        error: error,
      );
      return false;
    }
  }
}

/// Provides [PrepMaterialNotifier] for material CRUD and cover uploads.
final NotifierProvider<PrepMaterialNotifier, PrepMutationState>
    prepMaterialControllerProvider =
    NotifierProvider<PrepMaterialNotifier, PrepMutationState>(
  PrepMaterialNotifier.new,
);
