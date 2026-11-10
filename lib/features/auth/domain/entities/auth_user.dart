import 'package:flutter/foundation.dart' show immutable;

/// Pure domain entity representing an authenticated user.
@immutable
class AuthUser {
  /// Creates an [AuthUser].
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.emailConfirmed = false,
  });

  /// Unique user identifier (`auth.users.id`).
  final String id;

  /// Primary email address associated with the user account.
  final String? email;

  /// User display name if provided in profile metadata.
  final String? displayName;

  /// User avatar URL if provided in profile metadata.
  final String? avatarUrl;

  /// Whether the user's email address has been verified.
  final bool emailConfirmed;

  /// Creates a modified copy of this [AuthUser].
  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? emailConfirmed,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.emailConfirmed == emailConfirmed;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        displayName,
        avatarUrl,
        emailConfirmed,
      );

  @override
  String toString() => 'AuthUser(id: $id, emailConfirmed: $emailConfirmed)';
}
