import 'package:belling/data/database.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRepository Tests', () {
    late AppDatabase db;
    late ProductRepository repo;
    const businessId = 'local-business';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = ProductRepository(db, businessId);

      // Seed business
      await db.into(db.businesses).insertOnConflictUpdate(
        BusinessesCompanion.insert(
          id: businessId,
          businessId: businessId,
          name: 'Test Business',
          stateCode: '27',
          address: 'Main Store',
          createdAt: DateTime.now(),
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Opening stock creates stock_movement with reason "opening"', () async {
      final product = await repo.save(
        name: 'Atta 5kg',
        barcode: '8901234567890',
        hsn: '1101',
        gstRateBp: 500,
        pricePaise: 28500,
        costPaise: 20000,
        trackStock: true,
        openingStockMilli: 5000, // 5 units
        reorderLevel: 1000,
      );

      expect(product.name, equals('Atta 5kg'));

      // Check stock movements
      final movements = await db.select(db.stockMovements).get();
      expect(movements.length, equals(1));
      expect(movements.first.productId, equals(product.id));
      expect(movements.first.qtyMilli, equals(5000));
      expect(movements.first.reason, equals('opening'));

      // Check watchProducts stock calculation
      final productsList = await repo.watchProducts().first;
      expect(productsList.length, equals(1));
      expect(productsList.first.stockMilli, equals(5000));
    });

    test('Stock sum correctly aggregates multiple stock movements', () async {
      final product = await repo.save(
        name: 'Rice 1kg',
        hsn: '1006',
        gstRateBp: 500,
        pricePaise: 6000,
        costPaise: 4500,
        trackStock: true,
        openingStockMilli: 10000, // 10 units opening stock
        reorderLevel: 2000,
      );

      // Add a sale stock movement (-3 units)
      await db.into(db.stockMovements).insert(
        StockMovementsCompanion.insert(
          id: 'sm-1',
          businessId: businessId,
          productId: product.id,
          qtyMilli: -3000,
          reason: 'sale',
          createdAt: DateTime.now(),
        ),
      );

      // Add a purchase stock movement (+5 units)
      await db.into(db.stockMovements).insert(
        StockMovementsCompanion.insert(
          id: 'sm-2',
          businessId: businessId,
          productId: product.id,
          qtyMilli: 5000,
          reason: 'purchase',
          createdAt: DateTime.now(),
        ),
      );

      // Stock should be 10000 - 3000 + 5000 = 12000
      final productsList = await repo.watchProducts().first;
      expect(productsList.length, equals(1));
      expect(productsList.first.stockMilli, equals(12000));
    });

    test('Duplicate barcode within business throws exception', () async {
      await repo.save(
        name: 'Product 1',
        barcode: '123456',
        hsn: '1001',
        gstRateBp: 500,
        pricePaise: 1000,
        costPaise: 800,
        trackStock: true,
        reorderLevel: 0,
      );

      // Attempting to save a second product with the same barcode should fail
      expect(
        () async => await repo.save(
          name: 'Product 2',
          barcode: '123456',
          hsn: '1002',
          gstRateBp: 1800,
          pricePaise: 2000,
          costPaise: 1500,
          trackStock: true,
          reorderLevel: 0,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getByBarcode finds product by barcode', () async {
      await repo.save(
        name: 'Salt 1kg',
        barcode: '999888',
        hsn: '2501',
        gstRateBp: 0,
        pricePaise: 2500,
        costPaise: 1800,
        trackStock: true,
        openingStockMilli: 20000,
        reorderLevel: 5000,
      );

      final found = await repo.getByBarcode('999888');
      expect(found, isNotNull);
      expect(found!.product.name, equals('Salt 1kg'));
      expect(found.stockMilli, equals(20000));

      final notFound = await repo.getByBarcode('000000');
      expect(notFound, isNull);
    });
  });
}
