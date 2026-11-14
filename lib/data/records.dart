import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

/// Generic synced store for the "extra" business data (suppliers, purchases,
/// expenses, estimates, item details, staff notes ...). One table, no code
/// generation: each row is `kind` + a JSON document.
const kCreateAppRecordsSql = '''
CREATE TABLE IF NOT EXISTS app_records (
  id TEXT NOT NULL PRIMARY KEY,
  business_id TEXT NOT NULL,
  kind TEXT NOT NULL,
  data TEXT NOT NULL,
  deleted INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  server_seq INTEGER
)''';

const kCreateAppRecordsIndexSql =
    'CREATE INDEX IF NOT EXISTS idx_app_records_kind ON app_records (business_id, kind)';

class AppRecord {
  const AppRecord({
    required this.id,
    required this.kind,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String kind;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  String str(String k, [String d = '']) => (data[k] as String?) ?? d;
  int integer(String k, [int d = 0]) => (data[k] as num?)?.toInt() ?? d;
}

class RecordKinds {
  static const supplier = 'supplier';
  static const purchase = 'purchase';
  static const expense = 'expense';
  static const estimate = 'estimate';
  static const itemMeta = 'item_meta'; // id == product id
  static const supplierPayment = 'supplier_payment';
  static const activity = 'activity';
}

class RecordsRepository {
  RecordsRepository(this.db, this.businessId, this.deviceId);

  final AppDatabase db;
  final String businessId;
  final String deviceId;

  static AppRecord _fromRow(Map<String, Object?> r) => AppRecord(
        id: r['id'] as String,
        kind: r['kind'] as String,
        data: (jsonDecode(r['data'] as String) as Map).cast<String, dynamic>(),
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(r['updated_at'] as String).toLocal(),
      );

  /// Newest first.
  Future<List<AppRecord>> list(String kind, {bool newestFirst = true}) async {
    final rows = await db.customSelect(
      'SELECT * FROM app_records WHERE business_id = ? AND kind = ? AND deleted = 0 '
      'ORDER BY created_at ${newestFirst ? 'DESC' : 'ASC'}',
      variables: [_v(businessId), _v(kind)],
    ).get();
    return rows.map((r) => _fromRow(r.data)).toList();
  }

  Future<AppRecord?> get(String id) async {
    final rows = await db.customSelect(
      'SELECT * FROM app_records WHERE id = ? AND business_id = ? AND deleted = 0',
      variables: [_v(id), _v(businessId)],
    ).get();
    return rows.isEmpty ? null : _fromRow(rows.first.data);
  }

  /// Insert or replace a record and queue it for sync. Returns its id.
  Future<String> save(String kind, Map<String, dynamic> data, {String? id, DateTime? createdAt}) async {
    final rid = id ?? const Uuid().v4();
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      final existing = await db.customSelect(
        'SELECT created_at FROM app_records WHERE id = ?',
        variables: [_v(rid)],
      ).get();
      final created = existing.isNotEmpty
          ? existing.first.data['created_at'] as String
          : (createdAt ?? now).toUtc().toIso8601String();
      await db.customStatement(
        'INSERT OR REPLACE INTO app_records (id, business_id, kind, data, deleted, created_at, updated_at, server_seq) '
        'VALUES (?, ?, ?, ?, 0, ?, ?, NULL)',
        [rid, businessId, kind, jsonEncode(data), created, now.toIso8601String()],
      );
      await _enqueue(rid);
    });
    return rid;
  }

  Future<void> remove(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction(() async {
      await db.customStatement(
        'UPDATE app_records SET deleted = 1, updated_at = ? WHERE id = ? AND business_id = ?',
        [now, id, businessId],
      );
      await _enqueue(id);
    });
  }

  Future<void> _enqueue(String id) => db.enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'push_record',
        payload: {'record_id': id},
      );

  /// Payload for the server row (also used by the push worker).
  static Future<Map<String, dynamic>?> payloadFor(AppDatabase db, String id) async {
    final rows = await db.customSelect('SELECT * FROM app_records WHERE id = ?', variables: [_v(id)]).get();
    if (rows.isEmpty) return null;
    final r = rows.first.data;
    return {
      'id': r['id'],
      'business_id': r['business_id'],
      'kind': r['kind'],
      'data': jsonDecode(r['data'] as String),
      'deleted': (r['deleted'] as int) == 1,
      'created_at': r['created_at'],
      'updated_at': r['updated_at'],
    };
  }

  /// Applies a server row (pull). Last writer wins on updated_at.
  static Future<void> applyServerRow(AppDatabase db, Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final serverUpdated = DateTime.parse(r['updated_at'] as String).toUtc();
    final local = await db.customSelect('SELECT updated_at FROM app_records WHERE id = ?', variables: [_v(id)]).get();
    if (local.isNotEmpty) {
      final localUpdated = DateTime.parse(local.first.data['updated_at'] as String).toUtc();
      if (localUpdated.isAfter(serverUpdated)) return; // newer local edit not yet pushed
    }
    final data = r['data'];
    await db.customStatement(
      'INSERT OR REPLACE INTO app_records (id, business_id, kind, data, deleted, created_at, updated_at, server_seq) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        r['business_id'],
        r['kind'],
        data is String ? data : jsonEncode(data),
        (r['deleted'] == true) ? 1 : 0,
        DateTime.parse(r['created_at'] as String).toUtc().toIso8601String(),
        serverUpdated.toIso8601String(),
        (r['server_seq'] as num?)?.toInt(),
      ],
    );
  }
}

Variable<String> _v(String s) => Variable<String>(s);
