import '../../core/business_math.dart';
import '../database.dart';
import '../records.dart';
import 'product_repository.dart';
import '../../core/categories.dart';

class PurchaseLine {
  const PurchaseLine({
    required this.productId,
    required this.name,
    required this.qtyMilli,
    required this.costPaise,
  });
  final String productId;
  final String name;
  final int qtyMilli;
  final int costPaise;

  int get amountPaise => (qtyMilli * costPaise / 1000).round();

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'qty_milli': qtyMilli,
        'cost_paise': costPaise,
      };

  static PurchaseLine fromJson(Map<String, dynamic> j) => PurchaseLine(
        productId: j['product_id'] as String,
        name: (j['name'] as String?) ?? '',
        qtyMilli: (j['qty_milli'] as num).toInt(),
        costPaise: (j['cost_paise'] as num).toInt(),
      );
}

class SupplierSummary {
  const SupplierSummary({required this.supplier, required this.purchasedPaise, required this.paidPaise});
  final AppRecord supplier;
  final int purchasedPaise;
  final int paidPaise;
  int get duePaise => supplierPayable(purchasedPaise: purchasedPaise, paidPaise: paidPaise);
}

/// Suppliers, purchases (stock in), supplier payments, expenses and item
/// details. All stored in the generic [RecordsRepository].
class BusinessRepository {
  BusinessRepository(this.db, this.records, this.products);

  final AppDatabase db;
  final RecordsRepository records;
  final ProductRepository products;

  // ---------------- suppliers ----------------

  Future<String> saveSupplier({String? id, required String name, String phone = '', String gstin = '', String note = ''}) {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('Supplier ka naam daalo');
    return records.save(RecordKinds.supplier, {
      'name': n,
      'phone': phone.trim(),
      'gstin': gstin.trim().toUpperCase(),
      'note': note.trim(),
    }, id: id);
  }

  Future<List<AppRecord>> suppliers() => records.list(RecordKinds.supplier, newestFirst: false);

  Future<List<SupplierSummary>> supplierSummaries() async {
    final sup = await suppliers();
    final purchases = await records.list(RecordKinds.purchase);
    final pays = await records.list(RecordKinds.supplierPayment);
    return sup.map((s) {
      final bought = purchases.where((p) => p.str('supplier_id') == s.id).fold<int>(0, (a, p) => a + p.integer('total_paise'));
      final paidOnBill = purchases.where((p) => p.str('supplier_id') == s.id).fold<int>(0, (a, p) => a + p.integer('paid_paise'));
      final paidLater = pays.where((p) => p.str('supplier_id') == s.id).fold<int>(0, (a, p) => a + p.integer('amount_paise'));
      return SupplierSummary(supplier: s, purchasedPaise: bought, paidPaise: paidOnBill + paidLater);
    }).toList();
  }

  Future<void> paySupplier({required String supplierId, required int amountPaise, String note = ''}) async {
    if (amountPaise <= 0) throw ArgumentError('Amount 0 se zyada hona chahiye');
    await records.save(RecordKinds.supplierPayment, {
      'supplier_id': supplierId,
      'amount_paise': amountPaise,
      'note': note.trim(),
      'date': DateTime.now().toIso8601String(),
    });
  }

  // ---------------- purchases ----------------

