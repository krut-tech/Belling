import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../data/database.dart';

/// Read side of sync: returns server rows with `server_seq > afterSeq`,
/// ordered by `server_seq`. Implemented by SupabaseSyncRemote; faked in tests.
abstract class PullRemote {
  bool get canPull;

  Future<List<Map<String, dynamic>>> fetchChanges({
    required String table,
    required String businessId,
    required int afterSeq,
    required int limit,
  });
}

/// Order matters: parents before children.
const kPullTables = <String>[
  'businesses',
  'devices',
  'parties',
  'products',
  'documents',
  'document_lines',
  'payments',
  'stock_movements',
];

const kPullPageSize = 500;

class PullResult {
  final int rowsApplied;
  const PullResult(this.rowsApplied);
}

/// Pulls changes made on other devices / before a reinstall into the local DB.
///
/// * Mutable tables (businesses, devices, parties, products): last-writer-wins
///   on `updated_at`, so a newer local (not yet pushed) edit is never lost.
/// * Append-only tables (documents, lines, payments, stock): insert-or-ignore;
///   rows already present locally are untouched. A server-side cancel flips a
///   local issued document to cancelled (the only change the local trigger
///   allows).
class PullService {
  PullService(this.db, this.remote);

  final AppDatabase db;
  final PullRemote remote;

  bool _running = false;

  Future<PullResult> pullAll() async {
    if (_running || !remote.canPull) return const PullResult(0);
    _running = true;
    var applied = 0;
    try {
      final business = await (db.select(db.businesses)..limit(1)).getSingleOrNull();
      if (business == null) return const PullResult(0);

      for (final table in kPullTables) {
        var cursor = await _getCursor(table);
        while (true) {
          final rows = await remote.fetchChanges(
            table: table,
            businessId: business.id,
            afterSeq: cursor,
            limit: kPullPageSize,
          );
          if (rows.isEmpty) break;

          var maxSeq = cursor;
          await db.transaction(() async {
            await db.customStatement('PRAGMA defer_foreign_keys = ON;');
            for (final row in rows) {
              await _apply(table, row);
              final seq = _int(row['server_seq']);
              if (seq > maxSeq) maxSeq = seq;
              applied++;
            }
            await _setCursor(table, maxSeq);
          });

          if (maxSeq <= cursor) break; // defensive: never loop forever
          cursor = maxSeq;
          if (rows.length < kPullPageSize) break;
        }
      }
    } finally {
      _running = false;
    }
    return PullResult(applied);
  }

  Future<int> _getCursor(String table) async {
    final row = await (db.select(db.syncStateTable)..where((t) => t.tableNameCol.equals(table))).getSingleOrNull();
    return row?.lastSeq ?? 0;
  }

  Future<void> _setCursor(String table, int seq) async {
    await db.into(db.syncStateTable).insertOnConflictUpdate(
          SyncStateTableCompanion(tableNameCol: Value(table), lastSeq: Value(seq)),
        );
  }

  Future<void> _apply(String table, Map<String, dynamic> r) async {
    switch (table) {
      case 'businesses':
        return _applyBusiness(r);
      case 'devices':
        return _applyDevice(r);
      case 'parties':
        return _applyParty(r);
      case 'products':
        return _applyProduct(r);
      case 'documents':
        return _applyDocument(r);
      case 'document_lines':
        return _applyLine(r);
      case 'payments':
        return _applyPayment(r);
      case 'stock_movements':
        return _applyStock(r);
    }
  }

  // ---------------- mutable tables (last writer wins) ----------------

