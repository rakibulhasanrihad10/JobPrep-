import 'dart:convert';
import 'dart:typed_data';

import 'package:job_prep/features/settings/domain/utils/data_export_csv.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_json.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_snapshot.dart';

export 'package:job_prep/features/settings/domain/utils/data_export_snapshot.dart';

/// Pure utility encoding user circulars and study progress snapshots to pretty
/// JSON or RFC-4180 CSV bytes ready for file download.
abstract final class DataExportBuilder {
  /// Converts [snapshot] to formatted UTF-8 JSON text.
  static String toJsonString(DataExportSnapshot snapshot) {
    return const JsonEncoder.withIndent('  ')
        .convert(DataExportJson.buildMap(snapshot));
  }

  /// Converts [snapshot] to RFC-4180 CSV text.
  static String toCsvString(DataExportSnapshot snapshot) {
    return DataExportCsv.build(snapshot);
  }

  /// Builds formatted string payload for [format].
  static String buildContent(
    DataExportSnapshot snapshot,
    DataExportFormat format,
  ) {
    return switch (format) {
      DataExportFormat.csv => toCsvString(snapshot),
      DataExportFormat.json => toJsonString(snapshot),
    };
  }

  /// Encodes [snapshot] in [format] as UTF-8 bytes (`Uint8List`).
  static Uint8List buildBytes(
    DataExportSnapshot snapshot,
    DataExportFormat format,
  ) {
    return Uint8List.fromList(utf8.encode(buildContent(snapshot, format)));
  }

  /// Generates a deterministic timestamped filename like
  /// `jobprep-export-2026-11-12.csv`.
  static String buildFileName(
    DateTime now,
    DataExportFormat format,
  ) {
    final utc = now.toUtc();
    final yyyy = utc.year.toString().padLeft(4, '0');
    final mm = utc.month.toString().padLeft(2, '0');
    final dd = utc.day.toString().padLeft(2, '0');
    return 'jobprep-export-$yyyy-$mm-$dd.${format.extension}';
  }
}
