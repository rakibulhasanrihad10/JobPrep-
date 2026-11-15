import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

export 'mock_supabase_client.dart';

/// In-memory HTTP mock client simulating Supabase PostgREST for repository
/// contract testing without a live network connection.
class MockSupabaseHttpClient extends http.BaseClient {
  MockSupabaseHttpClient({this.currentUserId = 'mock-user-1111'});

  final String currentUserId;
  final Map<String, List<Map<String, dynamic>>> tables = {};

  void clear() {
    tables.clear();
  }

  Map<String, dynamic> _hydrateRow(String table, Map<String, dynamic> raw) {
    final copy = Map<String, dynamic>.from(raw);
    final nowIso = DateTime.now().toUtc().toIso8601String();
    copy
      ..putIfAbsent('id', () => const Uuid().v4())
      ..putIfAbsent('user_id', () => currentUserId)
      ..putIfAbsent('created_at', () => nowIso)
      ..putIfAbsent('updated_at', () => nowIso);

    if (table == 'circulars') {
      final examDates = tables['circular_exam_dates'] ?? [];
      final files = tables['circular_files'] ?? [];
      copy['circular_exam_dates'] = examDates
          .where((e) => e['circular_id'] == copy['id'])
          .map(Map<String, dynamic>.from)
          .toList();
      copy['circular_files'] = files
          .where((f) => f['circular_id'] == copy['id'])
          .map(Map<String, dynamic>.from)
          .toList();
    }
    return copy;
  }

