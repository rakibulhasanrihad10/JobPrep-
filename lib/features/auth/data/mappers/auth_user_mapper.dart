import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase `User` records into pure domain [AuthUser] entities.
abstract final class AuthUserMapper {
  /// Converts a Supabase [user] into a domain [AuthUser].
  static AuthUser fromSupabase(supabase.User user) {
    final metadata = user.userMetadata;
    final displayName =
        _readString(metadata, 'full_name') ?? _readString(metadata, 'name');
    final avatarUrl =
        _readString(metadata, 'avatar_url') ?? _readString(metadata, 'picture');

    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      emailConfirmed:
          user.emailConfirmedAt != null && user.emailConfirmedAt!.isNotEmpty,
    );
  }

  static String? _readString(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }
}
