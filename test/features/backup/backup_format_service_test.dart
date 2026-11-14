import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/services/backup_format_service.dart';

void main() {
  group('BackupFormatService', () {
    test('createManifest generates valid manifest with correct checksum', () {
      const tables = BackupDataTables(
        subjects: [
          {'id': 'sub-1', 'name': 'Bangla', 'color_hex': '#123456'},
        ],
      );

      final manifest = BackupFormatService.createManifest(
        tables: tables,
        appVersion: '0.1.0+1',
      );

      expect(manifest.format, BackupManifest.formatIdentifier);
      expect(manifest.schemaVersion, 1);
      expect(manifest.appVersion, '0.1.0+1');
      expect(manifest.data.subjects.length, 1);
      expect(manifest.checksum.isNotEmpty, isTrue);

      // Verifying checksum matches tables payload
      final expectedChecksum =
          BackupFormatService.computeChecksum(manifest.data);
      expect(manifest.checksum, equals(expectedChecksum));
    });

    test('validateRawBytes approves valid unencrypted manifest', () async {
      final manifest = BackupFormatService.createManifest(
        tables: const BackupDataTables(),
        appVersion: '0.1.0+1',
      );
      final bytes = Uint8List.fromList(utf8.encode(manifest.toJsonString()));

      final result = await BackupFormatService.validateRawBytes(
        bytes,
        currentAppVersion: '0.1.0+1',
      );

      expect(result.isValid, isTrue);
      expect(result.isEncrypted, isFalse);
      expect(result.manifest, isNotNull);
      expect(result.errorMessage, isNull);
    });

    test('validateRawBytes rejects payload exceeding 25 MB', () async {
      final oversizedBytes = Uint8List(26 * 1024 * 1024);

      final result = await BackupFormatService.validateRawBytes(oversizedBytes);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'file_too_large');
    });

    test('validateRawBytes rejects tampered data payload (checksum mismatch)',
        () async {
      final manifest = BackupFormatService.createManifest(
        tables: const BackupDataTables(),
        appVersion: '0.1.0+1',
      );

      // Manually tamper the JSON string so checksum doesn't match
      final tamperedJson = manifest.toJsonString().replaceFirst(
            '"subjects":[]',
            '"subjects":[{"id":"injected"}]',
          );
      final bytes = Uint8List.fromList(utf8.encode(tamperedJson));

      final result = await BackupFormatService.validateRawBytes(bytes);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'checksum_mismatch');
    });

    test('validateRawBytes rejects manifest from newer app version', () async {
      final manifest = BackupFormatService.createManifest(
        tables: const BackupDataTables(),
        appVersion: '1.5.0',
      );
      final bytes = Uint8List.fromList(utf8.encode(manifest.toJsonString()));

      final result = await BackupFormatService.validateRawBytes(
        bytes,
        currentAppVersion: '0.1.0+1',
      );

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'newer_version');
    });

    test(
        'validateRawBytes recognizes encrypted envelope and flags for '
        'passphrase', () async {
      final envelope = BackupCryptoEnvelope(
        schemaVersion: 1,
        appVersion: '0.1.0',
        exportedAt: DateTime.now().toUtc(),
        salt: 'fakeSalt==',
        nonce: 'fakeNonce==',
        mac: 'fakeMac==',
        ciphertext: 'fakeCiphertext==',
      );
      final bytes = Uint8List.fromList(utf8.encode(envelope.toJsonString()));

      final result = await BackupFormatService.validateRawBytes(bytes);

      expect(result.isEncrypted, isTrue);
      expect(result.envelope, isNotNull);
    });

    test(
        'migrateOlderSchema upgrades schema v0 by backfilling progress_logs '
        'entry_type', () {
      final v0Data = {
        'format': 'jobprep_backup',
        'schemaVersion': 0,
        'appVersion': '0.0.9',
        'exportedAt': '2026-11-01T00:00:00.000Z',
        'checksum': 'any',
        'data': {
          'subjects': <Map<String, dynamic>>[],
          'materials': <Map<String, dynamic>>[],
          'progress_logs': [
            {
              'id': 'log-1',
              'material_id': 'mat-1',
              'units_completed': 20,
              'created_at': '2026-11-01T10:00:00.000Z',
            }
          ],
        },
      };

      final migrated = BackupFormatService.migrateOlderSchema(
        v0Data['data']! as Map<String, dynamic>,
        0,
      );
      expect(migrated.progressLogs.first['entry_type'], 'increment');
    });
  });
}
