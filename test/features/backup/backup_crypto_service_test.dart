import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';
import 'package:job_prep/features/backup/domain/services/backup_crypto_service.dart';

void main() {
  group('BackupCryptoService', () {
    const plainPayload =
        '{"schemaVersion":1,"data":{"subjects":[{"id":"s1"}]}}';
    const testPassphrase = 'MyStrongPassword123!';

    test('encrypts and decrypts payload correctly (round-trip)', () async {
      final envelope = await BackupCryptoService.encrypt(
        plainJson: plainPayload,
        passphrase: testPassphrase,
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.utc(2026, 11, 14, 12),
      );

      expect(envelope.format, BackupCryptoEnvelope.formatIdentifier);
      expect(envelope.salt.isNotEmpty, isTrue);
      expect(envelope.nonce.isNotEmpty, isTrue);
      expect(envelope.mac.isNotEmpty, isTrue);
      expect(envelope.ciphertext.isNotEmpty, isTrue);
      expect(envelope.ciphertext, isNot(equals(plainPayload)));

      final decrypted = await BackupCryptoService.decrypt(
        envelope: envelope,
        passphrase: testPassphrase,
      );

      expect(decrypted, equals(plainPayload));
    });

    test('generates unique salt and nonce on consecutive calls', () async {
      final env1 = await BackupCryptoService.encrypt(
        plainJson: plainPayload,
        passphrase: testPassphrase,
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.now().toUtc(),
      );

      final env2 = await BackupCryptoService.encrypt(
        plainJson: plainPayload,
        passphrase: testPassphrase,
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.now().toUtc(),
      );

      expect(env1.salt, isNot(equals(env2.salt)));
      expect(env1.nonce, isNot(equals(env2.nonce)));
    });

    test('wrong passphrase fails with BackupDecryptionFailure', () async {
      final envelope = await BackupCryptoService.encrypt(
        plainJson: plainPayload,
        passphrase: testPassphrase,
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.now().toUtc(),
      );

      expect(
        () => BackupCryptoService.decrypt(
          envelope: envelope,
          passphrase: 'WrongPassword456!',
        ),
        throwsA(isA<BackupDecryptionFailure>()),
      );
    });

    test('tampered ciphertext fails decryption', () async {
      final envelope = await BackupCryptoService.encrypt(
        plainJson: plainPayload,
        passphrase: testPassphrase,
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.now().toUtc(),
      );

      // Corrupt the ciphertext by flipping a character
      final tamperedCiphertext = envelope.ciphertext.startsWith('A')
          ? 'B${envelope.ciphertext.substring(1)}'
          : 'A${envelope.ciphertext.substring(1)}';

      final tamperedEnvelope = BackupCryptoEnvelope(
        schemaVersion: envelope.schemaVersion,
        appVersion: envelope.appVersion,
        exportedAt: envelope.exportedAt,
        salt: envelope.salt,
        nonce: envelope.nonce,
        mac: envelope.mac,
        ciphertext: tamperedCiphertext,
      );

      expect(
        () => BackupCryptoService.decrypt(
          envelope: tamperedEnvelope,
          passphrase: testPassphrase,
        ),
        throwsA(isA<BackupDecryptionFailure>()),
      );
    });

    test('tampered MAC authentication tag fails decryption', () async {
      final envelope = await BackupCryptoService.encrypt(
        plainJson: plainPayload,
        passphrase: testPassphrase,
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.now().toUtc(),
      );

      final tamperedMac = envelope.mac.startsWith('A')
          ? 'B${envelope.mac.substring(1)}'
          : 'A${envelope.mac.substring(1)}';

      final tamperedEnvelope = BackupCryptoEnvelope(
        schemaVersion: envelope.schemaVersion,
        appVersion: envelope.appVersion,
        exportedAt: envelope.exportedAt,
        salt: envelope.salt,
        nonce: envelope.nonce,
        mac: tamperedMac,
        ciphertext: envelope.ciphertext,
      );

      expect(
        () => BackupCryptoService.decrypt(
          envelope: tamperedEnvelope,
          passphrase: testPassphrase,
        ),
        throwsA(isA<BackupDecryptionFailure>()),
      );
    });
  });
}
