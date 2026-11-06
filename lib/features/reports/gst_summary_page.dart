import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'csv_export_service.dart';
import 'reports_providers.dart';
import 'reports_repository.dart';

class GstSummaryPage extends ConsumerWidget {
  const GstSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dateRange = ref.watch(reportsDateRangeProvider);
    final summaryAsync = ref.watch(gstSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gstSummary),
        actions: [
          summaryAsync.maybeWhen(
            data: (summary) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.description_outlined),
                    tooltip: 'GSTR-1 export (CA ke liye)',
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () async {
                      final db = ref.read(databaseProvider);
                      final businessId = ref.read(currentBusinessIdProvider);
                      await CsvExportService(db, businessId).exportGstr1Csv(dateRange.start, dateRange.end);
                    },
                  ),
                  IconButton(
                icon: const Icon(Icons.share),
                tooltip: l10n.exportCsv,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () async {
                  final db = ref.read(databaseProvider);
                  final businessId = ref.read(currentBusinessIdProvider);
                  final exporter = CsvExportService(db, businessId);
                  await exporter.exportGstSummaryCsv(summary);
                },
              ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: staggered([
              // Date Range Indicator
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${dateRange.start.toIso8601String().substring(0, 10)} to ${dateRange.end.toIso8601String().substring(0, 10)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // On-screen Totals Check Banner
              if (!summary.totalsMatch) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.onError,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.totalsMismatchBanner,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.totalsMatchCheck,
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // B2B Section
              _buildSectionCard(
                context,
                title: l10n.b2bSection,
                rows: summary.b2bRows,
                totalRow: summary.b2bTotal,
                l10n: l10n,
              ),
              const SizedBox(height: 16),

              // B2C Section
              _buildSectionCard(
                context,
                title: l10n.b2cSection,
                rows: summary.b2cRows,
                totalRow: summary.b2cTotal,
                l10n: l10n,
              ),
              const SizedBox(height: 16),

              // Grand Total Section
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const Divider(),
                      _buildSummaryDataRow('Taxable Value', summary.grandTotal.taxablePaise, context),
                      _buildSummaryDataRow('CGST', summary.grandTotal.cgstPaise, context),
                      _buildSummaryDataRow('SGST', summary.grandTotal.sgstPaise, context),
                      _buildSummaryDataRow('IGST', summary.grandTotal.igstPaise, context),
                      _buildSummaryDataRow('Total Tax', summary.grandTotal.totalTaxPaise, context),
                      const Divider(),
                      _buildSummaryDataRow(
                        'Total Amount',
                        summary.grandTotal.totalAmountPaise,
                        context,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryDataRow(String label, int amountPaise, BuildContext context, {bool isBold = false}) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatRupees(amountPaise), style: style),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<GstRateSummaryRow> rows,
    required GstRateSummaryRow totalRow,
    required AppLocalizations l10n,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  l10n.noDataAvailable,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 40,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
                  columns: [
                    DataColumn(label: Text(l10n.gstRateHeader)),
                    DataColumn(label: Text(l10n.taxableHeader)),
                    DataColumn(label: Text(l10n.cgst)),
                    DataColumn(label: Text(l10n.sgst)),
                    DataColumn(label: Text(l10n.igst)),
                    DataColumn(label: Text(l10n.totalTaxHeader)),
                    DataColumn(label: Text(l10n.grandTotal)),
                  ],
                  rows: [
                    ...rows.map((r) => DataRow(cells: [
                          DataCell(Text('${formatGstRateBp(r.gstRateBp)}%')),
                          DataCell(Text(formatRupees(r.taxablePaise))),
                          DataCell(Text(formatRupees(r.cgstPaise))),
                          DataCell(Text(formatRupees(r.sgstPaise))),
                          DataCell(Text(formatRupees(r.igstPaise))),
                          DataCell(Text(formatRupees(r.totalTaxPaise))),
                          DataCell(Text(formatRupees(r.totalAmountPaise))),
                        ])),
                    // Section Total Row
                    DataRow(
                      color: WidgetStateProperty.all(Colors.grey.shade100),
                      cells: [
                        const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(formatRupees(totalRow.taxablePaise), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(formatRupees(totalRow.cgstPaise), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(formatRupees(totalRow.sgstPaise), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(formatRupees(totalRow.igstPaise), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(formatRupees(totalRow.totalTaxPaise), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(formatRupees(totalRow.totalAmountPaise), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
