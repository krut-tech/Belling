import 'dart:convert';
import 'package:drift/drift.dart';
import 'records.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/tax.dart';

part 'database.g.dart';

@DataClassName('Business')
class Businesses extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get gstin => text().nullable()();
  TextColumn get stateCode => text()();
  TextColumn get address => text()();
  TextColumn get upiId => text().nullable()();
  TextColumn get invoiceTerms => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get seriesPrefix => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Parties extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get gstin => text().nullable()();
  TextColumn get stateCode => text()();
  IntColumn get creditLimitPaise => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_products_business_barcode', columns: {#businessId, #barcode})
@TableIndex(name: 'idx_products_business_name', columns: {#businessId, #name})
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get hsn => text()();
  IntColumn get gstRateBp => integer()();
  IntColumn get pricePaise => integer()();
  IntColumn get costPaise => integer()();
  BoolColumn get trackStock => boolean()();
  IntColumn get reorderLevel => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'idx_document_series_unique',
  columns: {#businessId, #deviceId, #docType, #financialYear},
  unique: true,
)
@DataClassName('DocumentSeriesData')
class DocumentSeries extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get docType => text()();
  TextColumn get financialYear => text()();
  IntColumn get nextNumber => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_documents_business_issued_at', columns: {#businessId, #issuedAt})
@TableIndex(name: 'idx_documents_business_party', columns: {#businessId, #partyId})
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get docType => text()();
  TextColumn get number => text()();
  TextColumn get partyId => text().nullable().references(Parties, #id)();
  DateTimeColumn get issuedAt => dateTime()();
  TextColumn get status => text()();
  IntColumn get taxablePaise => integer()();
  IntColumn get cgstPaise => integer()();
  IntColumn get sgstPaise => integer()();
  IntColumn get igstPaise => integer()();
  IntColumn get roundOffPaise => integer()();
  IntColumn get totalPaise => integer()();
  TextColumn get snapshotJson => text()();
  TextColumn get refDocumentId => text().nullable().references(Documents, #id)();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DocumentLines extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();
  TextColumn get hsn => text()();
  IntColumn get qtyMilli => integer()();
  IntColumn get ratePaise => integer()();
  IntColumn get discountPaise => integer()();
  IntColumn get gstRateBp => integer()();
  IntColumn get taxablePaise => integer()();
  IntColumn get cgstPaise => integer()();
  IntColumn get sgstPaise => integer()();
  IntColumn get igstPaise => integer()();
  IntColumn get lineTotalPaise => integer()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_payments_business_party', columns: {#businessId, #partyId})
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get documentId => text().nullable().references(Documents, #id)();
  TextColumn get partyId => text().nullable().references(Parties, #id)();
  TextColumn get method => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get paidAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_stock_movements_business_product', columns: {#businessId, #productId})
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get qtyMilli => integer()();
  TextColumn get reason => text()();
  TextColumn get documentId => text().nullable().references(Documents, #id)();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class OutboxCommands extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get commandType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DraftCarts extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get partyId => text().nullable().references(Parties, #id)();
  TextColumn get cartJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncState')
class SyncStateTable extends Table {
  @override
  String get tableName => 'sync_state';

  TextColumn get tableNameCol => text().named('table_name')();
  IntColumn get lastSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {tableNameCol};
}

@DataClassName('AppSetting')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Current local schema version (also the highest backup version we can restore).
const int kSchemaVersion = 4;

class IssueDocumentLineParam {
  final String productId;
  final String name;
  final String hsn;
  final int qtyMilli;
  final int ratePaise;
  final int discountPaise;
  final int gstRateBp;
  final bool priceIncludesTax;

  const IssueDocumentLineParam({
    required this.productId,
    required this.name,
    required this.hsn,
    required this.qtyMilli,
    required this.ratePaise,
    this.discountPaise = 0,
    required this.gstRateBp,
    this.priceIncludesTax = false,
  });
}

class PaymentParam {
  final String method;
  final int amountPaise;

  const PaymentParam({
    required this.method,
    required this.amountPaise,
  });
}

Map<String, dynamic> businessToPayload(Business b) => {
      'id': b.id,
      'name': b.name,
      'gstin': b.gstin,
      'state_code': b.stateCode,
      'address': b.address,
      'upi_id': b.upiId,
      'invoice_terms': b.invoiceTerms,
      'created_at': b.createdAt.toUtc().toIso8601String(),
      'updated_at': b.updatedAt.toUtc().toIso8601String(),
    };

Map<String, dynamic> deviceToPayload(Device d) => {
      'id': d.id,
      'business_id': d.businessId,
      'name': d.name,
      'series_prefix': d.seriesPrefix,
      'created_at': d.createdAt.toUtc().toIso8601String(),
      'updated_at': d.updatedAt.toUtc().toIso8601String(),
    };

Map<String, dynamic> partyToPayload(Party p) => {
      'id': p.id,
      'business_id': p.businessId,
      'name': p.name,
      'phone': p.phone,
      'gstin': p.gstin,
      'state_code': p.stateCode,
      'credit_limit_paise': p.creditLimitPaise,
      'created_at': p.createdAt.toUtc().toIso8601String(),
      'updated_at': p.updatedAt.toUtc().toIso8601String(),
      'archived_at': p.archivedAt?.toUtc().toIso8601String(),
    };

Map<String, dynamic> productToPayload(Product p) => {
      'id': p.id,
      'business_id': p.businessId,
      'name': p.name,
      'barcode': p.barcode,
      'hsn': p.hsn,
      'gst_rate_bp': p.gstRateBp,
      'price_paise': p.pricePaise,
      'cost_paise': p.costPaise,
      'track_stock': p.trackStock,
      'reorder_level': p.reorderLevel,
      'created_at': p.createdAt.toUtc().toIso8601String(),
      'updated_at': p.updatedAt.toUtc().toIso8601String(),
    };

@DriftDatabase(tables: [
  Businesses,
  Devices,
  Parties,
  Products,
  DocumentSeries,
  Documents,
  DocumentLines,
  Payments,
  StockMovements,
  OutboxCommands,
  DraftCarts,
  SyncStateTable,
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => kSchemaVersion;

  Future<void> enqueueOutboxCommand({
    required String businessId,
    required String deviceId,
    required String commandType,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now();
    await into(outboxCommands).insert(
      OutboxCommandsCompanion.insert(
        id: const Uuid().v4(),
        businessId: businessId,
        deviceId: deviceId,
        commandType: commandType,
        payloadJson: jsonEncode(payload),
        status: 'pending',
        createdAt: now,
        lastError: const Value.absent(),
      ),
    );
  }

  /// Drops the immutability triggers. Only for one-time maintenance inside a
  /// transaction (rekey, adopting a server business); always call
  /// [createTriggers] again before the transaction ends.
  Future<void> dropTriggers() async {
    const names = [
      'prevent_issued_doc_update',
      'prevent_issued_doc_delete',
      'prevent_doc_lines_update',
      'prevent_doc_lines_delete',
      'prevent_payments_update',
      'prevent_payments_delete',
      'prevent_stock_movements_update',
      'prevent_stock_movements_delete',
    ];
    for (final name in names) {
      await customStatement('DROP TRIGGER IF EXISTS $name;');
    }
  }

  Future<void> createTriggers() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_issued_doc_update
      BEFORE UPDATE ON documents
      FOR EACH ROW
      WHEN OLD.status = 'issued' AND (
        NEW.status != 'cancelled' OR
        NEW.id IS NOT OLD.id OR
        NEW.business_id IS NOT OLD.business_id OR
        NEW.device_id IS NOT OLD.device_id OR
        NEW.doc_type IS NOT OLD.doc_type OR
        NEW.number IS NOT OLD.number OR
        NEW.party_id IS NOT OLD.party_id OR
        NEW.issued_at IS NOT OLD.issued_at OR
        NEW.taxable_paise IS NOT OLD.taxable_paise OR
        NEW.cgst_paise IS NOT OLD.cgst_paise OR
        NEW.sgst_paise IS NOT OLD.sgst_paise OR
        NEW.igst_paise IS NOT OLD.igst_paise OR
        NEW.round_off_paise IS NOT OLD.round_off_paise OR
        NEW.total_paise IS NOT OLD.total_paise OR
        NEW.snapshot_json IS NOT OLD.snapshot_json OR
        NEW.ref_document_id IS NOT OLD.ref_document_id OR
        NEW.created_at IS NOT OLD.created_at
      )
      BEGIN
        SELECT RAISE(ABORT, 'Issued documents cannot be updated except changing status to cancelled');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_issued_doc_delete
      BEFORE DELETE ON documents
      FOR EACH ROW
      WHEN OLD.status = 'issued'
      BEGIN
        SELECT RAISE(ABORT, 'Issued documents cannot be deleted');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_doc_lines_update
      BEFORE UPDATE ON document_lines
      FOR EACH ROW
      BEGIN
        SELECT RAISE(ABORT, 'document_lines cannot be updated');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_doc_lines_delete
      BEFORE DELETE ON document_lines
      FOR EACH ROW
      BEGIN
        SELECT RAISE(ABORT, 'document_lines cannot be deleted');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_payments_update
      BEFORE UPDATE ON payments
      FOR EACH ROW
      BEGIN
        SELECT RAISE(ABORT, 'payments cannot be updated');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_payments_delete
      BEFORE DELETE ON payments
      FOR EACH ROW
      BEGIN
        SELECT RAISE(ABORT, 'payments cannot be deleted');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_stock_movements_update
      BEFORE UPDATE ON stock_movements
      FOR EACH ROW
      BEGIN
        SELECT RAISE(ABORT, 'stock_movements cannot be updated');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS prevent_stock_movements_delete
      BEFORE DELETE ON stock_movements
      FOR EACH ROW
      BEGIN
        SELECT RAISE(ABORT, 'stock_movements cannot be deleted');
      END;
    ''');
  }

  /// Adds a column during migration. Only "duplicate column" (already added by
  /// an earlier partial run) is ignored; any other failure aborts the upgrade
  /// so a half-migrated schema is never opened silently.
  Future<void> _safeAddColumn(Migrator m, TableInfo table, GeneratedColumn column) async {
    try {
      await m.addColumn(table, column);
    } catch (e) {
      if (!e.toString().toLowerCase().contains('duplicate column')) rethrow;
    }
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await createTriggers();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await customStatement('DROP TRIGGER IF EXISTS prevent_issued_doc_update;');
          await createTriggers();
          await _safeAddColumn(m, businesses, businesses.upiId);
          await _safeAddColumn(m, businesses, businesses.invoiceTerms);
        }
        if (from < 3) {
          await _safeAddColumn(m, payments, payments.note);
        }
        if (from < 4) {
          await _safeAddColumn(m, businesses, businesses.updatedAt);
          await _safeAddColumn(m, businesses, businesses.serverSeq);
          await _safeAddColumn(m, devices, devices.updatedAt);
          await _safeAddColumn(m, devices, devices.serverSeq);
          await _safeAddColumn(m, parties, parties.updatedAt);
          await _safeAddColumn(m, parties, parties.archivedAt);
          await _safeAddColumn(m, parties, parties.serverSeq);
          await _safeAddColumn(m, products, products.updatedAt);
          await _safeAddColumn(m, products, products.serverSeq);
          await _safeAddColumn(m, documents, documents.serverSeq);
          await _safeAddColumn(m, documentLines, documentLines.serverSeq);
          await _safeAddColumn(m, payments, payments.serverSeq);
          await _safeAddColumn(m, stockMovements, stockMovements.serverSeq);
          try {
            await m.createTable(syncStateTable);
          } catch (e) {
            if (!e.toString().toLowerCase().contains('already exists')) rethrow;
          }
          try {
            await m.createTable(appSettingsTable);
          } catch (e) {
            if (!e.toString().toLowerCase().contains('already exists')) rethrow;
          }
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement(kCreateAppRecordsSql);
        await customStatement(kCreateAppRecordsIndexSql);
        await ensureBootstrapData();
      },
    );
  }

  Future<void> ensureBootstrapData() async {
    final now = DateTime.now();

    // Seed only when there is NO business at all. After the first sign-in the
    // local ids are rekeyed to UUIDs; looking for 'local-business' here would
    // create a second, empty business on every app start.
    final anyBusiness = await (select(businesses)..limit(1)).get();
    if (anyBusiness.isEmpty) {
      await into(businesses).insertOnConflictUpdate(
        BusinessesCompanion.insert(
          id: 'local-business',
          businessId: 'local-business',
          name: 'My Business',
          stateCode: '24',
          address: 'Main Store',
          createdAt: now,
        ),
      );
    }

    final anyDevice = await (select(devices)..limit(1)).get();
    if (anyDevice.isEmpty) {
      final ownerBusiness = await (select(businesses)..limit(1)).getSingle();
      await into(devices).insertOnConflictUpdate(
        DevicesCompanion.insert(
          id: 'local-device',
          businessId: ownerBusiness.id,
          name: 'POS Terminal 1',
          seriesPrefix: 'A',
          createdAt: now,
        ),
      );
    }
  }

  Future<Business> upsertBusinessSettings({
    required String businessId,
    required String deviceId,
    required String name,
    String? gstin,
    String? stateCode,
    required String address,
    String? upiId,
    String? invoiceTerms,
  }) async {
    return transaction(() async {
      final now = DateTime.now();
      final existingBusinessRow =
          await (select(businesses)..where((t) => t.id.equals(businessId))).getSingleOrNull();

      await into(businesses).insertOnConflictUpdate(
        BusinessesCompanion(
          id: Value(businessId),
          businessId: Value(businessId),
          name: Value(name),
          gstin: Value(gstin),
          stateCode: Value(stateCode ?? '24'),
          address: Value(address),
          upiId: Value(upiId),
          invoiceTerms: Value(invoiceTerms),
          updatedAt: Value(now),
          createdAt: Value(existingBusinessRow?.createdAt ?? now),
        ),
      );

      final updatedBus = await (select(businesses)..where((t) => t.id.equals(businessId))).getSingleOrNull();
      if (updatedBus == null) {
        throw StateError('Failed to load business settings after save');
      }

      await enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'upsert_business',
        payload: businessToPayload(updatedBus),
      );

      return updatedBus;
    });
  }

  Future<Document> issueDocument({
    required String businessId,
    required String deviceId,
    required String docType,
    required String financialYear,
    String? partyId,
    required List<IssueDocumentLineParam> lines,
    required bool isInterState,
    List<PaymentParam>? payments,
    String? refDocumentId,
    DateTime? issuedAt,
    Map<String, dynamic>? customSnapshot,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('A document needs at least one line');
    }
    for (final line in lines) {
      if (line.qtyMilli <= 0 || line.ratePaise < 0) {
        throw ArgumentError('qtyMilli must be positive and ratePaise must be non-negative');
      }
      if (line.discountPaise < 0) {
        throw ArgumentError('Discount cannot be negative');
      }
      final gross = divideRoundHalfUp(line.qtyMilli * line.ratePaise, 1000);
      if (line.discountPaise > gross) {
        throw ArgumentError('Discount cannot be more than the line amount');
      }
      if (line.gstRateBp < 0) {
        throw ArgumentError('GST rate cannot be negative');
      }
    }
    if (payments != null) {
      for (final p in payments) {
        if (p.amountPaise < 0) {
          throw ArgumentError('Payment amount cannot be negative');
        }
      }
    }

    return transaction(() async {
      final now = DateTime.now();

      final existingSeries = await (select(documentSeries)..where(
        (tbl) =>
            tbl.businessId.equals(businessId) &
            tbl.deviceId.equals(deviceId) &
            tbl.docType.equals(docType) &
            tbl.financialYear.equals(financialYear),
      )).getSingleOrNull();

      final device = await (select(devices)..where(
        (tbl) => tbl.id.equals(deviceId),
      )).getSingleOrNull();
      final seriesPrefix = device?.seriesPrefix ?? 'A';

      int currentNumber;
      if (existingSeries == null) {
        currentNumber = 1;
        await into(documentSeries).insert(DocumentSeriesCompanion.insert(
          id: const Uuid().v4(),
          businessId: businessId,
          deviceId: deviceId,
          docType: docType,
          financialYear: financialYear,
          nextNumber: 2,
          createdAt: now,
        ));
      } else {
        currentNumber = existingSeries.nextNumber;
        await (update(documentSeries)..where((tbl) => tbl.id.equals(existingSeries.id))).write(
          DocumentSeriesCompanion(
            nextNumber: Value(currentNumber + 1),
          ),
        );
      }

      final documentNumber = '$seriesPrefix-${currentNumber.toString().padLeft(4, '0')}';

      final taxResult = calculateTax(
        lines: lines
            .map((l) => TaxLineInput(
                  qtyMilli: l.qtyMilli,
                  ratePaise: l.ratePaise,
                  discountPaise: l.discountPaise,
                  gstRateBp: l.gstRateBp,
                  priceIncludesTax: l.priceIncludesTax,
                ))
            .toList(),
        isInterState: isInterState,
      );

      final paidPaise = payments?.fold<int>(0, (sum, p) => sum + p.amountPaise) ?? 0;
      final balancePaise = taxResult.totalPaise - paidPaise;

      String snapshotJsonStr;
      if (customSnapshot != null) {
        final map = Map<String, dynamic>.from(customSnapshot);
        map.putIfAbsent('paid_paise', () => paidPaise);
        map.putIfAbsent('balance_paise', () => balancePaise);
        map.putIfAbsent('number', () => documentNumber);
        map.putIfAbsent('doc_type', () => docType);
        map.putIfAbsent('issued_at', () => (issuedAt ?? now).toIso8601String());
        // Credit notes (cancel / return) need the amounts for their PDF and GST export.
        map.putIfAbsent('tax_breakup', () => {
              'taxable_paise': taxResult.taxablePaise,
              'cgst_paise': taxResult.cgstPaise,
              'sgst_paise': taxResult.sgstPaise,
              'igst_paise': taxResult.igstPaise,
              'total_before_round_off_paise': taxResult.totalBeforeRoundOffPaise,
              'round_off_paise': taxResult.roundOffPaise,
              'total_paise': taxResult.totalPaise,
            });
        snapshotJsonStr = jsonEncode(map);
      } else {
        final seller = await (select(businesses)..where(
          (tbl) => tbl.id.equals(businessId),
        )).getSingleOrNull();
        final buyer = partyId != null
            ? await (select(parties)..where(
                (tbl) => tbl.id.equals(partyId),
              )).getSingleOrNull()
            : null;

        final snapshotMap = {
          'seller': seller != null
              ? {
                  'id': seller.id,
                  'name': seller.name,
                  'gstin': seller.gstin,
                  'state_code': seller.stateCode,
                  'address': seller.address,
                  'upi_id': seller.upiId,
                  'invoice_terms': seller.invoiceTerms,
                }
              : {'id': businessId},
          'buyer': buyer != null
              ? {
                  'id': buyer.id,
                  'name': buyer.name,
                  'phone': buyer.phone,
                  'gstin': buyer.gstin,
                  'state_code': buyer.stateCode,
                }
              : (partyId != null ? {'id': partyId} : null),
          'tax_breakup': {
            'taxable_paise': taxResult.taxablePaise,
            'cgst_paise': taxResult.cgstPaise,
            'sgst_paise': taxResult.sgstPaise,
            'igst_paise': taxResult.igstPaise,
            'total_before_round_off_paise': taxResult.totalBeforeRoundOffPaise,
            'round_off_paise': taxResult.roundOffPaise,
            'total_paise': taxResult.totalPaise,
          },
          'paid_paise': paidPaise,
          'balance_paise': balancePaise,
          'number': documentNumber,
          'doc_type': docType,
          'issued_at': (issuedAt ?? now).toIso8601String(),
        };
        snapshotJsonStr = jsonEncode(snapshotMap);
      }

      final docId = const Uuid().v4();
      final docCompanion = DocumentsCompanion.insert(
        id: docId,
        businessId: businessId,
        deviceId: deviceId,
        docType: docType,
        number: documentNumber,
        partyId: Value(partyId),
        issuedAt: issuedAt ?? now,
        status: 'issued',
        taxablePaise: taxResult.taxablePaise,
        cgstPaise: taxResult.cgstPaise,
        sgstPaise: taxResult.sgstPaise,
        igstPaise: taxResult.igstPaise,
        roundOffPaise: taxResult.roundOffPaise,
        totalPaise: taxResult.totalPaise,
        snapshotJson: snapshotJsonStr,
        refDocumentId: Value(refDocumentId),
        createdAt: now,
      );

      await into(documents).insert(docCompanion);

      for (var i = 0; i < lines.length; i++) {
        final inputLine = lines[i];
        final lineTax = taxResult.lines[i];

        await into(documentLines).insert(DocumentLinesCompanion.insert(
          id: const Uuid().v4(),
          documentId: docId,
          businessId: businessId,
          productId: inputLine.productId,
          name: inputLine.name,
          hsn: inputLine.hsn,
          qtyMilli: inputLine.qtyMilli,
          ratePaise: inputLine.ratePaise,
          discountPaise: inputLine.discountPaise,
          gstRateBp: inputLine.gstRateBp,
          taxablePaise: lineTax.taxablePaise,
          cgstPaise: lineTax.cgstPaise,
          sgstPaise: lineTax.sgstPaise,
          igstPaise: lineTax.igstPaise,
          lineTotalPaise: lineTax.lineTotalPaise,
          createdAt: now,
        ));

        final product = await (select(products)..where((tbl) => tbl.id.equals(inputLine.productId))).getSingleOrNull();

        if (product != null && product.trackStock) {
          final stockQty = (docType == 'credit_note') ? inputLine.qtyMilli : -inputLine.qtyMilli;
          await into(stockMovements).insert(StockMovementsCompanion.insert(
            id: const Uuid().v4(),
            businessId: businessId,
            productId: inputLine.productId,
            qtyMilli: stockQty,
            reason: docType == 'credit_note' ? 'credit_note' : 'sale',
            documentId: Value(docId),
            createdAt: now,
          ));
        }
      }

      final payloadMap = {
        'document_id': docId,
        'number': documentNumber,
        'doc_type': docType,
        'total_paise': taxResult.totalPaise,
        'issued_at': (issuedAt ?? now).toIso8601String(),
      };

      await enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'issue_document',
        payload: payloadMap,
      );

      if (payments != null) {
        for (final p in payments) {
          if (p.amountPaise > 0) {
            await into(this.payments).insert(PaymentsCompanion.insert(
              id: const Uuid().v4(),
              businessId: businessId,
              documentId: Value(docId),
              partyId: Value(partyId),
              method: p.method,
              amountPaise: p.amountPaise,
              paidAt: issuedAt ?? now,
              createdAt: now,
            ));
          }
        }
      }

      final insertedDoc = await (select(documents)..where((tbl) => tbl.id.equals(docId))).getSingleOrNull();
      if (insertedDoc == null) {
        throw StateError('Failed to retrieve issued document');
      }
      return insertedDoc;
    });
  }

  Future<Document> cancelInvoice({
    required String businessId,
    required String deviceId,
    required String documentId,
    required String reason,
  }) async {
    return transaction(() async {
      final origDoc = await (select(documents)..where((tbl) => tbl.id.equals(documentId))).getSingleOrNull();
      if (origDoc == null) {
        throw StateError('Document not found');
      }
      if (origDoc.status == 'cancelled') {
        throw StateError('Document is already cancelled');
      }
      if (origDoc.docType != 'invoice') {
        throw StateError('Only invoices can be cancelled');
      }

      final earlierCredits = await (select(documents)
            ..where((t) => t.refDocumentId.equals(documentId) & t.docType.equals('credit_note')))
          .get();
      if (earlierCredits.isNotEmpty) {
        throw StateError('Is bill ka kuch maal pehle hi return ho chuka hai. Bacha hua maal "Return" se wapas lo.');
      }

      final origLines = await (select(documentLines)..where((tbl) => tbl.documentId.equals(documentId))).get();
      final origPayments = await (select(payments)..where((tbl) => tbl.documentId.equals(documentId))).get();

      await (update(documents)..where((tbl) => tbl.id.equals(documentId))).write(
        const DocumentsCompanion(status: Value('cancelled')),
      );

      await enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'cancel_document',
        payload: {'document_id': documentId},
      );

      // The credit note is issued today, so it belongs to today's financial year series.
      final fy = getFinancialYear(DateTime.now());

      final seller = await (select(businesses)..where((tbl) => tbl.id.equals(businessId))).getSingleOrNull();
      if (seller == null) {
        throw StateError('Business not found');
      }
      final buyer = origDoc.partyId != null
          ? await (select(parties)..where((tbl) => tbl.id.equals(origDoc.partyId!))).getSingleOrNull()
          : null;
      // Mirror the original invoice: IGST on the invoice means inter-state.
      final isInterState = origDoc.igstPaise != 0;

      // document_lines does not store whether the rate included tax. If the
      // stored taxable amount differs from gross - discount, the line was
      // tax-inclusive, so mirror that to reproduce the same totals.
      bool wasInclusive(DocumentLine l) {
        final gross = divideRoundHalfUp(l.qtyMilli * l.ratePaise, 1000);
        return (gross - l.discountPaise) != l.taxablePaise;
      }

      final creditNoteLines = origLines
          .map((l) => IssueDocumentLineParam(
                productId: l.productId,
                name: l.name,
                hsn: l.hsn,
                qtyMilli: l.qtyMilli,
                ratePaise: l.ratePaise,
                discountPaise: l.discountPaise,
                gstRateBp: l.gstRateBp,
                priceIncludesTax: wasInclusive(l),
              ))
          .toList();

      final sellerMap = {
        'id': seller.id,
        'name': seller.name,
        'gstin': seller.gstin,
        'state_code': seller.stateCode,
        'address': seller.address,
        'upi_id': seller.upiId,
        'invoice_terms': seller.invoiceTerms,
      };
      final buyerMap = buyer != null
          ? {
              'id': buyer.id,
              'name': buyer.name,
              'phone': buyer.phone,
              'gstin': buyer.gstin,
              'state_code': buyer.stateCode,
            }
          : (origDoc.partyId != null ? {'id': origDoc.partyId} : null);

      final customSnapshot = {
        'seller': sellerMap,
        'buyer': buyerMap,
        'cancel_reason': reason,
        'cancelled_document_id': documentId,
        'cancelled_document_number': origDoc.number,
      };

      final cnDoc = await issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'credit_note',
        financialYear: fy,
        partyId: origDoc.partyId,
        lines: creditNoteLines,
        isInterState: isInterState,
        refDocumentId: documentId,
        customSnapshot: customSnapshot,
      );

      final now = DateTime.now();
      for (final p in origPayments) {
        if (p.amountPaise != 0) {
          await into(payments).insert(PaymentsCompanion.insert(
            id: const Uuid().v4(),
            businessId: businessId,
            documentId: Value(cnDoc.id),
            partyId: Value(origDoc.partyId),
            method: p.method,
            amountPaise: -p.amountPaise,
            paidAt: now,
            createdAt: now,
          ));
        }
      }

      return cnDoc;
    });
  }

  /// Quantity of each original line (by line id) already returned through
  /// earlier credit notes. Matched by product id + rate because credit-note
  /// lines are new rows.
  Future<Map<String, int>> returnedQtyByProduct(String documentId) async {
    final cns = await (select(documents)
          ..where((t) => t.refDocumentId.equals(documentId) & t.docType.equals('credit_note')))
        .get();
    final out = <String, int>{};
    for (final cn in cns) {
      final ls = await (select(documentLines)..where((t) => t.documentId.equals(cn.id))).get();
      for (final l in ls) {
        out[l.productId] = (out[l.productId] ?? 0) + l.qtyMilli;
      }
    }
    return out;
  }

  /// Partial sale return: issues a credit note for [returnQtyByLineId]
  /// (original line id -> qty in milli), puts stock back, and refunds cash only
  /// for what the customer has already paid beyond what they still owe.
  /// The original invoice stays valid.
  Future<Document> returnItems({
    required String businessId,
    required String deviceId,
    required String documentId,
    required Map<String, int> returnQtyByLineId,
    required String reason,
  }) async {
    return transaction(() async {
      final origDoc = await (select(documents)..where((t) => t.id.equals(documentId))).getSingleOrNull();
      if (origDoc == null) throw StateError('Document not found');
      if (origDoc.docType != 'invoice') throw StateError('Sirf invoice ka return ho sakta hai');
      if (origDoc.status == 'cancelled') throw StateError('Ye invoice cancel ho chuka hai');

      final origLines = await (select(documentLines)..where((t) => t.documentId.equals(documentId))).get();
      final already = await returnedQtyByProduct(documentId);

      final picked = <DocumentLine, int>{};
      final usedByProduct = <String, int>{};
      for (final l in origLines) {
        final q = returnQtyByLineId[l.id] ?? 0;
        if (q <= 0) continue;
        final prior = (already[l.productId] ?? 0) + (usedByProduct[l.productId] ?? 0);
        final canReturn = l.qtyMilli - prior;
        if (q > canReturn) {
          throw StateError('${l.name}: sirf ${canReturn / 1000} wapas ho sakta hai');
        }
        usedByProduct[l.productId] = (usedByProduct[l.productId] ?? 0) + q;
        picked[l] = q;
      }
      if (picked.isEmpty) throw StateError('Return ki quantity daalo');

      bool wasInclusive(DocumentLine l) {
        final gross = divideRoundHalfUp(l.qtyMilli * l.ratePaise, 1000);
        return (gross - l.discountPaise) != l.taxablePaise;
      }

      final cnLines = picked.entries.map((e) {
        final l = e.key;
        final q = e.value;
        // Discount shrinks in proportion to the returned quantity.
        final disc = l.qtyMilli == 0 ? 0 : (l.discountPaise * q / l.qtyMilli).round();
        return IssueDocumentLineParam(
          productId: l.productId,
          name: l.name,
          hsn: l.hsn,
          qtyMilli: q,
          ratePaise: l.ratePaise,
          discountPaise: disc,
          gstRateBp: l.gstRateBp,
          priceIncludesTax: wasInclusive(l),
        );
      }).toList();

      final seller = await (select(businesses)..where((t) => t.id.equals(businessId))).getSingleOrNull();
      if (seller == null) throw StateError('Business not found');
      final buyer = origDoc.partyId != null
          ? await (select(parties)..where((t) => t.id.equals(origDoc.partyId!))).getSingleOrNull()
          : null;

      final snapshot = {
        'seller': {
          'id': seller.id,
          'name': seller.name,
          'gstin': seller.gstin,
          'state_code': seller.stateCode,
          'address': seller.address,
          'upi_id': seller.upiId,
          'invoice_terms': seller.invoiceTerms,
        },
        'buyer': buyer != null
            ? {'id': buyer.id, 'name': buyer.name, 'phone': buyer.phone, 'gstin': buyer.gstin, 'state_code': buyer.stateCode}
            : (origDoc.partyId != null ? {'id': origDoc.partyId} : null),
        'cancel_reason': reason,
        'cancelled_document_id': documentId,
        'cancelled_document_number': origDoc.number,
        'partial_return': true,
      };

      final cn = await issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'credit_note',
        financialYear: getFinancialYear(DateTime.now()),
        partyId: origDoc.partyId,
        lines: cnLines,
        isInterState: origDoc.igstPaise != 0,
        refDocumentId: documentId,
        customSnapshot: snapshot,
      );

      // Refund only what was paid beyond what is still owed after all returns.
      final origPayments = await (select(payments)..where((t) => t.documentId.equals(documentId))).get();
      final priorCns = await (select(documents)
            ..where((t) => t.refDocumentId.equals(documentId) & t.docType.equals('credit_note')))
          .get();
      var creditedTotal = 0;
      var netPaid = origPayments.fold<int>(0, (a, p) => a + p.amountPaise);
      for (final c in priorCns) {
        creditedTotal += c.totalPaise;
        final cps = await (select(payments)..where((t) => t.documentId.equals(c.id))).get();
        netPaid += cps.fold<int>(0, (a, p) => a + p.amountPaise);
      }
      // priorCns already includes the credit note just issued (creditedTotal covers it),
      // and netPaid does not yet include a refund for it.
      final stillOwed = origDoc.totalPaise - creditedTotal;
      final refund = netPaid - (stillOwed > 0 ? stillOwed : 0);
      if (refund > 0) {
        final now = DateTime.now();
        final method = origPayments.isNotEmpty ? origPayments.first.method : 'cash';
        await into(payments).insert(PaymentsCompanion.insert(
          id: const Uuid().v4(),
          businessId: businessId,
          documentId: Value(cn.id),
          partyId: Value(origDoc.partyId),
          method: method,
          amountPaise: -refund,
          paidAt: now,
          createdAt: now,
        ));
      }
      return cn;
    });
  }
}

String getFinancialYear([DateTime? date]) {
  final d = date ?? DateTime.now();
  final year = d.year;
  if (d.month >= 4) {
    final nextYear = (year + 1) % 100;
    return '${year.toString().substring(2)}-${nextYear.toString().padLeft(2, '0')}';
  } else {
    final prevYear = year - 1;
    return '${prevYear.toString().substring(2)}-${(year % 100).toString().padLeft(2, '0')}';
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'app_db');
}
