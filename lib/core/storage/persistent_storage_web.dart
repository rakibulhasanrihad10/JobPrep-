import 'dart:js_interop';
import 'package:job_prep/core/storage/persistent_storage_service.dart';
import 'package:web/web.dart' as web;

/// Creates a web persistent storage service using the browser's Storage API.
PersistentStorageService createPersistentStorageService() =>
    const _WebPersistentStorageService();

class _WebPersistentStorageService implements PersistentStorageService {
  const _WebPersistentStorageService();

  @override
  bool get isSupported => true;

  @override
  Future<bool> isPersisted() async {
    try {
      final storage = web.window.navigator.storage;
      final jsBool = await storage.persisted().toDart;
      return jsBool.toDart;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> requestPersistence() async {
    try {
      final storage = web.window.navigator.storage;
      final jsBool = await storage.persist().toDart;
      return jsBool.toDart;
    } on Object {
      return false;
    }
  }
}
