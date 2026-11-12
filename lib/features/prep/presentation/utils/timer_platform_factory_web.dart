import 'dart:async' show unawaited;
import 'dart:js_interop';

import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';

@JS('document')
external _JsDocument? get _document;

@JS('AudioContext')
external JSAny? get _audioContextGlobal;

extension type _JsDocument(JSObject _) implements JSObject {
  external String get title;
  external set title(String value);
}

@JS('AudioContext')
extension type _JsAudioContext._(JSObject _) implements JSObject {
  external factory _JsAudioContext();
  external double get currentTime;
  external _JsAudioNode get destination;
  external _JsOscillator createOscillator();
  external _JsGainNode createGain();
  external JSPromise<JSAny?>? close();
}

extension type _JsAudioNode(JSObject _) implements JSObject {
  external void connect(_JsAudioNode target);
}

extension type _JsOscillator(JSObject _) implements _JsAudioNode {
  external String get type;
  external set type(String value);
  external _JsAudioParam get frequency;
  external void start([double when]);
  external void stop([double when]);
}

extension type _JsGainNode(JSObject _) implements _JsAudioNode {
  external _JsAudioParam get gain;
}

extension type _JsAudioParam(JSObject _) implements JSObject {
  external void setValueAtTime(double value, double startTime);
  external void exponentialRampToValueAtTime(double value, double endTime);
}

class _WebStudyTimerPlatformAdapter implements StudyTimerPlatformAdapter {
  String? _originalTitle;

  @override
  void setTabTitle(String title) {
    try {
      final doc = _document;
      if (doc == null) return;
      _originalTitle ??= doc.title.isEmpty ? 'JobPrep' : doc.title;
      doc.title = title;
    } on Object catch (_) {
      // Ignore restricted document access cleanly.
    }
  }

  @override
  void restoreTabTitle() {
    try {
      final doc = _document;
      final saved = _originalTitle;
      if (doc != null && saved != null && saved.isNotEmpty) {
        doc.title = saved;
      }
      _originalTitle = null;
    } on Object catch (_) {
      // Ignore cleanly.
    }
  }

  @override
  Future<void> playGentleChime() async {
    try {
      if (_audioContextGlobal == null) return;
      final ctx = _JsAudioContext();

      _scheduleTone(ctx, frequencyHz: 523.25, startOffset: 0, duration: 0.28);
      _scheduleTone(
        ctx,
        frequencyHz: 659.25,
        startOffset: 0.14,
        duration: 0.35,
      );

      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 650), () {
          try {
            ctx.close();
          } on Object catch (_) {}
        }),
      );
    } on Object catch (_) {
      // Autoplay restriction or unsupported Web Audio should never crash timer.
    }
  }

  void _scheduleTone(
    _JsAudioContext ctx, {
    required double frequencyHz,
    required double startOffset,
    required double duration,
  }) {
    final base = ctx.currentTime + startOffset;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(frequencyHz, base);

    gain.gain.setValueAtTime(0.06, base);
    gain.gain.exponentialRampToValueAtTime(0.0001, base + duration);

    osc
      ..connect(gain)
      ..start(base)
      ..stop(base + duration + 0.02);
    gain.connect(ctx.destination);
  }
}

/// Creates a web adapter leveraging DOM title and Web Audio synthesis.
StudyTimerPlatformAdapter createStudyTimerPlatformAdapter() =>
    _WebStudyTimerPlatformAdapter();
