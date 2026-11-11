/// Permission state reported by an optional push notification provider.
enum PushPermissionStatus {
  /// Not supported on the active runtime or not wired yet.
  unsupported,

  /// User has not granted or denied push permission yet.
  prompt,

  /// Push notifications are permitted.
  granted,

  /// Push notifications were explicitly denied.
  denied,
}

/// Clean extension point for future Web Push / Android push notification
/// adapters without coupling domain or UI code to push SDKs.
///
/// Phase 6J delivers in-app notifications live via Supabase Realtime + polling
/// while open, alongside email reminders via Edge Functions when closed.
/// Adapters can register browser Push or FCM tokens here later.
abstract interface class PushNotificationExtensionPoint {
  /// Whether push notification delivery is wired for this platform build.
  bool get isSupported;

  /// Current permission state without prompting the user.
  Future<PushPermissionStatus> getPermissionStatus();

  /// Requests permission to deliver out-of-app push notifications.
  Future<PushPermissionStatus> requestPermission();

  /// Associates any platform push token with [userId] on backend registration.
  Future<void> syncDeviceToken({required String userId});

  /// Clears any registered push token during sign-out or opt-out.
  Future<void> clearDeviceToken();
}

/// Default no-op [PushNotificationExtensionPoint] active until Web Push or
/// mobile push providers are configured.
class NoopPushNotificationExtensionPoint
    implements PushNotificationExtensionPoint {
  /// Creates a [NoopPushNotificationExtensionPoint].
  const NoopPushNotificationExtensionPoint();

  @override
  bool get isSupported => false;

  @override
  Future<PushPermissionStatus> getPermissionStatus() async =>
      PushPermissionStatus.unsupported;

  @override
  Future<PushPermissionStatus> requestPermission() async =>
      PushPermissionStatus.unsupported;

  @override
  Future<void> syncDeviceToken({required String userId}) async {}

  @override
  Future<void> clearDeviceToken() async {}
}
