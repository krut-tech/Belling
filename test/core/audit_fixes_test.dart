import 'package:belling/data/database.dart';
import 'package:belling/features/sell/new_bill_notifier.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Issue validation (audit H1)', () {
    late AppDatabase db;
    const businessId = 'bus-audit';
    const deviceId = 'dev-audit';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.businesses).insertOnConflictUpdate(
            BusinessesCompanion.insert(
              id: businessId,
              businessId: businessId,
              name: 'Audit Biz',
              stateCode: '24',
              address: 'Main',
              createdAt: DateTime.now(),
            ),
          );
      await db.into(db.devices).insertOnConflictUpdate(
            DevicesCompanion.insert(
              id: deviceId,
              businessId: businessId,
              name: 'POS',
              seriesPrefix: 'A',
              createdAt: DateTime.now(),
            ),
          );
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'p1',
              businessId: businessId,
              name: 'Item',
              hsn: '1101',
              gstRateBp: 1800,
              pricePaise: 10000,
              costPaise: 5000,
              trackStock: false,
              reorderLevel: 0,
              createdAt: DateTime.now(),
            ),
          );
    });

    tearDown(() async => db.close());

    Future<Document> issue({
      int discount = 0,
      bool inclusive = false,
      List<PaymentParam>? payments,
      List<IssueDocumentLineParam>? lines,
    }) {
      return db.issueDocument(
        businessId: businessId,
        deviceId: deviceId,
        docType: 'invoice',
        financialYear: '26-27',
        isInterState: false,
        payments: payments,
        lines: lines ??
            [
              IssueDocumentLineParam(
                productId: 'p1',
                name: 'Item',
                hsn: '1101',
                qtyMilli: 1000,
                ratePaise: 10000,
                discountPaise: discount,
                gstRateBp: 1800,
                priceIncludesTax: inclusive,
              ),
            ],
      );
    }

    test('discount larger than line amount is rejected', () async {
      expect(() => issue(discount: 10001), throwsArgumentError);
    });

    test('negative discount is rejected', () async {
      expect(() => issue(discount: -1), throwsArgumentError);
    });

    test('negative payment is rejected', () async {
      expect(
        () => issue(payments: const [PaymentParam(method: 'cash', amountPaise: -5)]),
        throwsArgumentError,
      );
    });

    test('empty document is rejected', () async {
      expect(() => issue(lines: const []), throwsArgumentError);
    });

    test('discount equal to the line amount is allowed (free item)', () async {
      final doc = await issue(discount: 10000);
      expect(doc.totalPaise, 0);
    });

    test('cancelling a tax-inclusive invoice gives a credit note with the same total', () async {
      final inv = await issue(inclusive: true);
      final cn = await db.cancelInvoice(
        businessId: businessId,
        deviceId: deviceId,
        documentId: inv.id,
        reason: 'test',
      );
      expect(cn.totalPaise, inv.totalPaise);
      expect(cn.taxablePaise, inv.taxablePaise);
      expect(cn.cgstPaise, inv.cgstPaise);
      expect(cn.sgstPaise, inv.sgstPaise);
    });

    test('cancelling a tax-exclusive invoice gives a credit note with the same total', () async {
      final inv = await issue(discount: 1000);
      final cn = await db.cancelInvoice(
        businessId: businessId,
        deviceId: deviceId,
        documentId: inv.id,
        reason: 'test',
      );
      expect(cn.totalPaise, inv.totalPaise);
    });
  });

  group('Inter-state decision (audit C1)', () {
    Party party(String state) => Party(
          id: 'x',
          businessId: 'b',
          name: 'P',
          phone: '',
          stateCode: state,
          creditLimitPaise: 0,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

    test('walk-in is intra-state', () {
      expect(NewBillState(businessStateCode: '24').isInterState, isFalse);
    });

    test('same state as business is intra-state (CGST+SGST)', () {
      expect(NewBillState(party: party('24'), businessStateCode: '24').isInterState, isFalse);
    });

    test('different state is inter-state (IGST)', () {
      expect(NewBillState(party: party('27'), businessStateCode: '24').isInterState, isTrue);
    });

    test('unknown business state never forces IGST', () {
      expect(NewBillState(party: party('27')).isInterState, isFalse);
    });
  });
}
