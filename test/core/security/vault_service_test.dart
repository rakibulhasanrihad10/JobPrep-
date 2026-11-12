import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/core/security/vault_payload_codec.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/security/vault_service.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';

import '../../features/auth/fake_auth_repository.dart';

String _flipByteInBase64(String input, int byteIndex) {
  final bytes = Uint8List.fromList(base64Decode(input));
  bytes[byteIndex] = bytes[byteIndex] ^ 0x01;
  return base64Encode(bytes);
}

void main() {
  group('VaultService Configuration & PBKDF2 Derivation', () {
    test('rejects low iteration counts and short salts', () async {
      expect(
        () => VaultService(iterations: 10000),
        throwsA(isA<VaultConfigurationException>()),
      );

      final vault = VaultService();
      expect(vault.iterations, greaterThanOrEqualTo(100000));

      await expectLater(
        vault.deriveKey(
          passphrase: 'correct-horse-battery',
          salt: List<int>.filled(8, 1),
        ),
        throwsA(isA<VaultConfigurationException>()),
      );
    });

    test(
      'derives deterministic 256-bit keys for identical passphrase and salt, '
      'and distinct keys across salts or passphrases',
      () async {
        final vault = VaultService();
        final saltA = List<int>.generate(16, (i) => i + 1);
        final saltB = List<int>.generate(16, (i) => i + 100);

        final keyA1 = await vault.deriveKey(
          passphrase: 'pass-alpha',
          salt: saltA,
        );
        final keyA2 = await vault.deriveKey(
          passphrase: 'pass-alpha',
          salt: saltA,
        );
        final keyDiffSalt = await vault.deriveKey(
          passphrase: 'pass-alpha',
          salt: saltB,
        );
        final keyDiffPass = await vault.deriveKey(
          passphrase: 'pass-beta',
          salt: saltA,
        );

        expect(keyA1.bytes, hasLength(32));
        expect(keyA1.bytes, equals(keyA2.bytes));
        expect(keyA1.bytes, isNot(equals(keyDiffSalt.bytes)));
        expect(keyA1.bytes, isNot(equals(keyDiffPass.bytes)));

        keyA1.destroy();
        keyA2.destroy();
        keyDiffSalt.destroy();
        keyDiffPass.destroy();

        expect(keyA1.isDestroyed, isTrue);
        expect(() => keyA1.bytes, throwsStateError);
      },
    );
  });

  group('VaultService Encryption, Decryption & Tamper Resistance', () {
    test('encrypt/decrypt round trip works with Unicode and empty strings',
        () async {
      final vault = VaultService();
      expect(vault.isUnlocked, isFalse);

      await vault.unlock(passphrase: 'bcs-portal-vault-2026!');
      expect(vault.isUnlocked, isTrue);

      const secret = 'User: আমার-ইউজার | Pass: #Gold&Navy99!';
      final encrypted = await vault.encrypt(secret);
      expect(encrypted.ciphertext, isNotEmpty);
      expect(
        VaultPayloadCodec.decodeBase64(encrypted.salt),
        hasLength(VaultService.saltLengthBytes),
      );
      expect(
        VaultPayloadCodec.decodeBase64(encrypted.nonce),
        hasLength(VaultService.nonceLengthBytes),
      );
      expect(vault.cachedKeyCount, 1);

      expect(await vault.decrypt(encrypted), equals(secret));

      // Re-reading uses the cached key cleanly without extra cache entries.
      expect(await vault.decrypt(encrypted), equals(secret));
      expect(vault.cachedKeyCount, 1);

      final emptyEncrypted = await vault.encrypt('');
      expect(await vault.decrypt(emptyEncrypted), equals(''));
    });

    test('uses a fresh random nonce and salt on every encryption', () async {
      final vault = VaultService();
      await vault.unlock(passphrase: 'same-passphrase');

      final first = await vault.encrypt('identical-secret');
      final second = await vault.encrypt('identical-secret');

      expect(first.nonce, isNot(equals(second.nonce)));
      expect(first.salt, isNot(equals(second.salt)));
      expect(first.ciphertext, isNot(equals(second.ciphertext)));

      expect(await vault.decrypt(first), equals('identical-secret'));
      expect(await vault.decrypt(second), equals('identical-secret'));
    });

    test('decryption fails with wrong passphrase', () async {
      final vault = VaultService();
      final payload = await vault.encryptWithPassphrase(
        plaintext: 'portal-secret-token',
        passphrase: 'right-passphrase-1',
      );

      await expectLater(
        vault.decryptWithPassphrase(
          payload: payload,
          passphrase: 'wrong-passphrase-2',
        ),
        throwsA(isA<VaultDecryptionException>()),
      );

      final lockedSession = VaultService();
      await lockedSession.unlock(passphrase: 'wrong-passphrase-2');
      await expectLater(
        lockedSession.decrypt(payload),
        throwsA(isA<VaultDecryptionException>()),
      );
    });

    test(
      'decryption fails when ciphertext, auth tag, nonce, or salt is tampered',
      () async {
        final vault = VaultService();
        const passphrase = 'tamper-guard-passphrase';
        final payload = await vault.encryptWithPassphrase(
          plaintext: 'sensitive-portal-password',
          passphrase: passphrase,
        );
        final rawCipherBytes = base64Decode(payload.ciphertext);

        final tamperedBody = VaultPayload(
          ciphertext: _flipByteInBase64(payload.ciphertext, 0),
          salt: payload.salt,
          nonce: payload.nonce,
          iterations: payload.iterations,
        );
        final tamperedTag = VaultPayload(
          ciphertext: _flipByteInBase64(
            payload.ciphertext,
            rawCipherBytes.length - 1,
          ),
          salt: payload.salt,
          nonce: payload.nonce,
          iterations: payload.iterations,
        );
        final tamperedNonce = VaultPayload(
          ciphertext: payload.ciphertext,
          salt: payload.salt,
          nonce: _flipByteInBase64(payload.nonce, 0),
          iterations: payload.iterations,
        );
        final tamperedSalt = VaultPayload(
          ciphertext: payload.ciphertext,
          salt: _flipByteInBase64(payload.salt, 0),
          nonce: payload.nonce,
          iterations: payload.iterations,
        );

        for (final bad in [
          tamperedBody,
          tamperedTag,
          tamperedNonce,
          tamperedSalt,
        ]) {
          await expectLater(
            vault.decryptWithPassphrase(
              payload: bad,
              passphrase: passphrase,
            ),
            throwsA(isA<VaultDecryptionException>()),
          );
        }
      },
    );
  });

  group('Encrypted Passphrase Check Value & Memory Wiping', () {
    test(
      'verifies passphrase via check value without storing passphrase',
      () async {
        final vault = VaultService();
        const passphrase = 'MyMasterVaultPass!99';

        final checkValue = await vault.createCheckValue(passphrase);
        final serialized = jsonEncode(checkValue.toJson());
        expect(serialized.contains(passphrase), isFalse);
        expect(checkValue.toString().contains(checkValue.ciphertext), isFalse);

        expect(
          await vault.verifyPassphrase(
            passphrase: passphrase,
            checkValue: checkValue,
          ),
          isTrue,
        );
        expect(
          await vault.verifyPassphrase(
            passphrase: 'WrongPassphrase!',
            checkValue: checkValue,
          ),
          isFalse,
        );

        // Domain-separated AAD ensures a normal encrypted payload with the
        // canary string cannot impersonate a check value.
        final forgedCheck = await vault.encryptWithPassphrase(
          plaintext: 'jobprep:vault:passphrase-check:v1',
          passphrase: passphrase,
        );
        expect(
          await vault.verifyPassphrase(
            passphrase: passphrase,
            checkValue: forgedCheck,
          ),
          isFalse,
        );
      },
    );

    test(
      'unlock() validates against check value before retaining keys in memory',
      () async {
        final vault = VaultService();
        const passphrase = 'MyMasterVaultPass!99';
        final checkValue = await vault.createCheckValue(passphrase);

        expect(
          await vault.unlock(
            passphrase: 'WrongPassphrase!',
            checkValue: checkValue,
          ),
          isFalse,
        );
        expect(vault.isUnlocked, isFalse);

        expect(
          await vault.unlock(passphrase: passphrase, checkValue: checkValue),
          isTrue,
        );
        expect(vault.isUnlocked, isTrue);
        expect(vault.cachedKeyCount, 1);
      },
    );

    test('lock() zeroes cached keys and blocks subsequent encrypt/decrypt',
        () async {
      final vault = VaultService();
      await vault.unlock(passphrase: 'session-lock-passphrase');
      final payload = await vault.encrypt('portal-credential');

      expect(vault.isUnlocked, isTrue);
      expect(vault.cachedKeyCount, 1);

      vault.lock();

      expect(vault.isUnlocked, isFalse);
      expect(vault.cachedKeyCount, 0);
      await expectLater(
        vault.encrypt('new-secret'),
        throwsA(isA<VaultLockedException>()),
      );
      await expectLater(
        vault.decrypt(payload),
        throwsA(isA<VaultLockedException>()),
      );
    });

    test('vaultSessionProvider locks and wipes keys on sign-out or user change',
        () async {
      final authRepo = FakeAuthRepository.authenticated(
        const AuthUser(
          id: 'user-a',
          email: 'a@example.com',
          emailConfirmed: true,
        ),
      );
      addTearDown(authRepo.dispose);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      container.listen(vaultSessionProvider, (_, __) {});
      final notifier = container.read(vaultSessionProvider.notifier);
      final service = container.read(vaultServiceProvider);

      expect(container.read(vaultSessionProvider).isUnlocked, isFalse);

      final unlocked = await notifier.unlock(passphrase: 'riverpod-vault-pass');
      expect(unlocked, isTrue);
      await service.encrypt('cached-secret');
      expect(container.read(vaultSessionProvider).isUnlocked, isTrue);
      expect(service.isUnlocked, isTrue);
      expect(service.cachedKeyCount, 1);

      // Signing out wipes in-memory passphrase & keys immediately.
      await authRepo.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(vaultSessionProvider).isUnlocked, isFalse);
      expect(service.isUnlocked, isFalse);
      expect(service.cachedKeyCount, 0);

      // Switching signed-in user also clears any prior session keys.
      authRepo.emitSession(
        const AuthSessionState.signedIn(
          AuthUser(
            id: 'user-a',
            email: 'a@example.com',
            emailConfirmed: true,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await notifier.unlock(passphrase: 'user-a-pass');
      expect(service.isUnlocked, isTrue);

      authRepo.emitSession(
        const AuthSessionState.signedIn(
          AuthUser(
            id: 'user-b',
            email: 'b@example.com',
            emailConfirmed: true,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(container.read(vaultSessionProvider).isUnlocked, isFalse);
      expect(service.isUnlocked, isFalse);
      expect(service.cachedKeyCount, 0);
    });
  });
}
