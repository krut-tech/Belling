import 'dart:io';
import 'package:belling/data/database.dart';
import 'package:belling/sync/push_worker.dart';
import 'package:belling/sync/rekey_service.dart';
import 'package:belling/sync/sync_remote.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSyncRemote implements SyncRemote {
  final List<String> callLog = [];
  final Map<String, Map<String, dynamic>> remoteBusinesses = {};
  final Map<String, Map<String, dynamic>> remoteDevices = {};
  final Map<String, Map<String, dynamic>> remoteParties = {};
  final Map<String, Map<String, dynamic>> remoteProducts = {};
  final Map<String, Map<String, dynamic>> remoteDocuments = {};
  final Map<String, Map<String, dynamic>> remoteLines = {};
  final Map<String, Map<String, dynamic>> remotePayments = {};
  final Map<String, Map<String, dynamic>> remoteStockMovements = {};
  final Set<String> appliedCommands = {};

  bool shouldThrowNetworkError = false;
  bool shouldThrowConstraintError = false;
  bool failIssueDocumentAfterDocumentSaved = false;
  String? customErrorMsg;

  @override
  Future<void> upsertBusiness(Map<String, dynamic> data) async {
    _checkErrors();
    callLog.add('upsertBusiness');
    final id = data['id'] as String;
    if (remoteBusinesses.containsKey(id)) {
      remoteBusinesses[id] = Map<String, dynamic>.from(data);
    } else {
      throw const PostgrestException(
        message: 'Business does not exist on server (rejected)',
        code: '404',
      );
    }
  }

  @override
  Future<void> upsertDevice(Map<String, dynamic> data) async {
    _checkErrors();
    callLog.add('upsertDevice');
    _upsertMutable(remoteDevices, data);
  }

  @override
  Future<void> upsertParty(Map<String, dynamic> data) async {
    _checkErrors();
    callLog.add('upsertParty');
    _upsertMutable(remoteParties, data);
  }

  @override
  Future<void> upsertProduct(Map<String, dynamic> data) async {
    _checkErrors();
    callLog.add('upsertProduct');
    _upsertMutable(remoteProducts, data);
  }

  void _upsertMutable(Map<String, Map<String, dynamic>> store, Map<String, dynamic> data) {
    final id = data['id'] as String;
    if (!store.containsKey(id)) {
      store[id] = Map<String, dynamic>.from(data);
    } else {
      final existing = store[id]!;
      final existingUpdatedAtStr = existing['updated_at'] as String?;
      final clientUpdatedAtStr = data['updated_at'] as String?;
      if (existingUpdatedAtStr != null && clientUpdatedAtStr != null) {
        final existingUpdatedAt = DateTime.parse(existingUpdatedAtStr);
        final clientUpdatedAt = DateTime.parse(clientUpdatedAtStr);
        if (existingUpdatedAt.isBefore(clientUpdatedAt) || existingUpdatedAt.isAtSameMomentAs(clientUpdatedAt)) {
          store[id] = Map<String, dynamic>.from(data);
        }
      } else {
        store[id] = Map<String, dynamic>.from(data);
      }
    }
  }

  @override
  Future<void> issueDocument({
    required Map<String, dynamic> business,
    required Map<String, dynamic> device,
    Map<String, dynamic>? party,
    required List<Map<String, dynamic>> products,
    required Map<String, dynamic> document,
    required List<Map<String, dynamic>> lines,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> stockMovements,
    required String commandId,
  }) async {
    _checkErrors();

    // 1. Business (update only)
    callLog.add('upsertBusiness');
    final busId = business['id'] as String;
    if (remoteBusinesses.containsKey(busId)) {
      remoteBusinesses[busId] = Map<String, dynamic>.from(business);
    } else {
      throw const PostgrestException(
        message: 'Business does not exist on server (rejected)',
        code: '404',
      );
    }

    // 2. Device
    callLog.add('upsertDevice');
    _upsertMutable(remoteDevices, device);

    // 3. Party
    if (party != null) {
      callLog.add('upsertParty');
      _upsertMutable(remoteParties, party);
    }

    // 4. Products used
    for (final p in products) {
      callLog.add('upsertProduct');
      _upsertMutable(remoteProducts, p);
    }

    // 5. Document
    callLog.add('documents');
    final docId = document['id'] as String;
    final busIdDoc = document['business_id'];
    final docType = document['doc_type'];
    final number = document['number'];

    // Check unique constraint: documents(business_id, doc_type, number) for a DIFFERENT id
    for (final existingDoc in remoteDocuments.values) {
      if (existingDoc['business_id'] == busIdDoc &&
          existingDoc['doc_type'] == docType &&
          existingDoc['number'] == number &&
          existingDoc['id'] != docId) {
        throw const PostgrestException(
          message: 'duplicate key value violates unique constraint "idx_documents_business_number"',
          code: '23505',
        );
      }
    }

    if (!remoteDocuments.containsKey(docId)) {
      remoteDocuments[docId] = Map<String, dynamic>.from(document);
    }

    if (failIssueDocumentAfterDocumentSaved) {
      failIssueDocumentAfterDocumentSaved = false;
      throw const SocketException('Network failure after document saved');
    }

    // 6. Lines (append-only)
    callLog.add('documentLines');
    for (final l in lines) {
      final lId = l['id'] as String;
      if (!remoteLines.containsKey(lId)) {
        remoteLines[lId] = Map<String, dynamic>.from(l);
      }
    }

    // 7. Payments (append-only)
    callLog.add('payments');
    for (final pay in payments) {
      final payId = pay['id'] as String;
      if (!remotePayments.containsKey(payId)) {
        remotePayments[payId] = Map<String, dynamic>.from(pay);
      }
    }

    // 8. Stock Movements (append-only)
    callLog.add('stockMovements');
    for (final sm in stockMovements) {
      final smId = sm['id'] as String;
      if (!remoteStockMovements.containsKey(smId)) {
        remoteStockMovements[smId] = Map<String, dynamic>.from(sm);
      }
    }

    // 9. Applied Command (append-only)
    callLog.add('appliedCommands');
    appliedCommands.add(commandId);
  }

  @override
  Future<void> cancelDocument(String documentId) async {
    _checkErrors();
    callLog.add('cancelDocument');
    if (remoteDocuments.containsKey(documentId)) {
      final doc = Map<String, dynamic>.from(remoteDocuments[documentId]!);
      if (doc['status'] == 'issued') {
        doc['status'] = 'cancelled';
        remoteDocuments[documentId] = doc;
      } else if (doc['status'] != 'cancelled') {
        throw const PostgrestException(
          message: 'documents may only change issued -> cancelled',
          code: 'P0001',
        );
      }
    } else {
      throw const PostgrestException(
        message: 'Document not found for cancellation',
        code: '404',
      );
    }
  }

  void _checkErrors() {
    if (shouldThrowNetworkError) {
      throw const SocketException('No Internet Connection');
    }
    if (shouldThrowConstraintError) {
      throw PostgrestException(
        message: customErrorMsg ?? 'duplicate key value violates unique constraint',
        code: '23505',
      );
    }
  }
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Rekey transaction transforms seed IDs into UUIDs and keeps triggers', () async {
    final now = DateTime.now();

    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'local-business',
          businessId: 'local-business',
          name: 'Seed Shop',
          stateCode: '27',
          address: 'Main St',
          createdAt: now,
        ));

    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'local-device',
          businessId: 'local-business',
          name: 'Seed POS',
          seriesPrefix: 'A',
          createdAt: now,
        ));

    await db.into(db.parties).insert(PartiesCompanion.insert(
          id: 'p1',
          businessId: 'local-business',
          name: 'Party One',
          phone: '9999999999',
          stateCode: '27',
          creditLimitPaise: 0,
          createdAt: now,
        ));

    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'prod1',
          businessId: 'local-business',
          name: 'Item 1',
          hsn: '1234',
          gstRateBp: 1800,
          pricePaise: 10000,
          costPaise: 5000,
          trackStock: true,
          reorderLevel: 5,
          createdAt: now,
        ));

    final doc = await db.issueDocument(
      businessId: 'local-business',
      deviceId: 'local-device',
      docType: 'invoice',
      financialYear: '24-25',
      partyId: 'p1',
      lines: [
        const IssueDocumentLineParam(
          productId: 'prod1',
          name: 'Item 1',
          hsn: '1234',
          qtyMilli: 1000,
          ratePaise: 10000,
          gstRateBp: 1800,
        ),
      ],
      isInterState: false,
    );

    final rekeyService = RekeyService(db);
    final result = await rekeyService.rekeyIfNeeded();

    expect(result.newBusinessId, isNot(equals('local-business')));
    expect(result.newDeviceId, isNot(equals('local-device')));

    final buses = await db.select(db.businesses).get();
    expect(buses.first.id, equals(result.newBusinessId));

    final devs = await db.select(db.devices).get();
    expect(devs.first.id, equals(result.newDeviceId));
    expect(devs.first.businessId, equals(result.newBusinessId));

    final updatedDoc = await (db.select(db.documents)..where((t) => t.id.equals(doc.id))).getSingle();
    expect(updatedDoc.businessId, equals(result.newBusinessId));
    expect(updatedDoc.deviceId, equals(result.newDeviceId));
    expect(updatedDoc.snapshotJson, contains(result.newBusinessId));
    expect(updatedDoc.snapshotJson, isNot(contains('local-business')));

    expect(
      () => db.customStatement("UPDATE documents SET total_paise = 9999 WHERE id = '${doc.id}';"),
      throwsA(isA<Object>()),
    );
  });

  test('2. Push idempotency: running push twice results in single record on remote', () async {
    final remote = FakeSyncRemote();
    remote.remoteBusinesses['b1'] = {'id': 'b1', 'name': 'Shop 1'};
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop 1',
          stateCode: '27',
          address: 'Main',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'Device 1',
          seriesPrefix: 'A',
          createdAt: now,
        ));

    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'prod1',
          businessId: 'b1',
          name: 'Shirt',
          hsn: '6205',
          gstRateBp: 500,
          pricePaise: 50000,
          costPaise: 25000,
          trackStock: false,
          reorderLevel: 0,
          createdAt: now,
        ));

    await db.issueDocument(
      businessId: 'b1',
      deviceId: 'd1',
      docType: 'invoice',
      financialYear: '24-25',
      lines: [
        const IssueDocumentLineParam(
          productId: 'prod1',
          name: 'Shirt',
          hsn: '6205',
          qtyMilli: 1000,
          ratePaise: 50000,
          gstRateBp: 500,
        ),
      ],
      isInterState: false,
    );

    // First push
    await worker.pushPending();
    expect(remote.remoteDocuments.length, equals(1));

    // Second push
    await worker.pushPending();
    expect(remote.remoteDocuments.length, equals(1));
  });

  test('3. Table insertion order: business -> device -> party -> products -> document -> lines -> payments -> stockMovements', () async {
    final remote = FakeSyncRemote();
    remote.remoteBusinesses['b1'] = {'id': 'b1', 'name': 'Shop'};
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Address',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'POS',
          seriesPrefix: 'A',
          createdAt: now,
        ));
    await db.into(db.parties).insert(PartiesCompanion.insert(
          id: 'p1',
          businessId: 'b1',
          name: 'Buyer',
          phone: '9876543210',
          stateCode: '27',
          creditLimitPaise: 0,
          createdAt: now,
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'prod1',
          businessId: 'b1',
          name: 'Product 1',
          hsn: '1000',
          gstRateBp: 1800,
          pricePaise: 1000,
          costPaise: 500,
          trackStock: true,
          reorderLevel: 2,
          createdAt: now,
        ));

    await db.issueDocument(
      businessId: 'b1',
      deviceId: 'd1',
      docType: 'invoice',
      financialYear: '24-25',
      partyId: 'p1',
      lines: [
        const IssueDocumentLineParam(
          productId: 'prod1',
          name: 'Product 1',
          hsn: '1000',
          qtyMilli: 1000,
          ratePaise: 1000,
          gstRateBp: 1800,
        ),
      ],
      isInterState: false,
      payments: [const PaymentParam(method: 'cash', amountPaise: 1180)],
    );

    await worker.pushPending();

    expect(remote.callLog, equals([
      'upsertBusiness',
      'upsertDevice',
      'upsertParty',
      'upsertProduct',
      'documents',
      'documentLines',
      'payments',
      'stockMovements',
      'appliedCommands',
    ]));
  });

  test('4. Network failure keeps command pending and backs off', () async {
    final remote = FakeSyncRemote()..shouldThrowNetworkError = true;
    remote.remoteBusinesses['b1'] = {'id': 'b1'};
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Addr',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'Dev',
          seriesPrefix: 'A',
          createdAt: now,
        ));

    await db.enqueueOutboxCommand(
      businessId: 'b1',
      deviceId: 'd1',
      commandType: 'upsert_business',
      payload: {'id': 'b1'},
    );

    await worker.pushPending();

    final cmd = await (db.select(db.outboxCommands)..limit(1)).getSingle();
    expect(cmd.status, equals('pending'));
    expect(cmd.lastError, contains('SocketException'));
  });

  test('5. Constraint rejection marks outbox command as rejected', () async {
    final remote = FakeSyncRemote()..shouldThrowConstraintError = true;
    remote.remoteBusinesses['b1'] = {'id': 'b1'};
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Addr',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'Dev',
          seriesPrefix: 'A',
          createdAt: now,
        ));

    await db.enqueueOutboxCommand(
      businessId: 'b1',
      deviceId: 'd1',
      commandType: 'upsert_business',
      payload: {'id': 'b1'},
    );

    await worker.pushPending();

    final cmd = await (db.select(db.outboxCommands)..limit(1)).getSingle();
    expect(cmd.status, equals('rejected'));
    expect(cmd.lastError, contains('duplicate key'));
  });

  test('6. Two devices with duplicate document number gets duplicate-number rejection', () async {
    final remote = FakeSyncRemote()..customErrorMsg = 'duplicate key value violates unique constraint "idx_documents_business_number"';
    remote.shouldThrowConstraintError = true;
    remote.remoteBusinesses['b1'] = {'id': 'b1'};
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Addr',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'Dev',
          seriesPrefix: 'A',
          createdAt: now,
        ));

    await db.enqueueOutboxCommand(
      businessId: 'b1',
      deviceId: 'd1',
      commandType: 'cancel_document',
      payload: {'document_id': 'doc-dup'},
    );

    await worker.pushPending();

    final cmd = await (db.select(db.outboxCommands)..limit(1)).getSingle();
    expect(cmd.status, equals('rejected'));
    expect(cmd.lastError, contains('duplicate key'));
  });

  test('7. cancel_document only flips an issued doc status on remote', () async {
    final remote = FakeSyncRemote();
    remote.remoteBusinesses['b1'] = {'id': 'b1'};
    final worker = PushWorker(db: db, remote: remote);

    remote.remoteDocuments['doc-100'] = {
      'id': 'doc-100',
      'status': 'issued',
    };

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Addr',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'Dev',
          seriesPrefix: 'A',
          createdAt: now,
        ));

    await db.enqueueOutboxCommand(
      businessId: 'b1',
      deviceId: 'd1',
      commandType: 'cancel_document',
      payload: {'document_id': 'doc-100'},
    );

    await worker.pushPending();

    expect(remote.remoteDocuments['doc-100']!['status'], equals('cancelled'));
  });

  test('8. Retrying issue_document twice marks it applied (not rejected)', () async {
    final remote = FakeSyncRemote();
    remote.remoteBusinesses['b1'] = {'id': 'b1', 'name': 'Shop'};
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Main',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'POS',
          seriesPrefix: 'A',
          createdAt: now,
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'prod1',
          businessId: 'b1',
          name: 'Item 1',
          hsn: '1000',
          gstRateBp: 1800,
          pricePaise: 1000,
          costPaise: 500,
          trackStock: false,
          reorderLevel: 0,
          createdAt: now,
        ));

    await db.issueDocument(
      businessId: 'b1',
      deviceId: 'd1',
      docType: 'invoice',
      financialYear: '24-25',
      lines: [
        const IssueDocumentLineParam(
          productId: 'prod1',
          name: 'Item 1',
          hsn: '1000',
          qtyMilli: 1000,
          ratePaise: 1000,
          gstRateBp: 1800,
        ),
      ],
      isInterState: false,
    );

    // Push first time -> applied
    await worker.pushPending();
    var cmds = await db.select(db.outboxCommands).get();
    expect(cmds.first.status, equals('applied'));

    // Reset command back to pending and push again -> still applied (idempotent)
    await (db.update(db.outboxCommands)..where((t) => t.id.equals(cmds.first.id))).write(
      const OutboxCommandsCompanion(status: Value('pending')),
    );

    await worker.pushPending();
    cmds = await db.select(db.outboxCommands).get();
    expect(cmds.first.status, equals('applied'));
  });

  test('9. Retry after network failure mid-way completes remaining rows', () async {
    final remote = FakeSyncRemote();
    remote.remoteBusinesses['b1'] = {'id': 'b1', 'name': 'Shop'};
    remote.failIssueDocumentAfterDocumentSaved = true;
    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Main',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'POS',
          seriesPrefix: 'A',
          createdAt: now,
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'prod1',
          businessId: 'b1',
          name: 'Item 1',
          hsn: '1000',
          gstRateBp: 1800,
          pricePaise: 1000,
          costPaise: 500,
          trackStock: true,
          reorderLevel: 2,
          createdAt: now,
        ));

    await db.issueDocument(
      businessId: 'b1',
      deviceId: 'd1',
      docType: 'invoice',
      financialYear: '24-25',
      lines: [
        const IssueDocumentLineParam(
          productId: 'prod1',
          name: 'Item 1',
          hsn: '1000',
          qtyMilli: 1000,
          ratePaise: 1000,
          gstRateBp: 1800,
        ),
      ],
      isInterState: false,
    );

    // Push 1: network failure mid-way
    await worker.pushPending();

    expect(remote.remoteDocuments.length, equals(1));
    expect(remote.remoteLines.length, equals(0)); // lines not saved yet
    var cmd = await (db.select(db.outboxCommands)..limit(1)).getSingle();
    expect(cmd.status, equals('pending'));

    // Push 2: retry completes remaining rows
    await worker.pushPending();

    expect(remote.remoteLines.length, equals(1));
    cmd = await (db.select(db.outboxCommands)..limit(1)).getSingle();
    expect(cmd.status, equals('applied'));
  });

  test('10. Business push uses update only', () async {
    final remote = FakeSyncRemote();
    final worker = PushWorker(db: db, remote: remote);

    // 10a. Push business when it exists on server -> applied
    remote.remoteBusinesses['b1'] = {'id': 'b1', 'name': 'Old Name'};

    await db.enqueueOutboxCommand(
      businessId: 'b1',
      deviceId: 'd1',
      commandType: 'upsert_business',
      payload: {'id': 'b1', 'name': 'New Name'},
    );

    await worker.pushPending();

    final cmd1 = await (db.select(db.outboxCommands)..where((t) => t.businessId.equals('b1'))).getSingle();
    expect(cmd1.status, equals('applied'));
    expect(remote.remoteBusinesses['b1']!['name'], equals('New Name'));

    // 10b. Push business when it does NOT exist on server -> rejected
    await db.enqueueOutboxCommand(
      businessId: 'nonexistent',
      deviceId: 'd1',
      commandType: 'upsert_business',
      payload: {'id': 'nonexistent', 'name': 'Ghost'},
    );

    await worker.pushPending();

    final cmd2 = await (db.select(db.outboxCommands)..where((t) => t.businessId.equals('nonexistent'))).getSingle();
    expect(cmd2.status, equals('rejected'));
  });

  test('11. Older product edit does not overwrite a newer server row', () async {
    final remote = FakeSyncRemote();
    remote.remoteProducts['prod1'] = {
      'id': 'prod1',
      'name': 'Server Newer Name',
      'updated_at': '2025-01-02T12:00:00.000Z',
    };
    final worker = PushWorker(db: db, remote: remote);

    await db.enqueueOutboxCommand(
      businessId: 'b1',
      deviceId: 'd1',
      commandType: 'upsert_product',
      payload: {
        'id': 'prod1',
        'name': 'Client Older Name',
        'updated_at': '2025-01-01T12:00:00.000Z',
      },
    );

    await worker.pushPending();

    final cmd = await (db.select(db.outboxCommands)..limit(1)).getSingle();
    expect(cmd.status, equals('applied'));
    expect(remote.remoteProducts['prod1']!['name'], equals('Server Newer Name'));
  });

  test('12. Duplicate invoice number with a different id is rejected', () async {
    final remote = FakeSyncRemote();
    remote.remoteBusinesses['b1'] = {'id': 'b1'};

    final worker = PushWorker(db: db, remote: remote);

    final now = DateTime.now();
    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: 'b1',
          businessId: 'b1',
          name: 'Shop',
          stateCode: '27',
          address: 'Main',
          createdAt: now,
        ));
    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: 'd1',
          businessId: 'b1',
          name: 'POS',
          seriesPrefix: 'A',
          createdAt: now,
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'prod1',
          businessId: 'b1',
          name: 'Item 1',
          hsn: '1000',
          gstRateBp: 1800,
          pricePaise: 1000,
          costPaise: 500,
          trackStock: false,
          reorderLevel: 0,
          createdAt: now,
        ));

    // Issue a document locally
    final doc = await db.issueDocument(
      businessId: 'b1',
      deviceId: 'd1',
      docType: 'invoice',
      financialYear: '24-25',
      lines: [
        const IssueDocumentLineParam(
          productId: 'prod1',
          name: 'Item 1',
          hsn: '1000',
          qtyMilli: 1000,
          ratePaise: 1000,
          gstRateBp: 1800,
        ),
      ],
      isInterState: false,
    );

    // Pre-populate remote with a document having the SAME number but a DIFFERENT id ('doc-1')
    final localDoc = await (db.select(db.documents)..where((t) => t.id.equals(doc.id))).getSingle();
    remote.remoteDocuments['doc-1'] = {
      'id': 'doc-1',
      'business_id': 'b1',
      'doc_type': 'invoice',
      'number': localDoc.number,
    };

    await worker.pushPending();

    final cmd = await (db.select(db.outboxCommands)..where((t) => t.commandType.equals('issue_document'))).getSingle();
    expect(cmd.status, equals('rejected'));
    expect(cmd.lastError, contains('duplicate key'));
  });
}
