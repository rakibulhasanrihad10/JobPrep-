import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/storage/persistent_storage_stub.dart'
    if (dart.library.js_interop) 'package:job_prep/core/storage/'
        'persistent_storage_web.dart';

/// Service checking and requesting web persistent storage
/// (`navigator.storage`).
abstract interface class PersistentStorageService {
  /// Whether the current platform supports persistent storage requests.
  bool get isSupported;

  /// Returns whether storage is currently persisted.
  Future<bool> isPersisted();

  /// Requests persistent storage permission from the browser.
  Future<bool> requestPersistence();
}

/// Provides platform-appropriate [PersistentStorageService].
final Provider<PersistentStorageService> persistentStorageServiceProvider =
    Provider<PersistentStorageService>((ref) {
  return createPersistentStorageService();
});

/// Async state for whether persistent storage has been granted.
final persistentStorageStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(persistentStorageServiceProvider);
  if (!service.isSupported) return true;
  return await service.isPersisted();
});
