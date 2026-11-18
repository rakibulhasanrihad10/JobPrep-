import 'dart:convert' show jsonEncode;

import 'package:flutter/foundation.dart' show immutable;

/// Encrypted envelope header and payload for passphrase-protected backup files.
@immutable
class BackupCryptoEnvelope {
  /// Creates a [BackupCryptoEnvelope].
  const BackupCryptoEnvelope({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.salt,
    required this.nonce,
    required this.mac,
    required this.ciphertext,
    this.format = formatIdentifier,
    this.kdf = kdfIdentifier,
    this.iterations = defaultIterations,
  });

  /// Deserializes a [BackupCryptoEnvelope] from [json].
  factory BackupCryptoEnvelope.fromJson(Map<String, dynamic> json) {
    return BackupCryptoEnvelope(
      format: (json['format'] as String?) ?? formatIdentifier,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      appVersion: (json['appVersion'] as String?) ?? '0.1.0',
      exportedAt: DateTime.tryParse((json['exportedAt'] as String?) ?? '') ??
          DateTime.now().toUtc(),
      kdf: (json['kdf'] as String?) ?? kdfIdentifier,
      iterations: (json['iterations'] as num?)?.toInt() ?? defaultIterations,
      salt: (json['salt'] as String?) ?? '',
      nonce: (json['nonce'] as String?) ?? '',
      mac: (json['mac'] as String?) ?? '',
      ciphertext: (json['ciphertext'] as String?) ?? '',
    );
  }

  /// Standard format identifier for encrypted JobPrep backups.
  static const String formatIdentifier = 'jobprep_backup_encrypted';

  /// Key derivation function identifier.
  static const String kdfIdentifier = 'PBKDF2-HMAC-SHA256';

  /// Default PBKDF2 iteration count for backup encryption.
  static const int defaultIterations = 100000;

  /// Envelope format marker.
  final String format;

  /// Schema version of the encapsulated backup.
  final int schemaVersion;

  /// JobPrep application version that exported this file.
  final String appVersion;

  /// UTC timestamp when backup was generated.
  final DateTime exportedAt;

  /// Key derivation algorithm name.
  final String kdf;

  /// PBKDF2 iteration count.
  final int iterations;

  /// Base64-encoded random salt (16 bytes).
  final String salt;

  /// Base64-encoded random AES-GCM nonce (12 bytes).
  final String nonce;

  /// Base64-encoded AES-GCM authentication tag (16 bytes).
  final String mac;

  /// Base64-encoded ciphertext of the UTF-8 backup JSON string.
  final String ciphertext;

  /// Checks whether [json] represents an encrypted JobPrep backup envelope.
  static bool isEncryptedEnvelope(Map<String, dynamic> json) {
    return json['format'] == formatIdentifier;
  }

  /// Serializes envelope to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'format': format,
      'schemaVersion': schemaVersion,
      'appVersion': appVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'kdf': kdf,
      'iterations': iterations,
      'salt': salt,
      'nonce': nonce,
      'mac': mac,
      'ciphertext': ciphertext,
    };
  }

  /// Encodes this envelope directly to a JSON string.
  String toJsonString() => jsonEncode(toJson());
}
