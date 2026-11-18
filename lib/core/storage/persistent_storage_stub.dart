import 'package:job_prep/core/storage/persistent_storage_service.dart';

/// Creates a stub persistent storage service for native / non-web platforms.
PersistentStorageService createPersistentStorageService() =>
    const _StubPersistentStorageService();

class _StubPersistentStorageService implements PersistentStorageService {
  const _StubPersistentStorageService();

  @override
  bool get isSupported => false;

  @override
  Future<bool> isPersisted() async => true;

  @override
  Future<bool> requestPersistence() async => true;
}
