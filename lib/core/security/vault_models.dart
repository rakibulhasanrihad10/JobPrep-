import 'package:flutter/foundation.dart' show immutable;

/// Ciphertext container produced by VaultService using PBKDF2 + AES-GCM-256.
///
/// Stores only non-secret cryptographic parameters (`ciphertext` with appended
/// 16-byte GCM authentication tag, random PBKDF2 `salt`, random AES-GCM
/// `nonce`, and iteration count). Never contains plaintext or vault passphrase.
@immutable
class VaultPayload {
  /// Creates a [VaultPayload].
  const VaultPayload({
    required this.ciphertext,
    required this.salt,
    required this.nonce,
    required this.iterations,
  });

  /// Reconstructs a [VaultPayload] from JSON metadata.
  factory VaultPayload.fromJson(Map<String, dynamic> json) {
    final ciphertext = json['ciphertext'];
    final salt = json['salt'];
    final nonce = json['nonce'];
    final iterations = json['iterations'];

    if (ciphertext is! String ||
        salt is! String ||
        nonce is! String ||
        iterations is! int) {
      throw const VaultDecryptionException(
        'Malformed vault payload metadata.',
      );
    }

    return VaultPayload(
      ciphertext: ciphertext,
      salt: salt,
      nonce: nonce,
      iterations: iterations,
    );
  }

  /// Base64-encoded AES-GCM ciphertext concatenated with the 16-byte auth tag.
  final String ciphertext;

  /// Base64-encoded random salt used for PBKDF2 key derivation.
  final String salt;

  /// Base64-encoded random 12-byte AES-GCM initialization vector (nonce).
  final String nonce;

  /// PBKDF2-HMAC-SHA256 iteration count used to derive the encryption key.
  final int iterations;

  /// Serializes public cryptographic metadata into JSON without any secret.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'ciphertext': ciphertext,
        'salt': salt,
        'nonce': nonce,
        'iterations': iterations,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VaultPayload &&
        other.ciphertext == ciphertext &&
        other.salt == salt &&
        other.nonce == nonce &&
        other.iterations == iterations;
  }

  @override
  int get hashCode => Object.hash(ciphertext, salt, nonce, iterations);

  @override
  String toString() => 'VaultPayload(iterations: $iterations, <redacted>)';
}

/// Base exception type for client-side vault cryptography failures.
@immutable
sealed class VaultException implements Exception {
  /// Creates a [VaultException].
  const VaultException(this.message);

  /// Safe diagnostic message (never contains passphrases, keys, or plaintext).
  final String message;

  @override
  String toString() {
    final kind = switch (this) {
      VaultLockedException() => 'VaultLockedException',
      VaultInvalidPassphraseException() => 'VaultInvalidPassphraseException',
      VaultDecryptionException() => 'VaultDecryptionException',
      VaultConfigurationException() => 'VaultConfigurationException',
    };
    return '$kind: $message';
  }
}

/// Thrown when an unlocked vault operation is requested while locked.
final class VaultLockedException extends VaultException {
  /// Creates a [VaultLockedException].
  const VaultLockedException([
    super.message = 'Vault is locked. Unlock it with your passphrase first.',
  ]);
}

/// Thrown when the supplied passphrase fails validation or verification.
final class VaultInvalidPassphraseException extends VaultException {
  /// Creates a [VaultInvalidPassphraseException].
  const VaultInvalidPassphraseException([
    super.message = 'Vault passphrase is invalid or cannot be verified.',
  ]);
}

/// Thrown when AES-GCM decryption fails due to wrong passphrase or tampering.
final class VaultDecryptionException extends VaultException {
  /// Creates a [VaultDecryptionException].
  const VaultDecryptionException([
    super.message =
        'Unable to decrypt vault entry: wrong passphrase or tampered data.',
  ]);
}

/// Thrown when KDF or cipher parameters fall below security requirements.
final class VaultConfigurationException extends VaultException {
  /// Creates a [VaultConfigurationException].
  const VaultConfigurationException([
    super.message = 'Vault cryptographic parameters are invalid.',
  ]);
}