  /// Records a purchase bill: adds stock for every line (tracked items) and
  /// optionally updates the item's cost to the weighted average.
  Future<String> savePurchase({
    String? supplierId,
    String supplierName = '',
    String billNo = '',
    required List<PurchaseLine> lines,
    required int paidPaise,
    bool updateCost = true,
    DateTime? date,
  }) async {
    if (lines.isEmpty) throw ArgumentError('Kam se kam ek item daalo');
    for (final l in lines) {
      if (l.qtyMilli <= 0) throw ArgumentError('${l.name}: quantity 0 se zyada honi chahiye');
      if (l.costPaise < 0) throw ArgumentError('${l.name}: cost galat hai');
    }
    final total = lines.fold<int>(0, (a, l) => a + l.amountPaise);
    if (paidPaise < 0 || paidPaise > total) throw ArgumentError('Paid amount 0 se bill total ke beech hona chahiye');

    return db.transaction(() async {
    final when = date ?? DateTime.now();
    final id = await records.save(RecordKinds.purchase, {
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'bill_no': billNo.trim(),
      'lines': lines.map((l) => l.toJson()).toList(),
      'total_paise': total,
      'paid_paise': paidPaise,
      'date': when.toIso8601String(),
    }, createdAt: when);

    for (final l in lines) {
      final p = await products.getById(l.productId);
      if (p == null) throw StateError('Item nahi mila (delete ho gaya?): ${l.name}');
      if (p.product.trackStock) {
        await products.adjustStock(productId: l.productId, qtyMilli: l.qtyMilli, reason: 'purchase');
      }
      if (updateCost && l.costPaise > 0) {
        final newCost = weightedAverageCost(
          stockMilli: p.stockMilli,
          oldCostPaise: p.product.costPaise,
          buyQtyMilli: l.qtyMilli,
          buyCostPaise: l.costPaise,
        );
        if (newCost != p.product.costPaise) await products.updateCost(l.productId, newCost);
      }
    }
    return id;
    });
  }

  Future<List<AppRecord>> purchases() => records.list(RecordKinds.purchase);

  // ---------------- expenses ----------------

  Future<String> saveExpense({
    String? id,
    required String category,
    required int amountPaise,
    String note = '',
    DateTime? date,
  }) {
    if (amountPaise <= 0) throw ArgumentError('Amount 0 se zyada hona chahiye');
    final when = date ?? DateTime.now();
    return records.save(RecordKinds.expense, {
      'category': category.trim().isEmpty ? 'Other' : category.trim(),
      'amount_paise': amountPaise,
      'note': note.trim(),
      'date': when.toIso8601String(),
    }, id: id, createdAt: when);
  }

  Future<List<AppRecord>> expenses() => records.list(RecordKinds.expense);

  Future<int> expensesTotal(DateTime start, DateTime end) async {
    final all = await expenses();
    var sum = 0;
    for (final e in all) {
      final d = DateTime.tryParse(e.str('date'));
      if (d == null) continue;
      if (!d.isBefore(start) && !d.isAfter(end)) sum += e.integer('amount_paise');
    }
    return sum;
  }

  // ---------------- item details (category / unit / MRP) ----------------

  Future<void> saveItemMeta(String productId, {String category = '', String unit = '', int mrpPaise = 0}) {
    return records.save(RecordKinds.itemMeta, {
      'category': category.trim(),
      'unit': unit.trim(),
      'mrp_paise': mrpPaise,
    }, id: productId).then((_) {});
  }

  /// Sets only the category of an item (keeps its unit and MRP).
  Future<void> saveItemCategory(String productId, String category) async {
    final existing = await records.get(productId);
    await saveItemMeta(
      productId,
      category: normalizeCategory(category),
      unit: existing?.str('unit') ?? '',
      mrpPaise: existing?.integer('mrp_paise') ?? 0,
    );
  }

  /// Renames a category (and its sub-categories) on every item that uses it.
  Future<int> renameCategory(String from, String to) async {
    final target = to.trim();
    if (target.isEmpty || target == from) return 0;
    var changed = 0;
    for (final m in (await itemMetas()).values) {
      final path = splitCategory(m.str('category'));
      if (path.parent != from) continue;
      await saveItemMeta(
        m.id,
        category: joinCategory(target, path.child),
        unit: m.str('unit'),
        mrpPaise: m.integer('mrp_paise'),
      );
      changed++;
    }
    return changed;
  }

  Future<Map<String, AppRecord>> itemMetas() async {
    final all = await records.list(RecordKinds.itemMeta);
    return {for (final r in all) r.id: r};
  }
}
