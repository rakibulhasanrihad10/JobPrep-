import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/core/security/vault_payload_codec.dart';

/// Client-side PBKDF2 + AES-GCM-256 encryption service for portal credentials.
///
/// The passphrase and derived encryption keys live strictly in memory inside
/// overwrite-on-destroy [SecretKeyData] buffers, are never logged, stored, or
/// transmitted, and are wiped whenever [lock] is called.
class VaultService {
  /// Creates a [VaultService].
  ///
  /// Enforces at least [minIterations] (`100,000`) PBKDF2 iterations and
  /// defaults to [defaultIterations] (`210,000`).
  VaultService({
    int iterations = defaultIterations,
    Random? secureRandom,
    AesGcm? aesGcm,
  })  : _iterations = iterations,
        _random = secureRandom ?? Random.secure(),
        _aesGcm = aesGcm ?? AesGcm.with256bits() {
    if (iterations < minIterations) {
      throw const VaultConfigurationException(
        'PBKDF2 iteration count must be at least 100,000.',
      );
    }
  }

  /// Default PBKDF2-HMAC-SHA256 iteration count aligned with OWASP targets.
  static const int defaultIterations = VaultPayloadCodec.defaultIterations;

  /// Hard lower bound preventing weak key derivation configuration.
  static const int minIterations = VaultPayloadCodec.minIterations;

  /// Random salt length in bytes (`128` bits).
  static const int saltLengthBytes = VaultPayloadCodec.saltLengthBytes;

  /// Random AES-GCM nonce length in bytes (`96` bits).
  static const int nonceLengthBytes = VaultPayloadCodec.nonceLengthBytes;

  /// Derived AES key size (`256` bits / `32` bytes).
  static const int keyLengthBits = VaultPayloadCodec.keyLengthBits;

  static const String _checkCanaryPlaintext =
      'jobprep:vault:passphrase-check:v1';
  static final List<int> _checkAad = utf8.encode('jobprep:vault:check-aad:v1');

  final int _iterations;
  final Random _random;
  final AesGcm _aesGcm;

  SecretKeyData? _passphraseKey;
  final Map<String, SecretKeyData> _derivedKeys = <String, SecretKeyData>{};

  /// Configured PBKDF2 iteration count for new encryptions and checks.
  int get iterations => _iterations;

  /// Whether a verified passphrase is currently held in memory.
  bool get isUnlocked {
    final key = _passphraseKey;
    return key != null && !key.isDestroyed;
  }

  /// Number of derived per-salt keys currently cached in memory.
  int get cachedKeyCount => _derivedKeys.length;

  /// Derives a 256-bit AES key from [passphrase] and [salt] with
  /// PBKDF2-HMAC-SHA256.
  ///
  /// Calling [SecretKeyData.destroy] on the returned key zeroes its bytes.
  Future<SecretKeyData> deriveKey({
    required String passphrase,
    required List<int> salt,
    int? iterations,
  }) async {
    _validatePassphrase(passphrase);
    if (salt.length < saltLengthBytes) {
      throw const VaultConfigurationException(
        'PBKDF2 salt must be at least 16 bytes.',
      );
    }

    final effectiveIterations = iterations ?? _iterations;
    if (effectiveIterations < minIterations) {
      throw const VaultConfigurationException(
        'PBKDF2 iteration count below secure minimum.',
      );
    }

    final inputSecret = SecretKeyData(
      Uint8List.fromList(utf8.encode(passphrase)),
      overwriteWhenDestroyed: true,
    );

    try {
      return await VaultPayloadCodec.deriveKeyFromSecret(
        passphraseSecret: inputSecret,
        salt: salt,
        iterations: effectiveIterations,
      );
    } finally {
      inputSecret.destroy();
    }
  }

  /// Creates an encrypted verification check value without storing the
  /// passphrase anywhere.
  Future<VaultPayload> createCheckValue(String passphrase) {
    _validatePassphrase(passphrase);
    return _encryptInternal(
      plaintext: _checkCanaryPlaintext,
      passphrase: passphrase,
      aad: _checkAad,
    );
  }

  /// Verifies [passphrase] by decrypting [checkValue] and checking its
  /// authenticated canary string without storing [passphrase].
  Future<bool> verifyPassphrase({
    required String passphrase,
    required VaultPayload checkValue,
  }) async {
    if (passphrase.isEmpty) return false;
    try {
      final decoded = await _decryptInternal(
        payload: checkValue,
        passphrase: passphrase,
        aad: _checkAad,
      );
      return VaultPayloadCodec.constantTimeEquals(
        decoded,
        _checkCanaryPlaintext,
      );
    } on VaultException {
      return false;
    }
  }

  /// Verifies [passphrase] (against [checkValue] when provided) and loads the
  /// wipeable passphrase buffer into memory.
  Future<bool> unlock({
    required String passphrase,
    VaultPayload? checkValue,
  }) async {
    _validatePassphrase(passphrase);

    if (checkValue != null) {
      final isValid = await verifyPassphrase(
        passphrase: passphrase,
        checkValue: checkValue,
      );
      if (!isValid) return false;
    }

    lock();

    final passphraseSecret = SecretKeyData(
      Uint8List.fromList(utf8.encode(passphrase)),
      overwriteWhenDestroyed: true,
    );
    _passphraseKey = passphraseSecret;

    if (checkValue != null) {
      final saltBytes = VaultPayloadCodec.decodeBase64(
        checkValue.salt,
        minBytes: saltLengthBytes,
      );
      final derived = await VaultPayloadCodec.deriveKeyFromSecret(
        passphraseSecret: passphraseSecret,
        salt: saltBytes,
        iterations: checkValue.iterations,
      );
      _derivedKeys[_cacheKey(checkValue.salt, checkValue.iterations)] = derived;
    }

    return true;
  }

