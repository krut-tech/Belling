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

final salesReportProvider = FutureProvider<SalesReportData>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getSalesReport(range.start, range.end);
});

final topItemsByAmountProvider = FutureProvider<List<TopItemData>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getTopItemsByAmount(range.start, range.end);
});

final topItemsByQtyProvider = FutureProvider<List<TopItemData>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getTopItemsByQty(range.start, range.end);
});

final lowStockProvider = FutureProvider<List<LowStockData>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getLowStockItems();
});

final topReceivablesProvider = FutureProvider<List<ReceivableData>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getTopReceivables();
});

final gstSummaryProvider = FutureProvider<GstSectionSummary>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final range = ref.watch(reportsDateRangeProvider);
  return repo.getGstSummary(range.start, range.end);
});
