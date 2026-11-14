import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'csv_export_service.dart';
import 'gst_detail.dart';
import 'reports_providers.dart';
import 'reports_repository.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

/// 0 = B2B / B2C, 1 = HSN, 2 = Credit notes
final _gstTabProvider = StateProvider.autoDispose<int>((ref) => 0);

class GstSummaryPage extends ConsumerWidget {
  const GstSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dateRange = ref.watch(reportsDateRangeProvider);
    final summaryAsync = ref.watch(gstSummaryProvider);
    final tab = ref.watch(_gstTabProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: l10n.gstSummary,
              subtitle:
                  '${dateRange.start.toIso8601String().substring(0, 10)} to ${dateRange.end.toIso8601String().substring(0, 10)}',
              showBack: true,
              actions: [
                summaryAsync.maybeWhen(
                  data: (summary) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SoftIconButton(
                        icon: Icons.description_outlined,
                        tooltip: tr(context, 'GSTR-1 export (CA ke liye)'),
                        onTap: () async {
                          final db = ref.read(databaseProvider);
                          final businessId = ref.read(currentBusinessIdProvider);
                          await CsvExportService(db, businessId).exportGstr1Csv(dateRange.start, dateRange.end);
                        },
                      ),
                      const SizedBox(width: 10),
                      SoftIconButton(
                        icon: Icons.share,
                        tooltip: l10n.exportCsv,
                        onTap: () async {
                          final db = ref.read(databaseProvider);
                          final businessId = ref.read(currentBusinessIdProvider);
                          final exporter = CsvExportService(db, businessId);
                          await exporter.exportGstSummaryCsv(summary);
                        },
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            Expanded(
              child: summaryAsync.when(
                data: (summary) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: staggered([
                      HeroCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Tax',
                                style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(
                              formatRupees(summary.grandTotal.totalTaxPaise),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0x26FFFFFF)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _heroStat('CGST', summary.grandTotal.cgstPaise),
                                _heroStat('SGST', summary.grandTotal.sgstPaise),
                                _heroStat('IGST', summary.grandTotal.igstPaise),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // On-screen Totals Check Banner
                      if (!summary.totalsMatch) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.lightDanger,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.totalsMismatchBanner,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                            color: AppColors.goodBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.lightSuccess, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.totalsMatchCheck,
                                style: const TextStyle(
                                  color: AppColors.lightSuccess,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Wrap(
                        spacing: 8,
                        children: [
                          for (final e in const [(0, 'B2B / B2C'), (1, 'HSN'), (2, 'Credit notes')])
                            ChoiceChip(
                              label: Text(e.$2),
                              selected: tab == e.$1,
                              onSelected: (_) => ref.read(_gstTabProvider.notifier).state = e.$1,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (tab == 1) _hsnCard(ref) else if (tab == 2) _notesCard(ref) else ...[
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
                      SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
                      ],
                    ]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hsnCard(WidgetRef ref) {
    final detail = ref.watch(gstDetailProvider);
    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (d) => SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HSN summary (credit notes minus)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (d.hsn.isEmpty)
              const Text('Koi data nahi', style: TextStyle(color: AppColors.lightMuted))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 40,
                  headingTextStyle: const TextStyle(
                      color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w700),
                  columns: const [
                    DataColumn(label: Text('HSN')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Taxable')),
                    DataColumn(label: Text('Tax')),
                  ],
                  rows: [
                    for (final r in d.hsn)
                      DataRow(cells: [
                        DataCell(Text(r.hsn.isEmpty ? '-' : r.hsn)),
                        DataCell(StatusBadge('${formatGstRateBp(r.rateBp)}%',
                            color: AppColors.accent, background: AppColors.accentBg)),
                        DataCell(Text(formatMilliUnits(r.qtyMilli))),
                        DataCell(Text(formatRupees(r.taxable))),
                        DataCell(Text(formatRupees(r.tax))),
                      ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _notesCard(WidgetRef ref) {
    final detail = ref.watch(gstDetailProvider);
    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (d) => d.notes.isEmpty
          ? const SoftCard(
              child: Text('Is period me koi credit note nahi', style: TextStyle(color: AppColors.lightMuted)))
          : Column(
              children: [
                for (final n in d.notes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftCard(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          const IconTile(
                            icon: Icons.assignment_return_outlined,
                            color: AppColors.warn,
                            background: AppColors.warnBg,
                            size: 42,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.number, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text(
                                  '${n.party} • ${n.date.toIso8601String().substring(0, 10)}'
                                  '${n.original.isEmpty ? '' : ' • ${n.original}'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightMuted),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('− ${formatRupees(n.total)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text('GST ${formatRupees(n.tax)}',
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _heroStat(String label, int paise) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(formatRupees(paise),
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
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
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                l10n.noDataAvailable,
                style: const TextStyle(color: AppColors.lightMuted),
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
                headingTextStyle: const TextStyle(
                    color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w700),
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
                        DataCell(StatusBadge('${formatGstRateBp(r.gstRateBp)}%',
                            color: AppColors.accent, background: AppColors.accentBg)),
                        DataCell(Text(formatRupees(r.taxablePaise))),
                        DataCell(Text(formatRupees(r.cgstPaise))),
                        DataCell(Text(formatRupees(r.sgstPaise))),
                        DataCell(Text(formatRupees(r.igstPaise))),
                        DataCell(Text(formatRupees(r.totalTaxPaise))),
                        DataCell(Text(formatRupees(r.totalAmountPaise))),
                      ])),
                  // Section Total Row
                  DataRow(
                    color: WidgetStateProperty.all(AppColors.lightBackground),
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
    );
  }
}
