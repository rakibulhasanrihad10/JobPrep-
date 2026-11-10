import 'dart:typed_data';

import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_cover_repository.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';

/// In-memory fake [MaterialCoverRepository] recording per-user uploads,
/// signed URL requests, and deletions without touching Supabase.
class FakeMaterialCoverRepository implements MaterialCoverRepository {
  /// Creates a [FakeMaterialCoverRepository].
  FakeMaterialCoverRepository({
    this.defaultUserId = 'user-1',
    Map<String, Uint8List>? initialBlobs,
    DateTime Function()? clock,
  })  : _blobs = Map<String, Uint8List>.of(initialBlobs ?? const {}),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final String defaultUserId;
  final Map<String, Uint8List> _blobs;
  final List<String> deletedPaths = <String>[];
  final List<String> requestedSignedPaths = <String>[];
  final DateTime Function() _clock;
  int _counter = 1;

  /// Optional failure injected on the next repository operation.
  PrepFailure? nextError;

  /// Stored in-memory cover blobs keyed by per-user storage path.
  Map<String, Uint8List> get uploadedBlobs => Map.unmodifiable(_blobs);

  @override
  Future<String> uploadCover({
    required String folderKey,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    _consumeError();
    final validationError = MaterialCoverValidator.validateFile(
      fileName: fileName,
      sizeBytes: bytes.length,
    );
    if (validationError != null) {
      throw PrepValidationFailure(code: validationError.name);
    }
    final path = MaterialCoverValidator.buildStoragePath(
      userId: defaultUserId,
      folderKey: folderKey,
      fileName: fileName,
      timestamp: _clock().add(Duration(milliseconds: _counter++)),
    );
    _blobs[path] = Uint8List.fromList(bytes);
    return path;
  }

  @override
  Future<Uri> createSignedCoverUrl(
    String storagePath, {
    Duration expiresIn = const Duration(minutes: 30),
  }) async {
    _consumeError();
    final trimmed = storagePath.trim();
    if (trimmed.isEmpty) {
      throw const PrepNotFoundFailure(code: 'missing_storage_path');
    }
    requestedSignedPaths.add(trimmed);
    return Uri.parse(
      'https://signed.example.test/material-covers/$trimmed'
      '?token=signed-${expiresIn.inSeconds}',
    );
  }

  @override
  Future<void> deleteCover(String storagePath) async {
    _consumeError();
    final trimmed = storagePath.trim();
    if (trimmed.isEmpty) return;
    _blobs.remove(trimmed);
    deletedPaths.add(trimmed);
  }

  void _consumeError() {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
  }
}
