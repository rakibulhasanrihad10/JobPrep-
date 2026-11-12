import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:job_prep/core/security/vault_models.dart';

/// Encoding/decoding, key derivation, and byte-level helpers for vault crypto.
abstract final class VaultPayloadCodec {
  /// Default PBKDF2-HMAC-SHA256 iteration count aligned with OWASP targets.
  static const int defaultIterations = 210000;

  /// Hard lower bound preventing weak key derivation configuration.
  static const int minIterations = 100000;

  /// Random salt length in bytes (`128` bits).
  static const int saltLengthBytes = 16;

  /// Random AES-GCM nonce length in bytes (`96` bits).
  static const int nonceLengthBytes = 12;

  /// Derived AES key size (`256` bits / `32` bytes).
  static const int keyLengthBits = 256;

  /// AES-GCM authentication tag length (`128` bits / `16` bytes).
  static const int gcmTagLengthBytes = 16;

  /// Generates [length] cryptographically secure random bytes.
  static Uint8List nextRandomBytes(Random random, int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i += 1) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// Derives an extractable, overwrite-on-destroy 256-bit key from an
  /// in-memory [passphraseSecret] and [salt].
  static Future<SecretKeyData> deriveKeyFromSecret({
    required SecretKeyData passphraseSecret,
    required List<int> salt,
    required int iterations,
  }) async {
    final pbkdf2 = Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: keyLengthBits,
    );
    final derived = await pbkdf2.deriveKey(
      secretKey: passphraseSecret,
      nonce: salt,
    );
    final rawBytes = Uint8List.fromList(await derived.extractBytes());
    if (derived is SecretKeyData) {
      derived.destroy();
    }
    return SecretKeyData(rawBytes, overwriteWhenDestroyed: true);
  }

  /// Decrypts [secretBox] with [aesGcm] and zeroes plaintext bytes afterward.
  static Future<String> decryptSecretBox({
    required AesGcm aesGcm,
    required SecretBox secretBox,
    required SecretKey secretKey,
    List<int> aad = const <int>[],
  }) async {
    try {
      final plainBytes = await aesGcm.decrypt(
        secretBox,
        secretKey: secretKey,
        aad: aad,
      );
      try {
        return utf8.decode(plainBytes);
      } finally {
        if (plainBytes is Uint8List) {
          plainBytes.fillRange(0, plainBytes.length, 0);
        }
      }
    } on SecretBoxAuthenticationError {
      throw const VaultDecryptionException();
    } on FormatException {
      throw const VaultDecryptionException();
    }
  }

  /// Compares two strings in constant time to prevent timing side-channels.
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i += 1) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Encodes an AES-GCM [SecretBox] and KDF metadata into a [VaultPayload].
  static VaultPayload encode({
    required SecretBox secretBox,
    required String saltBase64,
    required List<int> nonceBytes,
    required int iterations,
  }) {
    return VaultPayload(
      ciphertext: base64Encode(secretBox.concatenation(nonce: false)),
      salt: saltBase64,
      nonce: base64Encode(nonceBytes),
      iterations: iterations,
    );
  }

  /// Validates [payload] and decodes its base64 salt bytes and [SecretBox].
  static ({Uint8List saltBytes, SecretBox secretBox}) decode(
    VaultPayload payload,
  ) {
    if (payload.iterations < minIterations) {
      throw const VaultConfigurationException(
        'Vault payload iteration count is below secure minimum.',
      );
    }

    final saltBytes = decodeBase64(payload.salt, minBytes: saltLengthBytes);
    final nonceBytes = decodeBase64(
      payload.nonce,
      exactBytes: nonceLengthBytes,
    );
    final combined = decodeBase64(
      payload.ciphertext,
      minBytes: gcmTagLengthBytes,
    );

    final tagStart = combined.length - gcmTagLengthBytes;
    final cipherText = Uint8List.sublistView(combined, 0, tagStart);
    final macBytes = Uint8List.sublistView(combined, tagStart);

    return (
      saltBytes: saltBytes,
      secretBox: SecretBox(
        cipherText,
        nonce: nonceBytes,
        mac: Mac(macBytes),
      ),
    );
  }

  /// Decodes a base64 string while verifying exact or minimum byte lengths.
  static Uint8List decodeBase64(
    String value, {
    int? minBytes,
    int? exactBytes,
  }) {
    try {
      final decoded = base64Decode(value);
      if (exactBytes != null && decoded.length != exactBytes) {
        throw const VaultDecryptionException('Invalid vault payload length.');
      }
      if (minBytes != null && decoded.length < minBytes) {
        throw const VaultDecryptionException('Invalid vault payload length.');
      }
      return decoded;
    } on FormatException {
      throw const VaultDecryptionException('Malformed base64 vault field.');
    }
  }
}
