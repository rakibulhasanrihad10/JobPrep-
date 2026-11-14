import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:job_prep/core/security/vault_payload_codec.dart';
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';

/// Exception thrown when backup decryption or key derivation fails.
class BackupDecryptionFailure implements Exception {
  /// Creates a [BackupDecryptionFailure].
  const BackupDecryptionFailure([
    this.message = 'Incorrect passphrase or invalid backup.',
  ]);

  /// Explanatory message.
  final String message;

  @override
  String toString() => 'BackupDecryptionFailure: $message';
}

/// AES-GCM (256-bit) and PBKDF2-HMAC-SHA256 encryption service
/// for backup files.
class BackupCryptoService {
  /// Creates a [BackupCryptoService].
  BackupCryptoService({
    AesGcm? aesGcm,
    Random? secureRandom,
  })  : _aesGcm = aesGcm ?? AesGcm.with256bits(),
        _random = secureRandom ?? Random.secure();

  final AesGcm _aesGcm;
  final Random _random;

  static final BackupCryptoService _instance = BackupCryptoService();

  /// Static convenience encrypt method.
  static Future<BackupCryptoEnvelope> encrypt({
    required String plainJson,
    required String passphrase,
    required int schemaVersion,
    required String appVersion,
    DateTime? exportedAt,
    int iterations = BackupCryptoEnvelope.defaultIterations,
  }) =>
      _instance.encryptBackup(
        jsonString: plainJson,
        passphrase: passphrase,
        schemaVersion: schemaVersion,
        appVersion: appVersion,
        iterations: iterations,
      );

  /// Static convenience decrypt method.
  static Future<String> decrypt({
    required BackupCryptoEnvelope envelope,
    required String passphrase,
  }) =>
      _instance.decryptBackup(envelope: envelope, passphrase: passphrase);

  /// Encrypts plaintext [jsonString] using [passphrase] with fresh salt
  /// and nonce.
  Future<BackupCryptoEnvelope> encryptBackup({
    required String jsonString,
    required String passphrase,
    required int schemaVersion,
    required String appVersion,
    int iterations = BackupCryptoEnvelope.defaultIterations,
  }) async {
    final salt = VaultPayloadCodec.nextRandomBytes(_random, 16);
    final nonce = VaultPayloadCodec.nextRandomBytes(_random, 12);
    final plainBytes = utf8.encode(jsonString);

    final passphraseSecret = SecretKeyData(
      utf8.encode(passphrase),
      overwriteWhenDestroyed: true,
    );

    SecretKeyData? derivedKey;
    try {
      derivedKey = await VaultPayloadCodec.deriveKeyFromSecret(
        passphraseSecret: passphraseSecret,
        salt: salt,
        iterations: iterations,
      );

      final secretBox = await _aesGcm.encrypt(
        plainBytes,
        secretKey: derivedKey,
        nonce: nonce,
      );

      return BackupCryptoEnvelope(
        schemaVersion: schemaVersion,
        appVersion: appVersion,
        exportedAt: DateTime.now().toUtc(),
        salt: base64Encode(salt),
        nonce: base64Encode(nonce),
        mac: base64Encode(secretBox.mac.bytes),
        ciphertext: base64Encode(secretBox.cipherText),
        iterations: iterations,
      );
    } finally {
      passphraseSecret.destroy();
      derivedKey?.destroy();
    }
  }

  /// Decrypts [envelope] using [passphrase]. Throws [BackupDecryptionFailure]
  /// if passphrase is wrong or the ciphertext / tag has been tampered with.
  Future<String> decryptBackup({
    required BackupCryptoEnvelope envelope,
    required String passphrase,
  }) async {
    final salt = base64Decode(envelope.salt);
    final nonce = base64Decode(envelope.nonce);
    final macBytes = base64Decode(envelope.mac);
    final cipherBytes = base64Decode(envelope.ciphertext);

    final passphraseSecret = SecretKeyData(
      utf8.encode(passphrase),
      overwriteWhenDestroyed: true,
    );

    SecretKeyData? derivedKey;
    try {
      derivedKey = await VaultPayloadCodec.deriveKeyFromSecret(
        passphraseSecret: passphraseSecret,
        salt: salt,
        iterations: envelope.iterations,
      );

      final secretBox = SecretBox(
        cipherBytes,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final decryptedBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: derivedKey,
      );

      return utf8.decode(decryptedBytes);
    } on Object catch (_) {
      throw const BackupDecryptionFailure();
    } finally {
      passphraseSecret.destroy();
      derivedKey?.destroy();
    }
  }
}
