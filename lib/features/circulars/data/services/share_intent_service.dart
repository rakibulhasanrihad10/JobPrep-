import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Abstract service interface for capturing shared links and text from the
/// native system share sheet (Android/iOS).
abstract class ShareIntentService {
  /// Stream emitting incoming shared URLs while the application is active.
  Stream<String> get sharedLinksStream;

  /// Retrieves any shared URL present when the application was launched from
  /// a share intent.
  Future<String?> getInitialSharedLink();

  /// Resets the native intent state after the shared payload has been consumed.
  Future<void> reset();
}

/// Native implementation of [ShareIntentService] backed by
/// [ReceiveSharingIntent].
class ReceiveSharingIntentService implements ShareIntentService {
  /// Creates a [ReceiveSharingIntentService].
  const ReceiveSharingIntentService();

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Stream<String> get sharedLinksStream {
    if (!_isSupportedPlatform) {
      return const Stream.empty();
    }
    return ReceiveSharingIntent.instance
        .getMediaStream()
        .map(_extractLinkFromMediaList)
        .where((link) => link != null)
        .cast<String>();
  }

  @override
  Future<String?> getInitialSharedLink() async {
    if (!_isSupportedPlatform) return null;
    try {
      final initialMedia =
          await ReceiveSharingIntent.instance.getInitialMedia();
      return _extractLinkFromMediaList(initialMedia);
    } on Object catch (e) {
      debugPrint('ShareIntentService getInitialSharedLink error: $e');
      return null;
    }
  }

  @override
  Future<void> reset() async {
    if (!_isSupportedPlatform) return;
    try {
      await ReceiveSharingIntent.instance.reset();
    } on Object catch (e) {
      debugPrint('ShareIntentService reset error: $e');
    }
  }

  String? _extractLinkFromMediaList(List<SharedMediaFile> files) {
    if (files.isEmpty) return null;
    for (final file in files) {
      final textOrPath = file.path;
      final extracted = extractUrlFromSharedText(textOrPath);
      if (extracted != null && extracted.isNotEmpty) {
        return extracted;
      }
    }
    return null;
  }
}

/// Riverpod provider for the platform share intent service.
final shareIntentServiceProvider = Provider<ShareIntentService>((ref) {
  return const ReceiveSharingIntentService();
});

/// Riverpod notifier holding any pending shared link waiting to be consumed by
/// the Quick Capture flow.
class PendingShareCaptureNotifier extends Notifier<String?> {
  StreamSubscription<String>? _subscription;

  @override
  String? build() {
    final service = ref.watch(shareIntentServiceProvider);
    unawaited(_subscription?.cancel());
    _subscription = service.sharedLinksStream.listen((link) {
      state = link;
    });

    ref.onDispose(() {
      unawaited(_subscription?.cancel());
    });

    // Check cold launch initial share intent
    unawaited(_checkInitial(service));

    return null;
  }

  Future<void> _checkInitial(ShareIntentService service) async {
    final initial = await service.getInitialSharedLink();
    if (initial != null && state == null) {
      state = initial;
    }
  }

  /// The current pending shared link, if any.
  String? get pendingLink => state;

  /// Sets a pending shared link manually (e.g. for testing or deep-linking).
  set pendingLink(String? link) {
    state = link;
  }

  /// Consumes and clears the current pending shared link, notifying the native
  /// service that the intent was handled.
  String? consume() {
    final current = state;
    state = null;
    if (current != null) {
      unawaited(ref.read(shareIntentServiceProvider).reset());
    }
    return current;
  }
}

/// Provider exposing the current pending shared URL to capture.
final pendingShareCaptureProvider =
    NotifierProvider<PendingShareCaptureNotifier, String?>(
  PendingShareCaptureNotifier.new,
);
