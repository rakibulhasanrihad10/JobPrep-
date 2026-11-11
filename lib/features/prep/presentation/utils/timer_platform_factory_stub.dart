import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';

class _NoopStudyTimerPlatformAdapter implements StudyTimerPlatformAdapter {
  const _NoopStudyTimerPlatformAdapter();

  @override
  void setTabTitle(String title) {}

  @override
  void restoreTabTitle() {}

  @override
  Future<void> playGentleChime() async {}
}

/// Returns a safe no-op adapter on non-web VM, mobile, and test hosts.
StudyTimerPlatformAdapter createStudyTimerPlatformAdapter() =>
    const _NoopStudyTimerPlatformAdapter();