  bool _matchesFilter(Map<String, dynamic> row, String key, String filter) {
    if (filter.startsWith('eq.')) {
      final target = filter.substring(3);
      return '${row[key]}' == target;
    } else if (filter.startsWith('neq.')) {
      final target = filter.substring(4);
      return '${row[key]}' != target;
    } else if (filter == 'is.null') {
      return row[key] == null;
    }
    return true;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final segments = request.url.pathSegments;
    final tableIndex = segments.indexOf('v1');
    final tableName = tableIndex != -1 && tableIndex + 1 < segments.length
        ? segments[tableIndex + 1]
        : segments.last;

    tables.putIfAbsent(tableName, () => <Map<String, dynamic>>[]);
    final tableRows = tables[tableName]!;

    final queryParams = request.url.queryParameters;
    final method = request.method.toUpperCase();
    final acceptHeader = request.headers['accept'] ?? '';
    final preferHeader = request.headers['prefer'] ?? '';
    final wantsSingleObject = acceptHeader.contains('vnd.pgrst.object+json');
    final isMinimal = preferHeader.contains('return=minimal');

    if (method == 'GET') {
      var rows = List<Map<String, dynamic>>.from(tableRows);

      for (final entry in queryParams.entries) {
        final key = entry.key;
        final value = entry.value;
        rows = rows.where((r) => _matchesFilter(r, key, value)).toList();
      }

      final order = queryParams['order'];
      if (order != null) {
        final parts = order.split('.');
        final col = parts.first;
        final isAsc = parts.contains('asc');
        rows.sort((a, b) {
          final va = a[col];
          final vb = b[col];
          if (va == null && vb == null) return 0;
          if (va == null) return isAsc ? 1 : -1;
          if (vb == null) return isAsc ? -1 : 1;
          final cmp = Comparable.compare(
            va is Comparable ? va : va.toString(),
            vb is Comparable ? vb : vb.toString(),
          );
          return isAsc ? cmp : -cmp;
        });
      }

      final limitStr = queryParams['limit'];
      if (limitStr != null) {
        final limit = int.tryParse(limitStr) ?? rows.length;
        if (rows.length > limit) {
          rows = rows.sublist(0, limit);
        }
      }

      final hydrated = rows.map((r) => _hydrateRow(tableName, r)).toList();

      final dynamic responseBody;
      if (wantsSingleObject) {
        responseBody = hydrated.isNotEmpty ? hydrated.first : null;
      } else {
        responseBody = hydrated;
      }

      final body = jsonEncode(responseBody);
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    }

    if (method == 'POST') {
      final bodyBytes = await request.finalize().toBytes();
      final bodyStr = utf8.decode(bodyBytes);
      final decoded = jsonDecode(bodyStr);

      final toInsert = <Map<String, dynamic>>[];
      if (decoded is List) {
        for (final item in decoded) {
          toInsert.add(Map<String, dynamic>.from(item as Map));
        }
      } else if (decoded is Map) {
        toInsert.add(Map<String, dynamic>.from(decoded));
      }

      final results = <Map<String, dynamic>>[];
      for (final row in toInsert) {
        final id = row['id'];
        final existingIndex =
            id != null ? tableRows.indexWhere((r) => r['id'] == id) : -1;

        if (existingIndex != -1) {
          tableRows[existingIndex].addAll(row);
          results.add(_hydrateRow(tableName, tableRows[existingIndex]));
        } else {
          final hydrated = _hydrateRow(tableName, row);
          tableRows.add(hydrated);
          results.add(hydrated);
        }
      }

      if (tableName == 'progress_logs') {
        _triggerRecalculateMaterialCompletedUnits();
      }

      if (isMinimal) {
        return http.StreamedResponse(
          const Stream.empty(),
          201,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }

      final dynamic responseBody;
      if (wantsSingleObject) {
        responseBody = results.isNotEmpty ? results.first : <String, dynamic>{};
      } else {
        responseBody = results;
      }

      final resBody = jsonEncode(responseBody);
      return http.StreamedResponse(
        Stream.value(utf8.encode(resBody)),
        201,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    }

    if (method == 'PATCH') {
      final bodyBytes = await request.finalize().toBytes();
      final bodyStr = utf8.decode(bodyBytes);
      final patchData = Map<String, dynamic>.from(jsonDecode(bodyStr) as Map);

      final matched = <Map<String, dynamic>>[];
      for (var i = 0; i < tableRows.length; i++) {
        var matches = true;
        for (final entry in queryParams.entries) {
          if (!_matchesFilter(tableRows[i], entry.key, entry.value)) {
            matches = false;
            break;
          }
        }
        if (matches) {
          final updated = Map<String, dynamic>.from(tableRows[i])
            ..addAll(patchData);
          tableRows[i] = updated;
          matched.add(updated);
        }
      }

      if (tableName == 'progress_logs') {
        _triggerRecalculateMaterialCompletedUnits();
      }

      if (isMinimal) {
        return http.StreamedResponse(
          const Stream.empty(),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }

      final hydrated = matched.map((r) => _hydrateRow(tableName, r)).toList();
      final dynamic responseBody;
      if (wantsSingleObject) {
        responseBody =
            hydrated.isNotEmpty ? hydrated.first : <String, dynamic>{};
      } else {
        responseBody = hydrated;
      }

      final resBody = jsonEncode(responseBody);
      return http.StreamedResponse(
        Stream.value(utf8.encode(resBody)),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    }

    if (method == 'DELETE') {
      var toRemove = List<Map<String, dynamic>>.from(tableRows);
      for (final entry in queryParams.entries) {
        final key = entry.key;
        final value = entry.value;
        toRemove =
            toRemove.where((r) => _matchesFilter(r, key, value)).toList();
      }

      toRemove.forEach(tableRows.remove);

      if (tableName == 'progress_logs') {
        _triggerRecalculateMaterialCompletedUnits();
      }

      return http.StreamedResponse(
        const Stream.empty(),
        204,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    }

    return http.StreamedResponse(
      Stream.value(utf8.encode('[]')),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }

  void _triggerRecalculateMaterialCompletedUnits() {
    final materials = tables['materials'] ?? [];
    final logs = tables['progress_logs'] ?? [];

    for (final material in materials) {
      final matId = material['id'];
      final matTotal = (material['total_units'] as num?)?.toInt() ?? 0;
      final matLogs = logs.where((l) => l['material_id'] == matId);
      var sum = 0;
      for (final l in matLogs) {
        sum += (l['units_done'] as num?)?.toInt() ?? 0;
      }
      final clamped = matTotal > 0 ? sum.clamp(0, matTotal) : 0;
      material['completed_units'] = clamped;
    }
  }
}