  Future<void> _applyBusiness(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final existing = await (db.select(db.businesses)..where((t) => t.id.equals(id))).getSingleOrNull();
    final serverUpdated = _dt(r['updated_at']);
    if (existing != null && !serverUpdated.isAfter(existing.updatedAt)) {
      return;
    }
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion(
          id: Value(id),
          businessId: Value(id),
          name: Value(r['name'] as String),
          gstin: Value(r['gstin'] as String?),
          stateCode: Value((r['state_code'] as String?) ?? '24'),
          address: Value((r['address'] as String?) ?? ''),
          upiId: Value(r['upi_id'] as String?),
          invoiceTerms: Value(r['invoice_terms'] as String?),
          createdAt: Value(_dt(r['created_at'])),
          updatedAt: Value(serverUpdated),
          serverSeq: Value(_int(r['server_seq'])),
        ));
  }

  Future<void> _applyDevice(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final existing = await (db.select(db.devices)..where((t) => t.id.equals(id))).getSingleOrNull();
    final serverUpdated = _dt(r['updated_at']);
    if (existing != null && !serverUpdated.isAfter(existing.updatedAt)) return;
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion(
          id: Value(id),
          businessId: Value(r['business_id'] as String),
          name: Value(r['name'] as String),
          seriesPrefix: Value(r['series_prefix'] as String),
          createdAt: Value(_dt(r['created_at'])),
          updatedAt: Value(serverUpdated),
          serverSeq: Value(_int(r['server_seq'])),
        ));
  }

  Future<void> _applyParty(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final existing = await (db.select(db.parties)..where((t) => t.id.equals(id))).getSingleOrNull();
    final serverUpdated = _dt(r['updated_at']);
    if (existing != null && !serverUpdated.isAfter(existing.updatedAt)) return;
    await db.into(db.parties).insertOnConflictUpdate(PartiesCompanion(
          id: Value(id),
          businessId: Value(r['business_id'] as String),
          name: Value(r['name'] as String),
          phone: Value((r['phone'] as String?) ?? ''),
          gstin: Value(r['gstin'] as String?),
          stateCode: Value((r['state_code'] as String?) ?? '24'),
          creditLimitPaise: Value(_int(r['credit_limit_paise'])),
          createdAt: Value(_dt(r['created_at'])),
          updatedAt: Value(serverUpdated),
          archivedAt: Value(r['archived_at'] == null ? null : _dt(r['archived_at'])),
          serverSeq: Value(_int(r['server_seq'])),
        ));
  }

  Future<void> _applyProduct(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final existing = await (db.select(db.products)..where((t) => t.id.equals(id))).getSingleOrNull();
    final serverUpdated = _dt(r['updated_at']);
    if (existing != null && !serverUpdated.isAfter(existing.updatedAt)) return;
    await db.into(db.products).insertOnConflictUpdate(ProductsCompanion(
          id: Value(id),
          businessId: Value(r['business_id'] as String),
          name: Value(r['name'] as String),
          barcode: Value(r['barcode'] as String?),
          hsn: Value((r['hsn'] as String?) ?? ''),
          gstRateBp: Value(_int(r['gst_rate_bp'])),
          pricePaise: Value(_int(r['price_paise'])),
          costPaise: Value(_int(r['cost_paise'])),
          trackStock: Value((r['track_stock'] as bool?) ?? false),
          reorderLevel: Value(_int(r['reorder_level'])),
          createdAt: Value(_dt(r['created_at'])),
          updatedAt: Value(serverUpdated),
          serverSeq: Value(_int(r['server_seq'])),
        ));
  }

  // ---------------- append-only tables ----------------

  Future<void> _applyDocument(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final existing = await (db.select(db.documents)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) {
      final snapshot = r['snapshot_json'];
      await db.into(db.documents).insert(
            DocumentsCompanion(
              id: Value(id),
              businessId: Value(r['business_id'] as String),
              deviceId: Value(r['device_id'] as String),
              docType: Value(r['doc_type'] as String),
              number: Value(r['number'] as String),
              partyId: Value(r['party_id'] as String?),
              issuedAt: Value(_dt(r['issued_at'])),
              status: Value(r['status'] as String),
              taxablePaise: Value(_int(r['taxable_paise'])),
              cgstPaise: Value(_int(r['cgst_paise'])),
              sgstPaise: Value(_int(r['sgst_paise'])),
              igstPaise: Value(_int(r['igst_paise'])),
              roundOffPaise: Value(_int(r['round_off_paise'])),
              totalPaise: Value(_int(r['total_paise'])),
              snapshotJson: Value(snapshot == null
                  ? '{}'
                  : (snapshot is String ? snapshot : _encode(snapshot))),
              refDocumentId: Value(r['ref_document_id'] as String?),
              createdAt: Value(_dt(r['created_at'])),
              serverSeq: Value(_int(r['server_seq'])),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return;
    }
    // Cancelled on another device: the only allowed change to an issued doc.
    if (existing.status == 'issued' && r['status'] == 'cancelled') {
      await (db.update(db.documents)..where((t) => t.id.equals(id)))
          .write(const DocumentsCompanion(status: Value('cancelled')));
    }
  }

  Future<void> _applyLine(Map<String, dynamic> r) async {
    await db.into(db.documentLines).insert(
          DocumentLinesCompanion(
            id: Value(r['id'] as String),
            documentId: Value(r['document_id'] as String),
            businessId: Value(r['business_id'] as String),
            productId: Value(r['product_id'] as String),
            name: Value(r['name'] as String),
            hsn: Value((r['hsn'] as String?) ?? ''),
            qtyMilli: Value(_int(r['qty_milli'])),
            ratePaise: Value(_int(r['rate_paise'])),
            discountPaise: Value(_int(r['discount_paise'])),
            gstRateBp: Value(_int(r['gst_rate_bp'])),
            taxablePaise: Value(_int(r['taxable_paise'])),
            cgstPaise: Value(_int(r['cgst_paise'])),
            sgstPaise: Value(_int(r['sgst_paise'])),
            igstPaise: Value(_int(r['igst_paise'])),
            lineTotalPaise: Value(_int(r['line_total_paise'])),
            createdAt: Value(_dt(r['created_at'])),
            serverSeq: Value(_int(r['server_seq'])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _applyPayment(Map<String, dynamic> r) async {
    await db.into(db.payments).insert(
          PaymentsCompanion(
            id: Value(r['id'] as String),
            businessId: Value(r['business_id'] as String),
            documentId: Value(r['document_id'] as String?),
            partyId: Value(r['party_id'] as String?),
            method: Value(r['method'] as String),
            amountPaise: Value(_int(r['amount_paise'])),
            note: Value(r['note'] as String?),
            paidAt: Value(_dt(r['paid_at'])),
            createdAt: Value(_dt(r['created_at'])),
            serverSeq: Value(_int(r['server_seq'])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _applyStock(Map<String, dynamic> r) async {
    await db.into(db.stockMovements).insert(
          StockMovementsCompanion(
            id: Value(r['id'] as String),
            businessId: Value(r['business_id'] as String),
            productId: Value(r['product_id'] as String),
            qtyMilli: Value(_int(r['qty_milli'])),
            reason: Value(r['reason'] as String),
            documentId: Value(r['document_id'] as String?),
            createdAt: Value(_dt(r['created_at'])),
            serverSeq: Value(_int(r['server_seq'])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  // ---------------- helpers ----------------

  static int _int(dynamic v) => v == null ? 0 : (v as num).toInt();

  static DateTime _dt(dynamic v) => DateTime.parse(v as String).toLocal();

  static String _encode(Object v) => jsonEncode(v);
}

/// Runs [PullService] on start, after sign-in, when connectivity returns, every
/// few minutes, and on demand ([pullNow]).
class PullWorker {
  PullWorker({
    required this.service,
    this.triggers = const <Stream<void>>[],
    this.interval = const Duration(minutes: 3),
  });

  final PullService service;
  final List<Stream<void>> triggers;
  final Duration interval;

  Timer? _timer;
  Timer? _debounce;
  final List<StreamSubscription<void>> _subs = [];
  final StreamController<PullResult> _results = StreamController<PullResult>.broadcast();

  Stream<PullResult> get results => _results.stream;

  void start() {
    for (final t in triggers) {
      _subs.add(t.listen((_) => pullSoon()));
    }
    _timer = Timer.periodic(interval, (_) => pullNow());
    pullSoon();
  }

  void pullSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), pullNow);
  }

  Future<PullResult?> pullNow() async {
    try {
      final r = await service.pullAll();
      if (!_results.isClosed) _results.add(r);
      return r;
    } catch (e) {
      // Offline / not signed in / server hiccup: try again on the next trigger.
      debugPrint('Pull sync skipped: $e');
      return null;
    }
  }

  void stop() {
    _timer?.cancel();
    _debounce?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _results.close();
  }
}
