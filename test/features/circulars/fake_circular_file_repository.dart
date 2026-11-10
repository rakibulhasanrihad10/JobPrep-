import 'dart:async';
import 'dart:typed_data';

import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';

/// Recorded signed URL generation request inside [FakeCircularFileRepository].
typedef SignedUrlRequest = ({
  CircularFile file,
  Duration expiresIn,
  bool download,
});

/// In-memory fake [CircularFileRepository] isolating storage paths, signed URL
/// creation, upload progress emission, and error injection for unit/widget
/// tests.
class FakeCircularFileRepository implements CircularFileRepository {
  /// Creates a [FakeCircularFileRepository].
  FakeCircularFileRepository({
    List<CircularFile> initialFiles = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
    this.progressDelay,
  })  : _files = List<CircularFile>.of(initialFiles),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 10, 12));

  final List<CircularFile> _files;
  final Map<String, Uint8List> _blobs = <String, Uint8List>{};
  final String defaultUserId;
  final DateTime Function() _clock;

  /// Optional delay between progress emissions so listeners can observe each
  /// discrete upload step in pure unit tests.
  final Duration? progressDelay;
  int _nextId = 1;
  int _tokenCounter = 1;

  /// Optional failure thrown on the next repository call when non-null.
  CircularFailure? nextError;

  /// Optional gate pausing upload at progress `0.45` so UI tests can assert
  /// the active progress state deterministically before completing it.
  Completer<void>? pendingUploadGate;

  /// Recorded operations for assertions.
  int fetchCalls = 0;
  final List<CircularFile> uploadedFiles = <CircularFile>[];
  final List<SignedUrlRequest> signedUrlRequests = <SignedUrlRequest>[];
  final List<CircularFile> deletedFiles = <CircularFile>[];

  /// Snapshot of stored attachment metadata.
  List<CircularFile> get files => List.unmodifiable(_files);

  /// Snapshot of stored object bytes keyed by Storage path.
  Map<String, Uint8List> get blobs => Map.unmodifiable(_blobs);

  @override
  Future<List<CircularFile>> getFilesForCircular(String circularId) async {
    fetchCalls += 1;
    _consumeNextErrorIfAny();

    final matching = _files
        .where((file) => file.circularId == circularId)
        .toList()
      ..sort((a, b) {
        final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bCreated.compareTo(aCreated);
      });
    return List.unmodifiable(matching);
  }

  @override
  Future<CircularFile> uploadFile({
    required String circularId,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) async {
    _consumeNextErrorIfAny();

    final validation = CircularFileValidator.validateFile(
      fileName: fileName,
      sizeBytes: bytes.length,
    );
    if (validation != null) {
      throw CircularValidationFailure(
        code: validation.name,
        message: 'Invalid upload payload ($validation)',
      );
    }

    await _emitProgress(onProgress, 0.15);
    if (pendingUploadGate != null && !pendingUploadGate!.isCompleted) {
      await _emitProgress(onProgress, 0.45);
      await pendingUploadGate!.future;
      _consumeNextErrorIfAny();
    }
    await _emitProgress(onProgress, 0.75);

    final timestamp = _clock().toUtc();
    final safeName = CircularFileValidator.sanitizeFileName(fileName);
    final storagePath = CircularFileValidator.buildStoragePath(
      userId: defaultUserId,
      circularId: circularId,
      fileName: safeName,
      timestampMs: timestamp.millisecondsSinceEpoch + _nextId,
    );

    final created = CircularFile(
      id: 'file-${_nextId++}',
      circularId: circularId,
      userId: defaultUserId,
      storagePath: storagePath,
      fileName: safeName,
      mimeType: mimeType.trim(),
      sizeBytes: bytes.length,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    _blobs[storagePath] = Uint8List.fromList(bytes);
    _files.insert(0, created);
    uploadedFiles.add(created);
    await _emitProgress(onProgress, 1);
    return created;
  }

  Future<void> _emitProgress(
    void Function(double progress)? onProgress,
    double value,
  ) async {
    onProgress?.call(value);
    if (progressDelay != null) {
      await Future<void>.delayed(progressDelay!);
    } else {
      await Future<void>.value();
    }
  }

  @override
  Future<Uri> createSignedUrl(
    CircularFile file, {
    Duration expiresIn = const Duration(minutes: 10),
    bool download = false,
  }) async {
    _consumeNextErrorIfAny();

    if (file.userId.isNotEmpty && file.userId != defaultUserId) {
      throw const CircularPermissionFailure(
        code: '403',
        message: 'Cannot sign another user storage object.',
      );
    }

    signedUrlRequests.add(
      (file: file, expiresIn: expiresIn, download: download),
    );

    final query = <String, String>{
      'token': 'signed-token-${_tokenCounter++}',
      'expiresIn': '${expiresIn.inSeconds}',
      if (download) 'download': file.fileName,
    };

    return Uri(
      scheme: 'https',
      host: 'example.supabase.co',
      path: '/storage/v1/object/sign/circular-files/${file.storagePath}',
      queryParameters: query,
    );
  }

  @override
  Future<void> deleteFile(CircularFile file) async {
    _consumeNextErrorIfAny();

    _files.removeWhere((item) => item.id == file.id);
    _blobs.remove(file.storagePath);
    deletedFiles.add(file);
  }

  void _consumeNextErrorIfAny() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
