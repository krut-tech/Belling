import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/repositories/party_repository.dart';
import 'invoice_pdf.dart' show loadFontBytes;
import 'invoice_style.dart';
import 'money.dart';

/// Date-wise account statement for one party: every bill (debit), return and
/// payment (credit) with the running balance. [items] may be in any order.
Future<Uint8List> generateStatementPdf({
  required String partyName,
  String? partyPhone,
  String? partyGstin,
  required String shopName,
  String? shopGstin,
  String? shopAddress,
  required List<LedgerItem> items,
  InvoiceStyle? style,
  InvoiceAssets? assets,
  DateTime? now,
}) async {
  final reg = await loadFontBytes('assets/fonts/Inter-Regular.ttf');
  final bold = await loadFontBytes('assets/fonts/Inter-Bold.ttf');
  final dev = await loadFontBytes('assets/fonts/NotoSansDevanagari-Regular.ttf');
  final guj = await loadFontBytes('assets/fonts/NotoSansGujarati-Regular.ttf');
  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(reg.buffer.asByteData()),
    bold: pw.Font.ttf(bold.buffer.asByteData()),
    fontFallback: [pw.Font.ttf(dev.buffer.asByteData()), pw.Font.ttf(guj.buffer.asByteData())],
  );

  final st = style ?? InvoiceStyle.classicDefault;
  final accent = PdfColor.fromInt(0xFF000000 | st.accentColor);
  const format = PdfPageFormat.a4;
  final dateFmt = DateFormat('dd MMM yyyy');
  final today = now ?? DateTime.now();

  pw.TextStyle ts(double size, {bool b = false, PdfColor? color}) =>
      pw.TextStyle(fontSize: size, fontWeight: b ? pw.FontWeight.bold : pw.FontWeight.normal, color: color);

  final sorted = [...items]..sort((a, b) => a.date.compareTo(b.date));
  var totalDebit = 0;
  var totalCredit = 0;
  for (final i in sorted) {
    if (i.type == LedgerItemType.invoice) {
      totalDebit += i.amountPaise;
    } else {
      totalCredit += i.amountPaise;
    }
  }
  final closing = totalDebit - totalCredit;

  pw.Widget cell(String t, {bool right = false, bool b = false, PdfColor? color}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(t, textAlign: right ? pw.TextAlign.right : pw.TextAlign.left, style: ts(9, b: b, color: color)),
      );

  final rows = <pw.TableRow>[
    pw.TableRow(
      decoration: pw.BoxDecoration(color: accent),
      children: [
        for (final h in ['Date', 'Particulars', 'Debit', 'Credit', 'Balance'])
          cell(h, right: h != 'Date' && h != 'Particulars', b: true, color: PdfColors.white),
      ],
    ),
    for (final i in sorted)
      pw.TableRow(
        children: [
          cell(dateFmt.format(i.date)),
          cell(i.title),
          cell(i.type == LedgerItemType.invoice ? formatRupees(i.amountPaise) : '', right: true),
          cell(i.type == LedgerItemType.invoice ? '' : formatRupees(i.amountPaise), right: true),
          cell(formatRupees(i.runningBalancePaise), right: true),
        ],
      ),
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        cell(''),
        cell('Total', b: true),
        cell(formatRupees(totalDebit), right: true, b: true),
        cell(formatRupees(totalCredit), right: true, b: true),
        cell(formatRupees(closing), right: true, b: true),
      ],
    ),
  ];

  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(pageFormat: format, margin: const pw.EdgeInsets.all(32), theme: theme),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(shopName, style: ts(17, b: true, color: accent)),
                  if (shopAddress != null && shopAddress.isNotEmpty) pw.Text(shopAddress, style: ts(9.5)),
                  if (shopGstin != null && shopGstin.isNotEmpty) pw.Text('GSTIN: $shopGstin', style: ts(9.5)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('ACCOUNT STATEMENT', style: ts(15, b: true, color: accent)),
                pw.Text('Date: ${dateFmt.format(today)}', style: ts(9.5)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: accent),
        pw.SizedBox(height: 6),
        pw.Text('Customer', style: ts(9, b: true)),
        pw.Text(partyName, style: ts(13, b: true)),
        if (partyPhone != null && partyPhone.isNotEmpty) pw.Text('Phone: $partyPhone', style: ts(9.5)),
        if (partyGstin != null && partyGstin.isNotEmpty) pw.Text('GSTIN: $partyGstin', style: ts(9.5)),
        pw.SizedBox(height: 12),
        if (sorted.isEmpty)
          pw.Text('No transactions yet.', style: ts(10))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FixedColumnWidth(66),
              1: pw.FlexColumnWidth(),
              2: pw.FixedColumnWidth(70),
              3: pw.FixedColumnWidth(70),
              4: pw.FixedColumnWidth(76),
            },
            children: rows,
          ),
        pw.SizedBox(height: 14),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            closing > 0
                ? 'Balance due: ${formatRupees(closing)}'
                : (closing < 0 ? 'Advance with us: ${formatRupees(-closing)}' : 'All settled'),
            style: ts(13, b: true, color: accent),
          ),
        ),
      ],
    ),
  );
  return pdf.save();
}
