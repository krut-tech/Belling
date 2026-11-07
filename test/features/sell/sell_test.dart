import 'dart:convert';
import 'package:belling/core/tax.dart';
import 'package:belling/data/database.dart';
import 'package:belling/data/providers.dart';
import 'package:belling/data/repositories/document_repository.dart';
import 'package:belling/data/repositories/party_repository.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:belling/features/sell/new_bill_notifier.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  group('Task 4: Sell & Invoice Tests', () {
    late AppDatabase db;
    late ProductRepository productRepo;
    late PartyRepository partyRepo;
    late DocumentRepository docRepo;
    const businessId = kLocalBusinessId;
    const deviceId = kLocalDeviceId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      productRepo = ProductRepository(db, businessId);
      partyRepo = PartyRepository(db, businessId);
      docRepo = DocumentRepository(db, businessId, deviceId);

      // Seed business & device
      await db.into(db.businesses).insertOnConflictUpdate(
        BusinessesCompanion.insert(
          id: businessId,
          businessId: businessId,
          name: 'Test Store',
          stateCode: '27', // Maharashtra
          address: 'Main St',
          createdAt: DateTime.now(),
        ),
      );

      await db.into(db.devices).insertOnConflictUpdate(
        DevicesCompanion.insert(
          id: deviceId,
          businessId: businessId,
          name: 'Terminal 1',
          seriesPrefix: 'A',
          createdAt: DateTime.now(),
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('1. Cart total equals calculateTax result', () async {
      final product1 = await productRepo.save(
        name: 'Sugar 1kg',
        hsn: '1701',
        gstRateBp: 500, // 5%
        pricePaise: 4200, // ₹42
        costPaise: 3500,
        trackStock: true,
        reorderLevel: 0,
      );

      final product2 = await productRepo.save(
        name: 'Oil 1L',
        hsn: '1507',
        gstRateBp: 1200, // 12%
        pricePaise: 13500, // ₹135
        costPaise: 11000,
        trackStock: true,
        reorderLevel: 0,
      );

      final pws1 = ProductWithStock(product: product1, stockMilli: 10000);
      final pws2 = ProductWithStock(product: product2, stockMilli: 10000);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(newBillProvider.notifier);
      notifier.addProduct(pws1);
      notifier.addProduct(pws2);

      final cartState = container.read(newBillProvider);

      // Expected calculation from calculateTax
      final expectedTaxResult = calculateTax(
        lines: [
          const TaxLineInput(qtyMilli: 1000, ratePaise: 4200, gstRateBp: 500),
          const TaxLineInput(qtyMilli: 1000, ratePaise: 13500, gstRateBp: 1200),
        ],
        isInterState: false,
      );

      expect(cartState.grandTotalPaise, equals(expectedTaxResult.totalPaise));
      expect(cartState.taxResult.taxablePaise, equals(expectedTaxResult.taxablePaise));
      expect(cartState.taxResult.cgstPaise, equals(expectedTaxResult.cgstPaise));
      expect(cartState.taxResult.sgstPaise, equals(expectedTaxResult.sgstPaise));
      expect(cartState.taxResult.igstPaise, equals(expectedTaxResult.igstPaise));
      expect(cartState.taxResult.roundOffPaise, equals(expectedTaxResult.roundOffPaise));
    });

    test('2. Inter-state switch updates isInterState and taxes', () async {
      final localParty = await partyRepo.save(
        name: 'Local Buyer',
        phone: '9876543210',
        stateCode: '27', // Same as business ('27')
      );

      final interStateParty = await partyRepo.save(
        name: 'Gujarat Buyer',
        phone: '9123456789',
        stateCode: '24', // Gujarat ('24')
      );

      // The bill decides IGST against the business's own state, so make the
      // business Maharashtra ('27') before the bill screen reads it.
      await (db.update(db.businesses)).write(const BusinessesCompanion(stateCode: Value('27')));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(newBillProvider.notifier);
      await container.read(activeBusinessProvider.future);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(newBillProvider).businessStateCode, '27');

      // Walk-in -> Intra-state
      expect(container.read(newBillProvider).isInterState, isFalse);

      // Local Party -> Intra-state
      notifier.setParty(localParty);
      expect(container.read(newBillProvider).isInterState, isFalse);
      expect(container.read(newBillProvider).taxResult.cgstPaise, greaterThanOrEqualTo(0));

      // Inter-state Party -> Inter-state
      notifier.setParty(interStateParty);
      expect(container.read(newBillProvider).isInterState, isTrue);
      expect(container.read(newBillProvider).taxResult.cgstPaise, equals(0));
      expect(container.read(newBillProvider).taxResult.sgstPaise, equals(0));

      // Switch back to null -> Intra-state
      notifier.setParty(null);
      expect(container.read(newBillProvider).isInterState, isFalse);
    });

    test('3. Credit needs a party', () async {
      final product = await productRepo.save(
        name: 'Rice 5kg',
        hsn: '1006',
        gstRateBp: 500,
        pricePaise: 30000,
        costPaise: 25000,
        trackStock: true,
        reorderLevel: 0,
      );
      final pws = ProductWithStock(product: product, stockMilli: 10000);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(newBillProvider.notifier);
      notifier.addProduct(pws);

      // Set payment method to credit with Walk-in (party = null)
      notifier.setPaymentMethod('credit');

      final resultWalkIn = await notifier.issueInvoice();
      expect(resultWalkIn, isNull);
      expect(
        container.read(newBillProvider).error,
        equals('Party is required for credit or unpaid balance'),
      );

      // Set party
      final party = await partyRepo.save(
        name: 'Credit Customer',
        phone: '9998887770',
        stateCode: '27',
      );
      notifier.setParty(party);

      final resultWithParty = await notifier.issueInvoice();
      expect(resultWithParty, isNotNull);
      expect(resultWithParty!.partyId, equals(party.id));
    });

    test('4. Double-tap issues one invoice', () async {
      final product = await productRepo.save(
        name: 'Soap Bar',
        hsn: '3401',
        gstRateBp: 1800,
        pricePaise: 4000,
        costPaise: 3000,
        trackStock: true,
        reorderLevel: 0,
      );
      final pws = ProductWithStock(product: product, stockMilli: 10000);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(newBillProvider.notifier);
      notifier.addProduct(pws);

      // Call issueInvoice twice concurrently (simulating double tap)
      final future1 = notifier.issueInvoice();
      final future2 = notifier.issueInvoice();

      final results = await Future.wait([future1, future2]);

      // Exactly one invocation succeeds, the second returns null
      final nonNullResults = results.where((r) => r != null).toList();
      expect(nonNullResults.length, equals(1));

      // Verify DB has only 1 document created
      final allDocs = await db.select(db.documents).get();
      expect(allDocs.length, equals(1));
    });

    test('5. Cancel creates a credit note and restores stock', () async {
      final product = await productRepo.save(
        name: 'Wheat Flour 10kg',
        hsn: '1101',
        gstRateBp: 500,
        pricePaise: 45000,
        costPaise: 38000,
        trackStock: true,
        openingStockMilli: 10000, // Initial stock = 10 units
        reorderLevel: 1000,
      );

      // Check opening stock
      var productsList = await productRepo.watchProducts().first;
      expect(productsList.first.stockMilli, equals(10000));

      // Issue invoice for 2 units (2000 milli)
      final issuedDoc = await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 2000,
            ratePaise: product.pricePaise,
            gstRateBp: product.gstRateBp,
          ),
        ],
        isInterState: false,
        payments: [
          const PaymentParam(method: 'cash', amountPaise: 47250),
        ],
      );

      expect(issuedDoc.status, equals('issued'));

      // Verify stock deducted to 8000 milli
      productsList = await productRepo.watchProducts().first;
      expect(productsList.first.stockMilli, equals(8000));

      // Cancel invoice
      final creditNoteDoc = await docRepo.cancelInvoice(
        documentId: issuedDoc.id,
        reason: 'Customer return',
      );

      // Verify original doc status is cancelled
      final updatedOrigDoc = await (db.select(db.documents)..where((t) => t.id.equals(issuedDoc.id))).getSingle();
      expect(updatedOrigDoc.status, equals('cancelled'));

      // Verify credit note document created
      expect(creditNoteDoc.docType, equals('credit_note'));
      expect(creditNoteDoc.refDocumentId, equals(issuedDoc.id));

      // Verify stock restored to 10000 milli
      productsList = await productRepo.watchProducts().first;
      expect(productsList.first.stockMilli, equals(10000));
    });

    test('6. Draft survives a new database instance', () async {
      final product = await productRepo.save(
        name: 'Tea Powder 250g',
        hsn: '0902',
        gstRateBp: 500,
        pricePaise: 12000,
        costPaise: 9500,
        trackStock: true,
        reorderLevel: 0,
      );

      final pws = ProductWithStock(product: product, stockMilli: 10000);

      final party = await partyRepo.save(
        name: 'Draft Customer',
        phone: '9888777666',
        stateCode: '27',
      );

      final draftPayload = {
        'lines': [
          CartLine(
            product: pws,
            qtyMilli: 2000, // 2 units
            ratePaise: 12000,
            gstRateBp: 500,
          ).toJson(),
        ],
        'partyId': party.id,
        'paymentMethod': 'upi',
        'customPaidAmountPaise': null,
      };

      await docRepo.saveDraftCart(
        partyId: party.id,
        cartJson: jsonEncode(draftPayload),
      );

      // Load draft cart from database instance
      final loadedDraft = await docRepo.getDraftCart();
      expect(loadedDraft, isNotNull);
      expect(loadedDraft!.partyId, equals(party.id));

      final loadedMap = jsonDecode(loadedDraft.cartJson) as Map<String, dynamic>;
      final linesList = (loadedMap['lines'] as List<dynamic>)
          .map((l) => CartLine.fromJson(l as Map<String, dynamic>))
          .toList();

      expect(linesList.length, equals(1));
      expect(linesList.first.product.product.name, equals('Tea Powder 250g'));
      expect(linesList.first.qtyMilli, equals(2000));
      expect(loadedMap['paymentMethod'], equals('upi'));
    });

    test('7. Migration from v1 adds the triggers', () async {
      final testDb = AppDatabase(NativeDatabase.memory());
      await testDb.customSelect('SELECT 1').get();

      // Drop triggers to simulate a v1 database missing triggers
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_issued_doc_update;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_issued_doc_delete;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_doc_lines_update;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_doc_lines_delete;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_payments_update;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_payments_delete;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_stock_movements_update;');
      await testDb.customStatement('DROP TRIGGER IF EXISTS prevent_stock_movements_delete;');

      // Run onUpgrade from version 1 to 2
      final migrator = Migrator(testDb);
      await testDb.migration.onUpgrade(migrator, 1, 2);

      final triggerRows = await testDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'trigger';",
      ).get();
      final triggerNames = triggerRows.map((r) => r.read<String>('name')).toSet();

      expect(triggerNames, containsAll([
        'prevent_issued_doc_update',
        'prevent_issued_doc_delete',
        'prevent_doc_lines_update',
        'prevent_doc_lines_delete',
        'prevent_payments_update',
        'prevent_payments_delete',
        'prevent_stock_movements_update',
        'prevent_stock_movements_delete',
      ]));

      await testDb.close();
    });

    test('8. A cancel that also tries to change total_paise fails', () async {
      final product = await productRepo.save(
        name: 'Test Item',
        hsn: '1001',
        gstRateBp: 500,
        pricePaise: 10000,
        costPaise: 8000,
        trackStock: false,
        reorderLevel: 0,
      );

      final doc = await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 1000,
            ratePaise: product.pricePaise,
            gstRateBp: product.gstRateBp,
          ),
        ],
        isInterState: false,
      );

      expect(doc.status, equals('issued'));

      // Updating status to 'cancelled' AND total_paise at the same time must fail
      expect(
        () async => await (db.update(db.documents)..where((t) => t.id.equals(doc.id)))
            .write(const DocumentsCompanion(
              status: Value('cancelled'),
              totalPaise: Value(99999),
            )),
        throwsA(isA<Object>()),
      );

      // Updating status to 'cancelled' WITHOUT changing total_paise must succeed
      await (db.update(db.documents)..where((t) => t.id.equals(doc.id)))
          .write(const DocumentsCompanion(status: Value('cancelled')));

      final updatedDoc = await (db.select(db.documents)..where((t) => t.id.equals(doc.id))).getSingle();
      expect(updatedDoc.status, equals('cancelled'));
    });

    test('9. Cancel of a fully paid invoice leaves cash total at zero', () async {
      final product = await productRepo.save(
        name: 'Cash Item',
        hsn: '1001',
        gstRateBp: 500,
        pricePaise: 10000,
        costPaise: 8000,
        trackStock: false,
        reorderLevel: 0,
      );

      const totalPaise = 10500; // 10000 + 500 tax

      final issuedDoc = await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 1000,
            ratePaise: product.pricePaise,
            gstRateBp: product.gstRateBp,
          ),
        ],
        isInterState: false,
        payments: const [
          PaymentParam(method: 'cash', amountPaise: totalPaise),
        ],
      );

      // Initial cash sum
      final initialCashRows = await (db.select(db.payments)
        ..where((t) => t.businessId.equals(businessId))
        ..where((t) => t.method.equals('cash'))).get();
      final initialCashTotal = initialCashRows.fold<int>(0, (sum, p) => sum + p.amountPaise);
      expect(initialCashTotal, equals(totalPaise));

      // Cancel invoice
      await docRepo.cancelInvoice(
        documentId: issuedDoc.id,
        reason: 'Customer return',
      );

      // Final cash sum
      final finalCashRows = await (db.select(db.payments)
        ..where((t) => t.businessId.equals(businessId))
        ..where((t) => t.method.equals('cash'))).get();
      final finalCashTotal = finalCashRows.fold<int>(0, (sum, p) => sum + p.amountPaise);
      expect(finalCashTotal, equals(0));
    });

    test('10. Cancel of a credit invoice reduces the party balance', () async {
      final party = await partyRepo.save(
        name: 'Credit Customer',
        phone: '9876543210',
        stateCode: '27',
      );

      final product = await productRepo.save(
        name: 'Credit Item',
        hsn: '1001',
        gstRateBp: 500,
        pricePaise: 20000,
        costPaise: 15000,
        trackStock: false,
        reorderLevel: 0,
      );

      final issuedDoc = await docRepo.issueInvoice(
        partyId: party.id,
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 1000,
            ratePaise: product.pricePaise,
            gstRateBp: product.gstRateBp,
          ),
        ],
        isInterState: false,
        payments: null,
      );

      Future<int> getPartyBalance() async {
        final docs = await (db.select(db.documents)..where((t) => t.partyId.equals(party.id))).get();
        int invoices = 0;
        int creditNotes = 0;
        for (final d in docs) {
          if (d.docType == 'invoice') {
            invoices += d.totalPaise;
          } else if (d.docType == 'credit_note') {
            creditNotes += d.totalPaise;
          }
        }
        final pays = await (db.select(db.payments)..where((t) => t.partyId.equals(party.id))).get();
        int paid = pays.fold<int>(0, (sum, p) => sum + p.amountPaise);
        return invoices - creditNotes - paid;
      }

      final balanceBefore = await getPartyBalance();
      expect(balanceBefore, equals(21000));

      await docRepo.cancelInvoice(
        documentId: issuedDoc.id,
        reason: 'Credit return',
      );

      final balanceAfter = await getPartyBalance();
      expect(balanceAfter, equals(0));
    });
  });
}
