import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class ProductWithStock {
  final Product product;
  final int stockMilli;

  const ProductWithStock({
    required this.product,
    required this.stockMilli,
  });

  bool get isLowStock => product.trackStock && stockMilli <= product.reorderLevel;
}

class ProductRepository {
  final AppDatabase db;
  final String businessId;
  final String deviceId;

  ProductRepository(this.db, this.businessId, [this.deviceId = 'local-device']);

  /// Streams list of products with current stock on hand (SUM of qty_milli from stock_movements).
  Stream<List<ProductWithStock>> watchProducts({String search = ''}) {
    final stockQtyExp = db.stockMovements.qtyMilli.sum();

    final query = db.select(db.products).join([
      leftOuterJoin(
        db.stockMovements,
        db.stockMovements.productId.equalsExp(db.products.id),
      ),
    ])
      ..where(db.products.businessId.equals(businessId));

    if (search.trim().isNotEmpty) {
      final term = '%${search.trim().toLowerCase()}%';
      query.where(
        db.products.name.lower().like(term) |
            db.products.barcode.lower().like(term) |
            db.products.hsn.lower().like(term),
      );
    }

    query.groupBy([db.products.id]);
    query.addColumns([stockQtyExp]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final product = row.readTable(db.products);
        final stockMilli = row.read(stockQtyExp) ?? 0;
        return ProductWithStock(
          product: product,
          stockMilli: stockMilli,
        );
      }).toList();
    });
  }

  /// A UPC-A code (12 digits) is often reported as EAN-13 with a leading 0 and
  /// vice versa, so look up both spellings.
  List<String> _barcodeVariants(String code) {
    final v = <String>{code};
    if (RegExp(r'^\d{12}$').hasMatch(code)) v.add('0$code');
    if (RegExp(r'^0\d{12}$').hasMatch(code)) v.add(code.substring(1));
    return v.toList();
  }

  /// Gets one product (with current stock) by id for the current business.
  Future<ProductWithStock?> getById(String id) async {
    final stockQtyExp = db.stockMovements.qtyMilli.sum();
    final query = db.select(db.products).join([
      leftOuterJoin(
        db.stockMovements,
        db.stockMovements.productId.equalsExp(db.products.id),
      ),
    ])
      ..where(db.products.businessId.equals(businessId) & db.products.id.equals(id))
      ..groupBy([db.products.id])
      ..addColumns([stockQtyExp])
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return ProductWithStock(
      product: row.readTable(db.products),
      stockMilli: row.read(stockQtyExp) ?? 0,
    );
  }

  /// Gets a single product by barcode for the current business.
  Future<ProductWithStock?> getByBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return null;

    final stockQtyExp = db.stockMovements.qtyMilli.sum();
    final query = db.select(db.products).join([
      leftOuterJoin(
        db.stockMovements,
        db.stockMovements.productId.equalsExp(db.products.id),
      ),
    ])
      ..where(
        db.products.businessId.equals(businessId) &
            db.products.barcode.isIn(_barcodeVariants(cleanBarcode)),
      )
      ..groupBy([db.products.id])
      ..addColumns([stockQtyExp])
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return ProductWithStock(
      product: row.readTable(db.products),
      stockMilli: row.read(stockQtyExp) ?? 0,
    );
  }

  /// Saves or updates a product.
  /// Validates name, price, and barcode uniqueness within the business.
  /// If creating a new product with opening stock, writes a stock_movement with reason 'opening'.
  Future<Product> save({
    String? id,
    required String name,
    String? barcode,
    required String hsn,
    required int gstRateBp,
    required int pricePaise,
    required int costPaise,
    bool trackStock = true,
    int openingStockMilli = 0,
    int reorderLevel = 10,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Product name is required');
    }
    if (pricePaise < 0) {
      throw ArgumentError('Price must be non-negative');
    }

    final cleanBarcode = barcode?.trim();
    final barcodeVal = (cleanBarcode != null && cleanBarcode.isNotEmpty) ? cleanBarcode : null;

    // Validate barcode uniqueness within business
    if (barcodeVal != null) {
      final existing = await (db.select(db.products)
            ..where((tbl) =>
                tbl.businessId.equals(businessId) &
                tbl.barcode.equals(barcodeVal)))
          .getSingleOrNull();

      if (existing != null && existing.id != id) {
        throw Exception('Barcode already exists for another product');
      }
    }

    return db.transaction(() async {
      final now = DateTime.now();
      Product resultProduct;

      if (id == null || id.isEmpty) {
        final newId = const Uuid().v4();
        await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: newId,
            businessId: businessId,
            name: cleanName,
            barcode: Value(barcodeVal),
            hsn: hsn.trim(),
            gstRateBp: gstRateBp,
            pricePaise: pricePaise,
            costPaise: costPaise,
            trackStock: trackStock,
            reorderLevel: reorderLevel,
            createdAt: now,
            updatedAt: Value(now),
          ),
        );

        if (trackStock && openingStockMilli != 0) {
          final openingMovementId = const Uuid().v4();
          await db.into(db.stockMovements).insert(
            StockMovementsCompanion.insert(
              id: openingMovementId,
              businessId: businessId,
              productId: newId,
              qtyMilli: openingStockMilli,
              reason: 'opening',
              documentId: const Value.absent(),
              createdAt: now,
            ),
          );
          await db.enqueueOutboxCommand(
            businessId: businessId,
            deviceId: deviceId,
            commandType: 'push_stock_movement',
            payload: {'stock_movement_id': openingMovementId},
          );
        }

        final pNew = await (db.select(db.products)..where((tbl) => tbl.id.equals(newId))).getSingleOrNull();
        if (pNew == null) throw StateError('Failed to load created product');
        resultProduct = pNew;
      } else {
        await (db.update(db.products)..where((tbl) => tbl.id.equals(id))).write(
          ProductsCompanion(
            name: Value(cleanName),
            barcode: Value(barcodeVal),
            hsn: Value(hsn.trim()),
            gstRateBp: Value(gstRateBp),
            pricePaise: Value(pricePaise),
            costPaise: Value(costPaise),
            trackStock: Value(trackStock),
            reorderLevel: Value(reorderLevel),
            updatedAt: Value(now),
          ),
        );

        final pUpdated = await (db.select(db.products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
        if (pUpdated == null) throw StateError('Failed to load updated product');
        resultProduct = pUpdated;
      }

      await db.enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'upsert_product',
        payload: productToPayload(resultProduct),
      );

      return resultProduct;
    });
  }

  /// Adds (qtyMilli > 0) or removes (qtyMilli < 0) stock by appending a movement.
  /// Stock is never edited in place: it is the sum of its movements.
  Future<void> adjustStock({
    required String productId,
    required int qtyMilli,
    required String reason, // 'purchase' | 'adjustment'
  }) async {
    if (qtyMilli == 0) throw ArgumentError('Quantity cannot be zero');
    await db.transaction(() async {
      final movementId = const Uuid().v4();
      await db.into(db.stockMovements).insert(
            StockMovementsCompanion.insert(
              id: movementId,
              businessId: businessId,
              productId: productId,
              qtyMilli: qtyMilli,
              reason: reason,
              documentId: const Value.absent(),
              createdAt: DateTime.now(),
            ),
          );
      await db.enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'push_stock_movement',
        payload: {'stock_movement_id': movementId},
      );
    });
  }

  /// Archives / deletes a product.
  Future<void> archive(String productId) async {
    await (db.delete(db.products)..where((tbl) => tbl.id.equals(productId))).go();
  }
}
