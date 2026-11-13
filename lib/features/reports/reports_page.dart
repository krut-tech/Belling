import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'csv_export_service.dart';
import 'reports_providers.dart';
import 'reports_repository.dart';
import '../../core/tr_text.dart';

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
    final profitAsync = ref.watch(profitProvider);
    final expenseTotal = ref.watch(expensesInRangeProvider).valueOrNull ?? 0;
    final topAmountAsync = ref.watch(topItemsByAmountProvider);
    final topQtyAsync = ref.watch(topItemsByQtyProvider);
    final lowStockAsync = ref.watch(lowStockProvider);
    final receivablesAsync = ref.watch(topReceivablesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: l10n.tabReports,
              subtitle:
                  '${dateRange.start.toIso8601String().substring(0, 10)} - ${dateRange.end.toIso8601String().substring(0, 10)}',
              actions: [
                PopupMenuButton<String>(
                  tooltip: l10n.exportCsv,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: const IgnorePointer(child: SoftIconButton(icon: Icons.file_download_outlined)),
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(salesReportProvider);
                  ref.invalidate(profitProvider);
                  ref.invalidate(expensesInRangeProvider);
                  ref.invalidate(topItemsByAmountProvider);
                  ref.invalidate(topItemsByQtyProvider);
                  ref.invalidate(lowStockProvider);
                  ref.invalidate(topReceivablesProvider);
                  ref.invalidate(gstSummaryProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  children: staggered([
                    // Date Range Preset Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: DateRangePreset.values.map((preset) {
                          final isSelected = selectedPreset == preset;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _pill(
                              _getPresetLabel(preset, l10n),
                              isSelected,
                              () {
                                if (preset == DateRangePreset.custom) {
                                  _selectCustomDateRange();
                                } else {
                                  ref.read(reportsPresetProvider.notifier).state = preset;
                                }
                              },
                              icon: preset == DateRangePreset.custom ? Icons.calendar_today : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // KPI cards
                    salesAsync.when(
                      data: (data) => Row(
                        children: [
                          Expanded(
                            child: _kpiCard(
                              l10n.salesTotal,
                              formatRupees(data.salesTotalPaise),
                              Icons.trending_up,
                              AppColors.accent,
                              AppColors.accentBg,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: profitAsync.maybeWhen(
                              data: (p) => _kpiCard(
                                'Net munafa',
                                formatRupees(p.profitPaise - expenseTotal),
                                Icons.account_balance_wallet_outlined,
                                AppColors.lightSuccess,
                                AppColors.goodBg,
                              ),
                              orElse: () => _kpiCard(
                                l10n.numberOfBills,
                                '${data.numberOfBills}',
                                Icons.receipt_long,
                                AppColors.blue,
                                AppColors.blueBg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SoftCard(child: SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))),
                      error: (e, st) => SoftCard(child: Text('Error: $e')),
                    ),
                    const SizedBox(height: 14),

                    // Sales & Payment Summary
                    salesAsync.maybeWhen(
                      data: (data) => SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.salesTotal,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
                      orElse: () => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 14),

                    // Profit estimate
                    profitAsync.when(
                      data: (p) => SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Munafa (profit)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetricTile(context, 'Net munafa', formatRupees(p.profitPaise - expenseTotal), isPrimary: true),
                                _buildMetricTile(context, 'Bikri (GST ke bina)', formatRupees(p.revenuePaise)),
                                _buildMetricTile(
                                  context,
                                  'Margin',
                                  '${(p.revenuePaise <= 0 ? 0 : (p.profitPaise - expenseTotal) * 100 / p.revenuePaise).toStringAsFixed(1)}%',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Maal ki cost: ${formatRupees(p.costPaise)} (item ki abhi ki cost price se). '
                              'Kharcha: ${formatRupees(expenseTotal)}. Net munafa = bikri − maal ki cost − kharcha.'
                              '${p.itemsWithoutCost > 0 ? ' ${p.itemsWithoutCost} item(s) ki cost price set nahi hai, unka munafa zyada dikhega.' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 14),

                    // Top 10 Items
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _showTopItemsByAmount ? l10n.top10ItemsByAmount : l10n.top10ItemsByQty,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _pill('Amount', _showTopItemsByAmount, () => setState(() => _showTopItemsByAmount = true)),
                              const SizedBox(width: 6),
                              _pill('Qty', !_showTopItemsByAmount, () => setState(() => _showTopItemsByAmount = false)),
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
                    const SizedBox(height: 14),

                    // GST summary link
                    SoftCard(
                      onTap: () => context.push('/reports/gst-summary'),
                      child: Row(
                        children: [
                          const IconTile(icon: Icons.receipt_long, color: AppColors.blue, background: AppColors.blueBg),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.viewGstSummary,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.lightMuted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Low Stock List
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const IconTile(
                                icon: Icons.warning,
                                color: AppColors.warn,
                                background: AppColors.warnBg,
                                size: 34,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.lowStockList,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
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
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                              Text(
                                                'Reorder Level: ${formatMilliUnits(item.reorderLevel)}',
                                                style: const TextStyle(fontSize: 12, color: AppColors.lightMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge.warn('Stock: ${formatMilliUnits(item.currentStockMilli)}'),
                                      ],
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
                    const SizedBox(height: 14),

                    // Top 10 Receivables
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const IconTile(
                                icon: Icons.account_balance_wallet,
                                color: AppColors.blue,
                                background: AppColors.blueBg,
                                size: 34,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.receivablesTop10,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
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
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        MonoTile(initialsOf(p.partyName), color: tileColorFor(p.partyName), size: 36),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p.partyName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                              Text(
                                                p.phone,
                                                style: const TextStyle(fontSize: 12, color: AppColors.lightMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          formatRupees(p.balancePaise),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.lightDanger,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
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
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap, {IconData? icon}) {
    final fg = selected ? Colors.white : AppColors.lightText;
    return Material(
      color: selected ? AppColors.ink : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.ink : AppColors.lightBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 15, color: fg), const SizedBox(width: 6)],
              Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, Color bg) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, color: color, background: bg, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.lightMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
        ],
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

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$idx',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accent),
                ),
              ),
              Expanded(
                child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(valStr, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
