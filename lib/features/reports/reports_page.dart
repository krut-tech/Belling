import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'csv_export_service.dart';
import 'reports_providers.dart';
import 'reports_repository.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _showTopItemsByAmount = true;

  String _getPresetLabel(DateRangePreset preset, AppLocalizations l10n) {
    switch (preset) {
      case DateRangePreset.today:
        return l10n.dateRangeToday;
      case DateRangePreset.yesterday:
        return l10n.dateRangeYesterday;
      case DateRangePreset.thisWeek:
        return l10n.dateRangeThisWeek;
      case DateRangePreset.thisMonth:
        return l10n.dateRangeThisMonth;
      case DateRangePreset.lastMonth:
        return l10n.dateRangeLastMonth;
      case DateRangePreset.thisFinancialYear:
        return l10n.dateRangeThisFinancialYear;
      case DateRangePreset.custom:
        return l10n.dateRangeCustom;
    }
  }

  Future<void> _selectCustomDateRange() async {
    final currentRange = ref.read(reportsDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: currentRange,
    );

    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).state = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999),
      );
      ref.read(reportsPresetProvider.notifier).state = DateRangePreset.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedPreset = ref.watch(reportsPresetProvider);
    final dateRange = ref.watch(reportsDateRangeProvider);

    final salesAsync = ref.watch(salesReportProvider);
    final topAmountAsync = ref.watch(topItemsByAmountProvider);
    final topQtyAsync = ref.watch(topItemsByQtyProvider);
    final lowStockAsync = ref.watch(lowStockProvider);
    final receivablesAsync = ref.watch(topReceivablesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabReports),
        actions: [
          // Export CSV Popup Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download),
            tooltip: l10n.exportCsv,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onSelected: (val) async {
              final db = ref.read(databaseProvider);
              final businessId = ref.read(currentBusinessIdProvider);
              final exporter = CsvExportService(db, businessId);
              if (val == 'sales') {
                await exporter.exportSalesRegisterCsv(dateRange.start, dateRange.end);
              } else if (val == 'gst') {
                final summary = await ref.read(gstSummaryProvider.future);
                await exporter.exportGstSummaryCsv(summary);
              } else if (val == 'party') {
                await exporter.exportPartyBalancesCsv();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sales',
                child: SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.exportSalesRegister),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'gst',
                child: SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.exportGstSummary),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'party',
                child: SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.exportPartyBalances),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesReportProvider);
          ref.invalidate(topItemsByAmountProvider);
          ref.invalidate(topItemsByQtyProvider);
          ref.invalidate(lowStockProvider);
          ref.invalidate(topReceivablesProvider);
          ref.invalidate(gstSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: staggered([
            // Date Range Preset Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DateRangePreset.values.map((preset) {
                  final isSelected = selectedPreset == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 48,
                      child: ChoiceChip(
                        label: Text(_getPresetLabel(preset, l10n)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            if (preset == DateRangePreset.custom) {
                              _selectCustomDateRange();
                            } else {
                              ref.read(reportsPresetProvider.notifier).state = preset;
                            }
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Date Range Subtitle Display & GST Summary Navigation Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${dateRange.start.toIso8601String().substring(0, 10)} - ${dateRange.end.toIso8601String().substring(0, 10)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/reports/gst-summary'),
                    icon: const Icon(Icons.receipt_long, size: 20),
                    label: Text(l10n.viewGstSummary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 1: Sales & Payment Summary
            salesAsync.when(
              data: (data) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.point_of_sale, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            l10n.salesTotal,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetricTile(context, l10n.salesTotal, formatRupees(data.salesTotalPaise), isPrimary: true),
                          _buildMetricTile(context, l10n.numberOfBills, '${data.numberOfBills}'),
                          _buildMetricTile(context, l10n.creditGiven, formatRupees(data.creditGivenPaise)),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        l10n.paymentsReceived,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetricTile(context, l10n.cashPayments, formatRupees(data.paymentsReceivedCashPaise)),
                          _buildMetricTile(context, l10n.upiPayments, formatRupees(data.paymentsReceivedUpiPaise)),
                          _buildMetricTile(context, l10n.cardPayments, formatRupees(data.paymentsReceivedCardPaise)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))),
              error: (e, st) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e'))),
            ),
            const SizedBox(height: 16),

            // Card 2: Top 10 Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showTopItemsByAmount ? l10n.top10ItemsByAmount : l10n.top10ItemsByQty,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 48,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: true, label: Text('Amount')),
                              ButtonSegment(value: false, label: Text('Qty')),
                            ],
                            selected: {_showTopItemsByAmount},
                            onSelectionChanged: (val) {
                              if (val.isNotEmpty) {
                                setState(() => _showTopItemsByAmount = val.first);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _showTopItemsByAmount
                        ? topAmountAsync.when(
                            data: (items) => _buildTopItemsList(items, isAmount: true, l10n: l10n),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, st) => Text('Error: $e'),
                          )
                        : topQtyAsync.when(
                            data: (items) => _buildTopItemsList(items, isAmount: false, l10n: l10n),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, st) => Text('Error: $e'),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Low Stock List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          l10n.lowStockList,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    lowStockAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No low stock items',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                            ),
                          );
                        }
                        return Column(
                          children: items.map((item) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              minVerticalPadding: 8,
                              title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Reorder Level: ${item.reorderLevel}'),
                              trailing: Chip(
                                backgroundColor: Colors.orange.shade100,
                                label: Text(
                                  'Stock: ${formatMilliUnits(item.currentStockMilli)}',
                                  style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 4: Top 10 Receivables
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text(
                          l10n.receivablesTop10,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    receivablesAsync.when(
                      data: (parties) {
                        if (parties.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No outstanding receivables',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                            ),
                          );
                        }
                        return Column(
                          children: parties.map((p) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              minVerticalPadding: 8,
                              title: Text(p.partyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(p.phone),
                              trailing: Text(
                                formatRupees(p.balancePaise),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPrimary ? Theme.of(context).colorScheme.primary : null,
              ),
        ),
      ],
    );
  }

  Widget _buildTopItemsList(List<TopItemData> items, {required bool isAmount, required AppLocalizations l10n}) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          l10n.noDataAvailable,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final idx = entry.key + 1;
        final item = entry.value;
        final valStr = isAmount ? formatRupees(item.totalAmountPaise) : '${formatMilliUnits(item.totalQtyMilli)} units';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 8,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text('$idx', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Text(valStr, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}