  /// Overwrites and clears the in-memory passphrase and all cached keys.
  void lock() {
    _passphraseKey?.destroy();
    _passphraseKey = null;

    for (final derived in _derivedKeys.values) {
      derived.destroy();
    }
    _derivedKeys.clear();
  }

  /// Encrypts [plaintext] using the unlocked passphrase, a fresh random salt,
  /// and a fresh random AES-GCM nonce.
  Future<VaultPayload> encrypt(String plaintext) async {
    final activePassphrase = _requireUnlockedPassphrase();
    final saltBytes = VaultPayloadCodec.nextRandomBytes(
      _random,
      saltLengthBytes,
    );
    final nonceBytes = VaultPayloadCodec.nextRandomBytes(
      _random,
      nonceLengthBytes,
    );

    final derivedKey = await VaultPayloadCodec.deriveKeyFromSecret(
      passphraseSecret: activePassphrase,
      salt: saltBytes,
      iterations: _iterations,
    );
    final saltB64 = base64Encode(saltBytes);
    _derivedKeys[_cacheKey(saltB64, _iterations)] = derivedKey;

    final box = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: derivedKey,
      nonce: nonceBytes,
    );
    return VaultPayloadCodec.encode(
      secretBox: box,
      saltBase64: saltB64,
      nonceBytes: nonceBytes,
      iterations: _iterations,
    );
  }

  /// Decrypts [payload] using the unlocked passphrase and verifies its GCM tag.
  Future<String> decrypt(VaultPayload payload) async {
    final activePassphrase = _requireUnlockedPassphrase();
    final parsed = VaultPayloadCodec.decode(payload);

    final cacheKey = _cacheKey(payload.salt, payload.iterations);
    var derivedKey = _derivedKeys[cacheKey];
    if (derivedKey == null || derivedKey.isDestroyed) {
      derivedKey = await VaultPayloadCodec.deriveKeyFromSecret(
        passphraseSecret: activePassphrase,
        salt: parsed.saltBytes,
        iterations: payload.iterations,
      );
      _derivedKeys[cacheKey] = derivedKey;
    }

    return await VaultPayloadCodec.decryptSecretBox(
      aesGcm: _aesGcm,
      secretBox: parsed.secretBox,
      secretKey: derivedKey,
    );
  }

  /// Encrypts [plaintext] once with an explicit [passphrase] without keeping
  /// any key or passphrase in memory afterward.
  Future<VaultPayload> encryptWithPassphrase({
    required String plaintext,
    required String passphrase,
  }) {
    _validatePassphrase(passphrase);
    return _encryptInternal(plaintext: plaintext, passphrase: passphrase);
  }

  /// Decrypts [payload] once with an explicit [passphrase] without modifying
  /// unlock session state.
  Future<String> decryptWithPassphrase({
    required VaultPayload payload,
    required String passphrase,
  }) {
    _validatePassphrase(passphrase);
    return _decryptInternal(payload: payload, passphrase: passphrase);
  }

  Future<VaultPayload> _encryptInternal({
    required String plaintext,
    required String passphrase,
    List<int> aad = const <int>[],
  }) async {
    final saltBytes = VaultPayloadCodec.nextRandomBytes(
      _random,
      saltLengthBytes,
    );
    final nonceBytes = VaultPayloadCodec.nextRandomBytes(
      _random,
      nonceLengthBytes,
    );
    final key = await deriveKey(passphrase: passphrase, salt: saltBytes);

    try {
      final box = await _aesGcm.encrypt(
        utf8.encode(plaintext),
        secretKey: key,
        nonce: nonceBytes,
        aad: aad,
      );
      return VaultPayloadCodec.encode(
        secretBox: box,
        saltBase64: base64Encode(saltBytes),
        nonceBytes: nonceBytes,
        iterations: _iterations,
      );
    } finally {
      key.destroy();
    }
  }

  Future<String> _decryptInternal({
    required VaultPayload payload,
    required String passphrase,
    List<int> aad = const <int>[],
  }) async {
    final parsed = VaultPayloadCodec.decode(payload);
    final key = await deriveKey(
      passphrase: passphrase,
      salt: parsed.saltBytes,
      iterations: payload.iterations,
    );

    try {
      return await VaultPayloadCodec.decryptSecretBox(
        aesGcm: _aesGcm,
        secretBox: parsed.secretBox,
        secretKey: key,
        aad: aad,
      );
    } finally {
      key.destroy();
    }
  }

  SecretKeyData _requireUnlockedPassphrase() {
    final key = _passphraseKey;
    if (key == null || key.isDestroyed) {
      throw const VaultLockedException();
    }
    return key;
  }

  void _validatePassphrase(String passphrase) {
    if (passphrase.isEmpty) {
      throw const VaultInvalidPassphraseException(
        'Passphrase cannot be empty.',
      );
    }
  }

  static String _cacheKey(String saltBase64, int iterations) =>
      '$iterations:$saltBase64';

  @override
  String toString() =>
      'VaultService(iterations: $_iterations, unlocked: $isUnlocked)';
}
