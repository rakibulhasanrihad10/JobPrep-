import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_factory_stub.dart'
    if (dart.library.js_interop) 'package:job_prep/features/prep/presentation/utils/timer_platform_factory_web.dart'
    as platform_factory;

/// Platform adapter updating the browser tab title and playing an optional
/// gentle alert sound without platform-specific imports in controllers/widgets.
abstract interface class StudyTimerPlatformAdapter {
  /// Updates the active browser tab title while a study session runs.
  void setTabTitle(String title);

  /// Restores the default application tab title when the timer stops.
  void restoreTabTitle();

  /// Plays a gentle synthesized two-tone chime when a Pomodoro round finishes.
  Future<void> playGentleChime();
}

/// Injectable provider supplying [StudyTimerPlatformAdapter] so unit and
/// widget tests can capture tab title changes and chime triggers.
final Provider<StudyTimerPlatformAdapter> studyTimerPlatformProvider =
    Provider<StudyTimerPlatformAdapter>(
  (ref) => platform_factory.createStudyTimerPlatformAdapter(),
);
