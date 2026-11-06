import 'package:belling/data/database.dart';
import 'package:belling/sync/pull_service.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePullRemote implements PullRemote {
  FakePullRemote(this.data);
  final Map<String, List<Map<String, dynamic>>> data;
  bool ready = true;
  int calls = 0;

  @override
  bool get canPull => ready;

  @override
  Future<List<Map<String, dynamic>>> fetchChanges({
    required String table,
    required String businessId,
    required int afterSeq,
    required int limit,
  }) async {
    calls++;
    final rows = (data[table] ?? [])
        .where((r) => (r['server_seq'] as int) > afterSeq)
        .toList()
      ..sort((a, b) => (a['server_seq'] as int).compareTo(b['server_seq'] as int));
    return rows.take(limit).toList();
  }
}

String iso(DateTime d) => d.toUtc().toIso8601String();

void main() {
  late AppDatabase db;
  late String businessId;
  late String deviceId;
  final t0 = DateTime.utc(2026, 11, 1, 10);

  Map<String, dynamic> party(String id, String name, DateTime updated, int seq) => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'phone': '9999999999',
        'gstin': null,
        'state_code': '24',
        'credit_limit_paise': 0,
        'created_at': iso(t0),
        'updated_at': iso(updated),
        'archived_at': null,
        'server_seq': seq,
      };

  Map<String, dynamic> doc(String id, String status, int seq) => {
        'id': id,
        'business_id': businessId,
        'device_id': deviceId,
        'doc_type': 'invoice',
        'number': 'X-1',
        'party_id': 'p1',
        'issued_at': iso(t0),
        'status': status,
        'taxable_paise': 10000,
        'cgst_paise': 900,
        'sgst_paise': 900,
        'igst_paise': 0,
        'round_off_paise': 0,
        'total_paise': 11800,
        'snapshot_json': {'a': 1},
        'ref_document_id': null,
        'created_at': iso(t0),
        'server_seq': seq,
      };

  Map<String, dynamic> product(int seq) => {
        'id': 'pr1',
        'business_id': businessId,
        'name': 'Rice',
        'barcode': '8901234567890',
        'hsn': '1006',
        'gst_rate_bp': 500,
        'price_paise': 10000,
        'cost_paise': 8000,
        'track_stock': true,
        'reorder_level': 0,
        'created_at': iso(t0),
        'updated_at': iso(t0),
        'server_seq': seq,
      };

  Map<String, dynamic> line(int seq) => {
        'id': 'l1',
        'document_id': 'd1',
        'business_id': businessId,
        'product_id': 'pr1',
        'name': 'Rice',
        'hsn': '1006',
        'qty_milli': 1000,
        'rate_paise': 10000,
        'discount_paise': 0,
        'gst_rate_bp': 500,
        'taxable_paise': 10000,
        'cgst_paise': 250,
        'sgst_paise': 250,
        'igst_paise': 0,
        'line_total_paise': 10500,
        'created_at': iso(t0),
        'server_seq': seq,
      };

  Map<String, dynamic> payment(int seq) => {
        'id': 'pay1',
        'business_id': businessId,
        'document_id': 'd1',
        'party_id': 'p1',
        'method': 'cash',
        'amount_paise': 5000,
        'note': null,
        'paid_at': iso(t0),
        'created_at': iso(t0),
        'server_seq': seq,
      };

  Map<String, dynamic> stock(int seq) => {
        'id': 's1',
        'business_id': businessId,
        'product_id': 'pr1',
        'qty_milli': -1000,
        'reason': 'sale',
        'document_id': 'd1',
        'created_at': iso(t0),
        'server_seq': seq,
      };

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureBootstrapData();
    businessId = (await db.select(db.businesses).get()).first.id;
    deviceId = (await db.select(db.devices).get()).first.id;
  });

  tearDown(() async => db.close());

  FakePullRemote fullRemote() => FakePullRemote({
        'parties': [party('p1', 'Ramesh', t0, 1)],
        'products': [product(2)],
        'documents': [doc('d1', 'issued', 3)],
        'document_lines': [line(4)],
        'payments': [payment(5)],
        'stock_movements': [stock(6)],
      });

  test('pulls every table into an empty local database and is idempotent', () async {
    final remote = fullRemote();
    final service = PullService(db, remote);

    final first = await service.pullAll();
    expect(first.rowsApplied, 6);
    expect((await db.select(db.parties).get()).single.name, 'Ramesh');
    expect((await db.select(db.products).get()).single.barcode, '8901234567890');
    final d = (await db.select(db.documents).get()).single;
    expect(d.totalPaise, 11800);
    expect(d.snapshotJson, contains('"a":1'));
    expect((await db.select(db.documentLines).get()).length, 1);
    expect((await db.select(db.payments).get()).single.amountPaise, 5000);
    expect((await db.select(db.stockMovements).get()).single.qtyMilli, -1000);

    // cursor persisted -> nothing re-applied
    final second = await service.pullAll();
    expect(second.rowsApplied, 0);

    // even with a reset cursor, existing append-only rows are not duplicated
    await db.delete(db.syncStateTable).go();
    await PullService(db, remote).pullAll();
    expect((await db.select(db.documents).get()).length, 1);
    expect((await db.select(db.payments).get()).length, 1);
  });

  test('newer local party edit is not overwritten, older one is', () async {
    final service = PullService(db, fullRemote());
    await service.pullAll();

    // local edit newer than server
    await (db.update(db.parties)..where((t) => t.id.equals('p1'))).write(
      PartiesCompanion(name: const Value('Ramesh (local)'), updatedAt: Value(t0.add(const Duration(hours: 5)))),
    );
    final remote = FakePullRemote({
      'parties': [party('p1', 'Ramesh (server old)', t0.add(const Duration(hours: 1)), 10)],
    });
    await PullService(db, remote).pullAll();
    expect((await db.select(db.parties).get()).single.name, 'Ramesh (local)');

    final remote2 = FakePullRemote({
      'parties': [party('p1', 'Ramesh (server new)', t0.add(const Duration(hours: 9)), 11)],
    });
    await db.delete(db.syncStateTable).go();
    await PullService(db, remote2).pullAll();
    expect((await db.select(db.parties).get()).single.name, 'Ramesh (server new)');
  });

  test('a cancel done on another device marks the local invoice cancelled', () async {
    await PullService(db, fullRemote()).pullAll();
    expect((await db.select(db.documents).get()).single.status, 'issued');

    final remote = FakePullRemote({
      'documents': [doc('d1', 'cancelled', 20)],
    });
    await PullService(db, remote).pullAll();
    expect((await db.select(db.documents).get()).single.status, 'cancelled');
  });

  test('does nothing while signed out', () async {
    final remote = fullRemote()..ready = false;
    final r = await PullService(db, remote).pullAll();
    expect(r.rowsApplied, 0);
    expect(remote.calls, 0);
  });
}
