import 'package:belling/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('partial sale return', () {
    late AppDatabase db;
    const businessId = 'bus-ret';
    const deviceId = 'dev-ret';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
            id: businessId, businessId: businessId, name: 'B', stateCode: '24', address: 'x', createdAt: DateTime.now()));
      await db.into(db.devices).insertOnConflictUpdate(
          DevicesCompanion.insert(id: deviceId, businessId: businessId, name: 'POS', seriesPrefix: 'A', createdAt: DateTime.now()));
      await db.into(db.products).insert(ProductsCompanion.insert(
            id: 'p1',
            businessId: businessId,
            name: 'Item',
            hsn: '1101',
            gstRateBp: 0,
            pricePaise: 10000,
            costPaise: 5000,
            trackStock: true,
            reorderLevel: 0,
            createdAt: DateTime.now(),
          ));
    });

    tearDown(() => db.close());

    Future<Document> sell({required int paid}) => db.issueDocument(
          businessId: businessId,
          deviceId: deviceId,
          docType: 'invoice',
          financialYear: '26-27',
          isInterState: false,
          payments: paid > 0 ? [PaymentParam(method: 'cash', amountPaise: paid)] : null,
          lines: [
            IssueDocumentLineParam(productId: 'p1', name: 'Item', hsn: '1101', qtyMilli: 4000, ratePaise: 10000, gstRateBp: 0),
          ],
        );

    Future<String> lineId(String docId) async =>
        (await (db.select(db.documentLines)..where((t) => t.documentId.equals(docId))).getSingle()).id;

    test('fully paid bill: return 1 of 4 refunds that amount, stock goes back', () async {
      final inv = await sell(paid: 40000);
      final cn = await db.returnItems(
        businessId: businessId,
        deviceId: deviceId,
        documentId: inv.id,
        returnQtyByLineId: {await lineId(inv.id): 1000},
        reason: 't',
      );
      expect(cn.totalPaise, 10000);
      final refunds = await (db.select(db.payments)..where((t) => t.documentId.equals(cn.id))).get();
      expect(refunds.single.amountPaise, -10000);
      final stock = await (db.select(db.stockMovements)..where((t) => t.documentId.equals(cn.id))).getSingle();
      expect(stock.qtyMilli, 1000);
      final orig = await (db.select(db.documents)..where((t) => t.id.equals(inv.id))).getSingle();
      expect(orig.status, isNot('cancelled'));
    });

    test('udhar bill: return reduces due, no cash refund', () async {
      final inv = await sell(paid: 0);
      final cn = await db.returnItems(
        businessId: businessId,
        deviceId: deviceId,
        documentId: inv.id,
        returnQtyByLineId: {await lineId(inv.id): 2000},
        reason: 't',
      );
      expect(cn.totalPaise, 20000);
      final refunds = await (db.select(db.payments)..where((t) => t.documentId.equals(cn.id))).get();
      expect(refunds, isEmpty);
    });

    test('half paid bill: refund only the overpaid part', () async {
      final inv = await sell(paid: 20000); // owes 20000
      // return 3 of 4 -> still owed = 40000-30000 = 10000, paid 20000 -> refund 10000
      final cn = await db.returnItems(
        businessId: businessId,
        deviceId: deviceId,
        documentId: inv.id,
        returnQtyByLineId: {await lineId(inv.id): 3000},
        reason: 't',
      );
      final refunds = await (db.select(db.payments)..where((t) => t.documentId.equals(cn.id))).get();
      expect(refunds.single.amountPaise, -10000);
    });

    test('cannot return more than sold, across several returns', () async {
      final inv = await sell(paid: 40000);
      final id = await lineId(inv.id);
      await db.returnItems(businessId: businessId, deviceId: deviceId, documentId: inv.id, returnQtyByLineId: {id: 3000}, reason: 't');
      expect(
        () => db.returnItems(businessId: businessId, deviceId: deviceId, documentId: inv.id, returnQtyByLineId: {id: 2000}, reason: 't'),
        throwsStateError,
      );
    });

    test('empty return is rejected', () async {
      final inv = await sell(paid: 0);
      expect(
        () => db.returnItems(businessId: businessId, deviceId: deviceId, documentId: inv.id, returnQtyByLineId: {}, reason: 't'),
        throwsStateError,
      );
    });
  });
}
