import 'package:belling/core/business_math.dart';
import 'package:belling/data/database.dart';
import 'package:belling/data/records.dart';
import 'package:belling/data/repositories/business_repository.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('business math', () {
    test('distributeDiscount sums exactly and respects caps', () {
      final d = distributeDiscount([10000, 20000, 30000], 1000);
      expect(d.fold<int>(0, (a, b) => a + b), 1000);
      expect(distributeDiscount([500, 500], 5000), [500, 500]);
      expect(distributeDiscount([100, 100, 100], 100).fold<int>(0, (a, b) => a + b), 100);
      expect(distributeDiscount([0, 0], 100), [0, 0]);
      expect(distributeDiscount([1000], 0), [0]);
    });

    test('weighted average cost', () {
      expect(weightedAverageCost(stockMilli: 10000, oldCostPaise: 100, buyQtyMilli: 10000, buyCostPaise: 200), 150);
      expect(weightedAverageCost(stockMilli: 0, oldCostPaise: 100, buyQtyMilli: 5000, buyCostPaise: 300), 300);
      expect(weightedAverageCost(stockMilli: 5000, oldCostPaise: 100, buyQtyMilli: 0, buyCostPaise: 300), 100);
    });

    test('supplierPayable never negative', () {
      expect(supplierPayable(purchasedPaise: 1000, paidPaise: 400), 600);
      expect(supplierPayable(purchasedPaise: 1000, paidPaise: 1500), 0);
    });
  });

  group('BusinessRepository', () {
    late AppDatabase db;
    late BusinessRepository repo;
    late ProductRepository products;
    late RecordsRepository records;
    const bid = 'local-business';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
            id: bid,
            businessId: bid,
            name: 'T',
            stateCode: '27',
            address: 'x',
            createdAt: DateTime.now(),
          ));
      products = ProductRepository(db, bid);
      records = RecordsRepository(db, bid, 'local-device');
      repo = BusinessRepository(db, records, products);
    });

    tearDown(() => db.close());

    test('records save/list/remove and queue sync commands', () async {
      final id = await records.save('expense', {'amount_paise': 500});
      expect((await records.list('expense')).length, 1);
      await records.remove(id);
      expect(await records.list('expense'), isEmpty);
      final cmds = await db.select(db.outboxCommands).get();
      expect(cmds.where((c) => c.commandType == 'push_record').length, 2);
    });

    test('purchase adds stock, updates average cost, tracks supplier due', () async {
      final p = await products.save(
        name: 'Rice',
        hsn: '1006',
        gstRateBp: 500,
        pricePaise: 5000,
        costPaise: 3000,
        trackStock: true,
        openingStockMilli: 10000,
        reorderLevel: 0,
      );
      final sid = await repo.saveSupplier(name: 'Mehta Traders');
      await repo.savePurchase(
        supplierId: sid,
        supplierName: 'Mehta Traders',
        lines: [PurchaseLine(productId: p.id, name: 'Rice', qtyMilli: 10000, costPaise: 5000)],
        paidPaise: 20000,
      );
      final after = await products.getById(p.id);
      expect(after!.stockMilli, 20000);
      expect(after.product.costPaise, 4000); // avg of 3000 and 5000
      final s = (await repo.supplierSummaries()).single;
      expect(s.purchasedPaise, 50000);
      expect(s.duePaise, 30000);
      await repo.paySupplier(supplierId: sid, amountPaise: 30000);
      expect((await repo.supplierSummaries()).single.duePaise, 0);
    });

    test('purchase validates input', () async {
      expect(() => repo.savePurchase(lines: [], paidPaise: 0), throwsArgumentError);
    });

    test('expenses total within range', () async {
      final now = DateTime.now();
      await repo.saveExpense(category: 'Rent', amountPaise: 100000, date: now);
      await repo.saveExpense(category: 'Tea', amountPaise: 2000, date: now.subtract(const Duration(days: 40)));
      final sum = await repo.expensesTotal(now.subtract(const Duration(days: 1)), now.add(const Duration(days: 1)));
      expect(sum, 100000);
    });

    test('applyServerRow keeps newer local edit', () async {
      final id = await records.save('expense', {'amount_paise': 1});
      await RecordsRepository.applyServerRow(db, {
        'id': id,
        'business_id': bid,
        'kind': 'expense',
        'data': {'amount_paise': 999},
        'deleted': false,
        'created_at': '2020-01-01T00:00:00Z',
        'updated_at': '2020-01-01T00:00:00Z',
        'server_seq': 5,
      });
      expect((await records.get(id))!.integer('amount_paise'), 1);
    });
  });
}
