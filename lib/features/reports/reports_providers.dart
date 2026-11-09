import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'reports_repository.dart';

final reportsPresetProvider = StateProvider<DateRangePreset>((ref) => DateRangePreset.today);

final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final reportsDateRangeProvider = Provider<DateTimeRange>((ref) {
  final preset = ref.watch(reportsPresetProvider);
  final customRange = ref.watch(customDateRangeProvider);
  return getDateRangeForPreset(preset, customRange: customRange);
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return ReportsRepository(db, businessId);
});

/// Ticks whenever bills, payments, stock, items or parties change, so the
/// reports refresh by themselves instead of showing stale numbers.
final reportsRefreshProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  var n = 0;
  return db
      .tableUpdates(TableUpdateQuery.onAllTables([
        db.documents,
        db.documentLines,
        db.payments,
        db.stockMovements,
        db.products,
        db.parties,
      ]))
      .map((_) => ++n);
});

final salesReportProvider = FutureProvider<SalesReportData>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getSalesReport(range.start, range.end);
});

final profitProvider = FutureProvider<ProfitData>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getProfit(range.start, range.end);
});

final topItemsByAmountProvider = FutureProvider<List<TopItemData>>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getTopItemsByAmount(range.start, range.end);
});

final topItemsByQtyProvider = FutureProvider<List<TopItemData>>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getTopItemsByQty(range.start, range.end);
});

final lowStockProvider = FutureProvider<List<LowStockData>>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getLowStockItems();
});

final topReceivablesProvider = FutureProvider<List<ReceivableData>>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getTopReceivables();
});

final gstSummaryProvider = FutureProvider<GstSectionSummary>((ref) async {
  ref.watch(reportsRefreshProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getGstSummary(range.start, range.end);
});
