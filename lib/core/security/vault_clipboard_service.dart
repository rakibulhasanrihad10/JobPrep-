import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback writing plain text into the OS clipboard.
typedef VaultClipboardWriter = Future<void> Function(String text);

/// Callback reading current OS clipboard text (`null` when unavailable).
typedef VaultClipboardReader = Future<String?> Function();

Future<void> _defaultClipboardWriter(String text) {
  return Clipboard.setData(ClipboardData(text: text));
}

Future<String?> _defaultClipboardReader() async {
  try {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  } on PlatformException {
    return null;
  }
}

/// Duration before copied vault credentials are cleared from the clipboard.
final Provider<Duration> vaultClipboardClearDurationProvider =
    Provider<Duration>((ref) => const Duration(seconds: 30));

/// Injectable clipboard writer allowing unit/widget tests to inspect copies
/// and clear-clipboard timers deterministically.
final Provider<VaultClipboardWriter> vaultClipboardWriterProvider =
    Provider<VaultClipboardWriter>((ref) => _defaultClipboardWriter);

/// Injectable clipboard reader used before wiping managed clipboard contents.
final Provider<VaultClipboardReader> vaultClipboardReaderProvider =
    Provider<VaultClipboardReader>((ref) => _defaultClipboardReader);

/// Clipboard guard writing sensitive values and clearing them automatically
/// after a configured timeout or when the vault locks.
class VaultClipboardService {
  /// Creates a [VaultClipboardService].
  VaultClipboardService({
    required this.clearDuration,
    VaultClipboardWriter? writer,
    VaultClipboardReader? reader,
  })  : _writer = writer ?? _defaultClipboardWriter,
        _reader = reader ?? _defaultClipboardReader;

  /// Delay after which copied text is cleared automatically.
  final Duration clearDuration;
  final VaultClipboardWriter _writer;
  final VaultClipboardReader _reader;

  Timer? _clearTimer;
  String? _lastCopiedValue;

  /// Whether a sensitive clipboard clear timer is currently scheduled.
  bool get hasPendingClear => _clearTimer?.isActive ?? false;

  /// Copies [value] to the clipboard and starts/restarts the clear timer.
  Future<void> copySensitive(String value) async {
    _clearTimer?.cancel();
    _lastCopiedValue = value;
    await _writer(value);

    _clearTimer = Timer(clearDuration, () {
      unawaited(clearIfManaged());
    });
  }

  /// Clears the clipboard when it still holds the last copied vault value
  /// (or when clipboard reading is unavailable on the host browser).
  Future<void> clearIfManaged() async {
    _clearTimer?.cancel();
    _clearTimer = null;

    final tracked = _lastCopiedValue;
    _lastCopiedValue = null;
    if (tracked == null) return;

    final current = await _reader();
    if (current == null || current == tracked) {
      await _writer('');
    }
  }

  /// Cancels any pending clear timer without leaving dangling timers behind.
  void dispose() {
    _clearTimer?.cancel();
    _clearTimer = null;
    _lastCopiedValue = null;
  }
}

/// Provides the app-wide [VaultClipboardService] wired to injectable clear
/// duration and clipboard delegates.
final Provider<VaultClipboardService> vaultClipboardServiceProvider =
    Provider<VaultClipboardService>((ref) {
  final service = VaultClipboardService(
    clearDuration: ref.watch(vaultClipboardClearDurationProvider),
    writer: ref.watch(vaultClipboardWriterProvider),
    reader: ref.watch(vaultClipboardReaderProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
