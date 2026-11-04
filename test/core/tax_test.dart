import 'package:belling/core/tax.dart';
import 'package:belling/data/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GST Tax Calculations (lib/core/tax.dart)', () {
    test('5% GST calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10000, // ₹100.00
            gstRateBp: 500, // 5%
          ),
        ],
        isInterState: false,
      );

      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(250)); // ₹2.50
      expect(result.sgstPaise, equals(250)); // ₹2.50
      expect(result.igstPaise, equals(0));
      expect(result.totalBeforeRoundOffPaise, equals(10500)); // ₹105.00
      expect(result.roundOffPaise, equals(0));
      expect(result.totalPaise, equals(10500));
    });

    test('12% GST calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10000, // ₹100.00
            gstRateBp: 1200, // 12%
          ),
        ],
        isInterState: false,
      );

      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(600)); // ₹6.00
      expect(result.sgstPaise, equals(600)); // ₹6.00
      expect(result.totalPaise, equals(11200));
    });

    test('18% GST calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10000, // ₹100.00
            gstRateBp: 1800, // 18%
          ),
        ],
        isInterState: false,
      );

      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(900)); // ₹9.00
      expect(result.sgstPaise, equals(900)); // ₹9.00
      expect(result.totalPaise, equals(11800));
    });

    test('0% GST calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10000, // ₹100.00
            gstRateBp: 0, // 0%
          ),
        ],
        isInterState: false,
      );

      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(0));
      expect(result.sgstPaise, equals(0));
      expect(result.totalPaise, equals(10000));
    });

    test('Sample Invoice: Atta 2x285 @5%, Dishwash 3x100 @18%, Salt 4x25 @0%', () {
      final result = calculateTax(
        lines: const [
          // Atta: 2 x 285.00 at 5%
          TaxLineInput(
            qtyMilli: 2000,
            ratePaise: 28500,
            gstRateBp: 500,
          ),
          // Dishwash: 3 x 100.00 at 18%
          TaxLineInput(
            qtyMilli: 3000,
            ratePaise: 10000,
            gstRateBp: 1800,
          ),
          // Salt: 4 x 25.00 at 0%
          TaxLineInput(
            qtyMilli: 4000,
            ratePaise: 2500,
            gstRateBp: 0,
          ),
        ],
        isInterState: false,
      );

      // Taxable: 57000 + 30000 + 10000 = 97000 paise (970.00)
      expect(result.taxablePaise, equals(97000));
      // CGST: 1425 + 2700 + 0 = 4125 paise (41.25)
      expect(result.cgstPaise, equals(4125));
      // SGST: 1425 + 2700 + 0 = 4125 paise (41.25)
      expect(result.sgstPaise, equals(4125));
      expect(result.igstPaise, equals(0));

      // Total before round-off: 105250 paise (1,052.50)
      expect(result.totalBeforeRoundOffPaise, equals(105250));

      // Round-off: +50 paise
      expect(result.roundOffPaise, equals(50));

      // Total after round-off: 105300 paise (1,053.00)
      expect(result.totalPaise, equals(105300));
    });

    test('Inclusive price calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10500, // ₹105.00 inclusive of 5% tax
            gstRateBp: 500, // 5%
            priceIncludesTax: true,
          ),
        ],
        isInterState: false,
      );

      // Taxable = 10500 * 10000 / (10000 + 500) = 10000
      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(250));
      expect(result.sgstPaise, equals(250));
      expect(result.totalPaise, equals(10500));
    });

    test('Discount calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10000, // ₹100.00
            discountPaise: 1000, // ₹10.00 discount
            gstRateBp: 1800, // 18%
          ),
        ],
        isInterState: false,
      );

      // Taxable = 10000 - 1000 = 9000
      expect(result.taxablePaise, equals(9000));
      // Tax = 9000 * 1800 / 10000 = 1620 -> CGST 810, SGST 810
      expect(result.cgstPaise, equals(810));
      expect(result.sgstPaise, equals(810));
      expect(result.totalBeforeRoundOffPaise, equals(10620));
      expect(result.roundOffPaise, equals(-20));
      expect(result.totalPaise, equals(10600));
    });

    test('Fractional quantity (0.5 kg)', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 500, // 0.5 kg
            ratePaise: 20000, // ₹200.00 per kg
            gstRateBp: 500, // 5%
          ),
        ],
        isInterState: false,
      );

      // Gross = 500 * 20000 / 1000 = 10000 (₹100.00)
      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(250));
      expect(result.sgstPaise, equals(250));
      expect(result.totalPaise, equals(10500));
    });

    test('Inter-state (IGST) calculation', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10000, // ₹100.00
            gstRateBp: 1800, // 18%
          ),
        ],
        isInterState: true,
      );

      expect(result.taxablePaise, equals(10000));
      expect(result.cgstPaise, equals(0));
      expect(result.sgstPaise, equals(0));
      expect(result.igstPaise, equals(1800)); // ₹18.00 IGST
      expect(result.totalPaise, equals(11800));
    });

    test('Odd tax paise split', () {
      // 15 paise tax -> CGST 7, SGST 8
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 100, // 100 paise = ₹1.00
            gstRateBp: 1500, // 15%
          ),
        ],
        isInterState: false,
      );

      expect(result.taxablePaise, equals(100));
      // Tax = 100 * 1500 / 10000 = 15 paise
      expect(result.cgstPaise, equals(7)); // 15 ~/ 2
      expect(result.sgstPaise, equals(8)); // 15 - 7
      expect(result.cgstPaise + result.sgstPaise, equals(15));
    });

    test('Round-off up', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 9571,
            gstRateBp: 500,
          ),
        ],
        isInterState: false,
      );

      expect(result.totalBeforeRoundOffPaise % 100, greaterThanOrEqualTo(50));
      expect(result.roundOffPaise, greaterThan(0));
      expect(result.totalPaise % 100, equals(0));
    });

    test('Round-off down', () {
      final result = calculateTax(
        lines: const [
          TaxLineInput(
            qtyMilli: 1000,
            ratePaise: 10020, // ₹100.20
            gstRateBp: 0,
          ),
        ],
        isInterState: false,
      );

      expect(result.totalBeforeRoundOffPaise, equals(10020));
      expect(result.roundOffPaise, equals(-20));
      expect(result.totalPaise, equals(10000));
    });
  });

  group('Database issueDocument() & Hardening tests', () {
    late AppDatabase db;
    const businessId = 'bus-001';
    const deviceId = 'dev-001';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());

      // Seed business and device
      await db.into(db.businesses).insertOnConflictUpdate(
        BusinessesCompanion.insert(
          id: businessId,
          businessId: businessId,
          name: 'Test Business',
          stateCode: '27',
          address: 'Main Street',
          createdAt: DateTime.now(),
        ),
      );

      await db.into(db.devices).insertOnConflictUpdate(
        DevicesCompanion.insert(
          id: deviceId,
          businessId: businessId,
          name: 'Main POS',
          seriesPrefix: 'A',
          createdAt: DateTime.now(),
        ),
      );

      // Seed products: prod-1 with trackStock = true, prod-2 with trackStock = false
      await db.into(db.products).insert(
        ProductsCompanion.insert(
          id: 'prod-1',
          businessId: businessId,
          name: 'Atta',
          hsn: '1101',
          gstRateBp: 500,
          pricePaise: 28500,
          costPaise: 20000,
          trackStock: true,
          reorderLevel: 10,
          createdAt: DateTime.now(),
        ),
      );

      await db.into(db.products).insert(
        ProductsCompanion.insert(
          id: 'prod-2',
          businessId: businessId,
          name: 'Salt',
          hsn: '2501',
          gstRateBp: 0,
          pricePaise: 2500,
          costPaise: 1500,
          trackStock: false,
          reorderLevel: 0,
          createdAt: DateTime.now(),
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Sequential document numbering: A-0001, A-0002', () async {
      final doc1 = await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-1',
            name: 'Atta',
            hsn: '1101',
            qtyMilli: 2000,
            ratePaise: 28500,
            gstRateBp: 500,
          ),
        ],
        isInterState: false,
      );

      expect(doc1.number, equals('A-0001'));
      expect(doc1.status, equals('issued'));

      final doc2 = await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-2',
            name: 'Salt',
            hsn: '2501',
            qtyMilli: 1000,
            ratePaise: 2500,
            gstRateBp: 0,
          ),
        ],
        isInterState: false,
      );

      expect(doc2.number, equals('A-0002'));

      // Verify DB records
      final allDocs = await db.select(db.documents).get();
      expect(allDocs.length, equals(2));

      final lines = await db.select(db.documentLines).get();
      expect(lines.length, equals(2));

      final outbox = await db.select(db.outboxCommands).get();
      expect(outbox.length, equals(2));
      expect(outbox.first.commandType, equals('issue_document'));
    });

    test('Failed transaction (negative qtyMilli) throws ArgumentError and does not consume document number', () async {
      // 1. First document succeeds -> A-0001
      final doc1 = await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-1',
            name: 'Atta',
            hsn: '1101',
            qtyMilli: 1000,
            ratePaise: 28500,
            gstRateBp: 500,
          ),
        ],
        isInterState: false,
      );

      expect(doc1.number, equals('A-0001'));

      // 2. Second document fails due to negative qtyMilli -> throws ArgumentError
      expect(
        () async => await db.issueDocument(
          businessId: businessId,
          deviceId: deviceId,
          docType: 'invoice',
          financialYear: '2024-25',
          lines: const [
            IssueDocumentLineParam(
              productId: 'prod-2',
              name: 'Salt',
              hsn: '2501',
              qtyMilli: -1000, // Invalid negative qtyMilli
              ratePaise: 2500,
              gstRateBp: 0,
            ),
          ],
          isInterState: false,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // 3. Next document succeeds -> should be A-0002 (number NOT consumed)
      final doc3 = await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-2',
            name: 'Salt',
            hsn: '2501',
            qtyMilli: 1000,
            ratePaise: 2500,
            gstRateBp: 0,
          ),
        ],
        isInterState: false,
      );

      expect(doc3.number, equals('A-0002'));

      final allDocs = await db.select(db.documents).get();
      expect(allDocs.length, equals(2));
      expect(allDocs.map((d) => d.number), containsAll(['A-0001', 'A-0002']));
    });

    test('Stock movements created only for products with track_stock = true', () async {
      // prod-1 has trackStock = true, prod-2 has trackStock = false
      await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-1', // trackStock = true
            name: 'Atta',
            hsn: '1101',
            qtyMilli: 2000,
            ratePaise: 28500,
            gstRateBp: 500,
          ),
          IssueDocumentLineParam(
            productId: 'prod-2', // trackStock = false
            name: 'Salt',
            hsn: '2501',
            qtyMilli: 1000,
            ratePaise: 2500,
            gstRateBp: 0,
          ),
        ],
        isInterState: false,
      );

      final stockMovements = await db.select(db.stockMovements).get();
      expect(stockMovements.length, equals(1));
      expect(stockMovements.first.productId, equals('prod-1'));
      expect(stockMovements.first.qtyMilli, equals(-2000));
    });

    test('Triggers allow issued document status -> cancelled, but block other updates or deletes', () async {
      final doc = await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-1',
            name: 'Atta',
            hsn: '1101',
            qtyMilli: 1000,
            ratePaise: 28500,
            gstRateBp: 500,
          ),
        ],
        isInterState: false,
      );

      // 1. Updating status from issued -> cancelled SUCCEEDS
      await (db.update(db.documents)..where((t) => t.id.equals(doc.id)))
          .write(const DocumentsCompanion(status: Value('cancelled')));

      final updatedDoc = await (db.select(db.documents)..where((t) => t.id.equals(doc.id))).getSingle();
      expect(updatedDoc.status, equals('cancelled'));

      // 2. Updating an issued document to draft or modifying amounts FAILS
      final doc2 = await db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '2024-25',
        lines: const [
          IssueDocumentLineParam(
            productId: 'prod-1',
            name: 'Atta',
            hsn: '1101',
            qtyMilli: 1000,
            ratePaise: 28500,
            gstRateBp: 500,
          ),
        ],
        isInterState: false,
      );

      expect(
        () async => await (db.update(db.documents)..where((t) => t.id.equals(doc2.id)))
            .write(const DocumentsCompanion(totalPaise: Value(99999))),
        throwsA(isA<Object>()),
      );

      // 3. Deleting an issued document FAILS
      expect(
        () async => await (db.delete(db.documents)..where((t) => t.id.equals(doc2.id))).go(),
        throwsA(isA<Object>()),
      );

      // 4. Updating or deleting document_lines FAILS
      final line = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc2.id))).getSingle();
      expect(
        () async => await (db.update(db.documentLines)..where((t) => t.id.equals(line.id)))
            .write(const DocumentLinesCompanion(qtyMilli: Value(5000))),
        throwsA(isA<Object>()),
      );
      expect(
        () async => await (db.delete(db.documentLines)..where((t) => t.id.equals(line.id))).go(),
        throwsA(isA<Object>()),
      );

      // 5. Updating or deleting stock_movements FAILS
      final stock = await (db.select(db.stockMovements)..where((t) => t.documentId.equals(doc2.id))).getSingle();
      expect(
        () async => await (db.update(db.stockMovements)..where((t) => t.id.equals(stock.id)))
            .write(const StockMovementsCompanion(qtyMilli: Value(-999))),
        throwsA(isA<Object>()),
      );
      expect(
        () async => await (db.delete(db.stockMovements)..where((t) => t.id.equals(stock.id))).go(),
        throwsA(isA<Object>()),
      );

      // 6. Updating or deleting payments FAILS
      const paymentId = 'pay-001';
      await db.into(db.payments).insert(
        PaymentsCompanion.insert(
          id: paymentId,
          businessId: businessId,
          method: 'cash',
          amountPaise: 5000,
          paidAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      expect(
        () async => await (db.update(db.payments)..where((t) => t.id.equals(paymentId)))
            .write(const PaymentsCompanion(amountPaise: Value(10000))),
        throwsA(isA<Object>()),
      );
      expect(
        () async => await (db.delete(db.payments)..where((t) => t.id.equals(paymentId))).go(),
        throwsA(isA<Object>()),
      );
    });

    test('Unique index on document_series prevents duplicate series rows', () async {
      await db.into(db.documentSeries).insert(
        DocumentSeriesCompanion.insert(
          id: 'series-1',
          businessId: businessId,
          deviceId: deviceId,
          docType: 'invoice',
          financialYear: '2024-25',
          nextNumber: 1,
          createdAt: DateTime.now(),
        ),
      );

      expect(
        () async => await db.into(db.documentSeries).insert(
          DocumentSeriesCompanion.insert(
            id: 'series-2',
            businessId: businessId,
            deviceId: deviceId,
            docType: 'invoice',
            financialYear: '2024-25',
            nextNumber: 1,
            createdAt: DateTime.now(),
          ),
        ),
        throwsA(isA<Object>()), // Unique index violation
      );
    });
  });
}
