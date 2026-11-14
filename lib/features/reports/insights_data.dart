import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import 'reports_providers.dart';
import 'reports_repository.dart';

class ItemProfitRow {
  ItemProfitRow(this.name);
  final String name;
  int qtyMilli = 0;
  int revenuePaise = 0;
  int costPaise = 0;
  bool noCost = false;
  int get profitPaise => revenuePaise - costPaise;
  double get margin => revenuePaise <= 0 ? 0 : profitPaise * 100 / revenuePaise;
}

class SlowItemRow {
  SlowItemRow(this.name, this.stockMilli, this.valuePaise, this.daysSince);
  final String name;
  final int stockMilli;
  final int valuePaise;
  final int? daysSince; // null = never sold
}

class CustomerRow {
  CustomerRow(this.name);
  final String name;
  int bills = 0;
  int totalPaise = 0;
}

class MonthRow {
  MonthRow(this.month, this.totalPaise);
  final DateTime month;
  final int totalPaise;
}

class InsightsData {
  InsightsData({required this.items, required this.slow, required this.customers, required this.months});
  final List<ItemProfitRow> items;
  final List<SlowItemRow> slow;
  final List<CustomerRow> customers;
  final List<MonthRow> months; // oldest first, last 6 months

  int get thisMonth => months.isEmpty ? 0 : months.last.totalPaise;
  int get lastMonth => months.length < 2 ? 0 : months[months.length - 2].totalPaise;

  /// Change vs last month in percent, or null when there is nothing to compare.
  int? get changePct => lastMonth <= 0 ? null : ((thisMonth - lastMonth) * 100 / lastMonth).round();
}

/// Days without a sale after which an item counts as slow moving.
const kSlowDays = 60;

final insightsPresetProvider = StateProvider<DateRangePreset>((ref) => DateRangePreset.thisMonth);

final insightsProvider = FutureProvider.autoDispose<InsightsData>((ref) async {
  ref.watch(reportsRefreshProvider);
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  final range = getDateRangeForPreset(ref.watch(insightsPresetProvider));
  final now = DateTime.now();

  final allDocs = await (db.select(db.documents)..where((t) => t.businessId.equals(businessId))).get();
  final sign = {for (final d in allDocs) d.id: d.docType == 'credit_note' ? -1 : (d.docType == 'invoice' ? 1 : 0)};
  final allLines = await (db.select(db.documentLines)..where((t) => t.businessId.equals(businessId))).get();
  final docById = {for (final d in allDocs) d.id: d};
  final products = {
    for (final p in await (db.select(db.products)..where((t) => t.businessId.equals(businessId))).get()) p.id: p,
  };
  final parties = {
    for (final p in await (db.select(db.parties)..where((t) => t.businessId.equals(businessId))).get()) p.id: p,
  };

  // Profit by item in the chosen range + last sale date per item (all time).
  final itemRows = <String, ItemProfitRow>{};
  final lastSale = <String, DateTime>{};
  for (final l in allLines) {
    final doc = docById[l.documentId];
    final sg = sign[l.documentId] ?? 0;
    if (doc == null || sg == 0) continue;
    if (sg > 0) {
      final prev = lastSale[l.productId];
      if (prev == null || doc.issuedAt.isAfter(prev)) lastSale[l.productId] = doc.issuedAt;
    }
    if (doc.issuedAt.isBefore(range.start) || doc.issuedAt.isAfter(range.end)) continue;
    final unitCost = products[l.productId]?.costPaise ?? 0;
    final row = itemRows.putIfAbsent(l.productId, () => ItemProfitRow(l.name));
    if (unitCost == 0) row.noCost = true;
    row.qtyMilli += sg * l.qtyMilli;
    row.revenuePaise += sg * l.taxablePaise;
    row.costPaise += sg * ((l.qtyMilli * unitCost) / 1000).round();
  }
  final items = itemRows.values.where((r) => r.qtyMilli != 0 || r.revenuePaise != 0).toList()
    ..sort((a, b) => b.profitPaise.compareTo(a.profitPaise));

  // Best customers in range (net of credit notes, cancelled bills net to zero).
  final custRows = <String, CustomerRow>{};
  for (final d in allDocs) {
    final sg = sign[d.id] ?? 0;
    if (sg == 0 || d.partyId == null) continue;
    if (d.issuedAt.isBefore(range.start) || d.issuedAt.isAfter(range.end)) continue;
    final row = custRows.putIfAbsent(d.partyId!, () => CustomerRow(parties[d.partyId!]?.name ?? 'Customer'));
    if (sg > 0) row.bills++;
    row.totalPaise += sg * d.totalPaise;
  }
  final customers = custRows.values.where((c) => c.totalPaise > 0).toList()
    ..sort((a, b) => b.totalPaise.compareTo(a.totalPaise));

  // Last 6 months of net sales.
  final months = <MonthRow>[];
  for (var i = 5; i >= 0; i--) {
    final start = DateTime(now.year, now.month - i, 1);
    final end = DateTime(now.year, now.month - i + 1, 1);
    var total = 0;
    for (final d in allDocs) {
      final sg = sign[d.id] ?? 0;
      if (sg == 0) continue;
      if (!d.issuedAt.isBefore(start) && d.issuedAt.isBefore(end)) total += sg * d.totalPaise;
    }
    months.add(MonthRow(start, total));
  }

  // Slow moving stock.
  final stock = await ProductRepository(db, businessId).watchProducts().first;
  final slow = <SlowItemRow>[];
  for (final p in stock) {
    if (!p.product.trackStock || p.stockMilli <= 0) continue;
    final last = lastSale[p.product.id];
    final days = last == null ? null : now.difference(last).inDays;
    if (days != null && days < kSlowDays) continue;
    final value = ((p.stockMilli * p.product.costPaise) / 1000).round();
    slow.add(SlowItemRow(p.product.name, p.stockMilli, value, days));
  }
  slow.sort((a, b) => b.valuePaise.compareTo(a.valuePaise));

  return InsightsData(items: items, slow: slow, customers: customers, months: months);
});
