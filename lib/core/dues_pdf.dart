import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'dues.dart';
import 'invoice_pdf.dart' show buildUpiQrUri, loadFontBytes;
import 'invoice_style.dart';
import 'money.dart';

/// Payment reminder / statement of dues for one customer: every unpaid bill
/// with its items, what was paid, what is still due, the grand total and a UPI
/// QR for exactly that amount. The shop's bill design (logo, colour, margins,
/// stationary) is applied.
Future<Uint8List> generateDuesPdf({
  required String partyName,
  String? partyPhone,
  required String shopName,
  String? shopGstin,
  String? shopAddress,
  String? upiId,
  required DuesResult dues,
  InvoiceStyle? style,
  InvoiceAssets? assets,
  Uint8List? interRegularBytes,
  Uint8List? interBoldBytes,
  Uint8List? devanagariBytes,
  Uint8List? gujaratiBytes,
  DateTime? now,
}) async {
  final reg = interRegularBytes ?? await loadFontBytes('assets/fonts/Inter-Regular.ttf');
  final bold = interBoldBytes ?? await loadFontBytes('assets/fonts/Inter-Bold.ttf');
  final dev = devanagariBytes ?? await loadFontBytes('assets/fonts/NotoSansDevanagari-Regular.ttf');
  final guj = gujaratiBytes ?? await loadFontBytes('assets/fonts/NotoSansGujarati-Regular.ttf');

  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(reg.buffer.asByteData()),
    bold: pw.Font.ttf(bold.buffer.asByteData()),
    fontFallback: [pw.Font.ttf(dev.buffer.asByteData()), pw.Font.ttf(guj.buffer.asByteData())],
  );

  final st = style ?? InvoiceStyle.classicDefault;
  // A reminder is always a normal sheet: thermal rolls fall back to A4.
  var format = st.pageFormat();
  if (!format.height.isFinite || format.width / PdfPageFormat.mm <= 100) format = PdfPageFormat.a4;
  final m = st.margins(format);
  final accent = PdfColor.fromInt(0xFF000000 | st.accentColor);
  final scale = st.fontScale;
  pw.TextStyle ts(double size, {bool b = false, PdfColor? color}) => pw.TextStyle(
        fontSize: size * scale,
        fontWeight: b ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      );

  pw.MemoryImage? tryImage(Uint8List? bytes) {
    if (bytes == null) return null;
    try {
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  final logo = st.showLogo ? tryImage(assets?.logo) : null;
  final bg = tryImage(assets?.background);
  final dateFmt = DateFormat('dd MMM yyyy');
  final today = now ?? DateTime.now();

  final qrUri = st.showQr
      ? buildUpiQrUri(
          upiId: upiId,
          sellerName: shopName,
          number: 'Dues',
          balancePaise: dues.totalDuePaise,
          docType: 'invoice',
        )
      : null;

  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: format,
        margin: pw.EdgeInsets.fromLTRB(m.left, m.top, m.right, m.bottom),
        theme: theme,
        buildBackground: bg == null
            ? null
            : (pw.Context c) => pw.FullPage(
                  ignoreMargins: true,
                  child: pw.Image(bg, fit: st.backgroundFit == BackgroundFit.full ? pw.BoxFit.fill : pw.BoxFit.contain),
                ),
      ),
      build: (pw.Context context) {
        return [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logo != null) ...[pw.Image(logo, height: 44 * scale, fit: pw.BoxFit.contain), pw.SizedBox(width: 10)],
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
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('PAYMENT REMINDER', style: ts(15, b: true, color: accent)),
                  pw.SizedBox(height: 3),
                  pw.Text('Date: ${dateFmt.format(today)}', style: ts(9.5)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: accent),
          pw.SizedBox(height: 6),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Customer', style: ts(9, b: true)),
                pw.Text(partyName, style: ts(12, b: true)),
                if (partyPhone != null && partyPhone.isNotEmpty) pw.Text('Phone: $partyPhone', style: ts(9.5)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          for (final inv in dues.openInvoices) ...[
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: _tint(accent, 0.88),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Bill ${inv.number}  |  ${dateFmt.format(inv.issuedAt)}', style: ts(10, b: true)),
                  pw.Text(
                    inv.isPartlyPaid
                        ? 'Total ${formatRupees(inv.totalPaise)}  |  Paid ${formatRupees(inv.paidPaise)}  |  Due ${formatRupees(inv.duePaise)}'
                        : 'Due ${formatRupees(inv.duePaise)}',
                    style: ts(9.5, b: true),
                  ),
                ],
              ),
            ),
            if (inv.lines.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Rate', 'Amount'],
                headerStyle: ts(8.5, b: true),
                cellStyle: ts(8.5),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headerAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.4),
                  3: const pw.FlexColumnWidth(1.6),
                },
                data: [
                  for (final l in inv.lines)
                    [l.name, formatMilliUnits(l.qtyMilli), formatRupees(l.ratePaise), formatRupees(l.lineTotalPaise)],
                ],
              ),
            pw.SizedBox(height: 10),
          ],
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (qrUri != null) ...[
                      pw.Text('Scan to pay ${formatRupees(dues.totalDuePaise)}', style: ts(9, b: true)),
                      pw.SizedBox(height: 4),
                      pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: qrUri, width: 80, height: 80),
                      pw.SizedBox(height: 2),
                      pw.Text('UPI ID: $upiId', style: ts(8.5)),
                    ],
                  ],
                ),
              ),
              pw.Container(
                width: 190,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Column(
                  children: [
                    _row('Billed (open bills)', formatRupees(dues.totalBilledPaise), ts(9.5)),
                    _row('Paid so far', formatRupees(dues.totalPaidPaise), ts(9.5)),
                    pw.Divider(),
                    _row('TOTAL DUE', formatRupees(dues.totalDuePaise), ts(12, b: true, color: accent)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text('Please pay at your earliest. Thank you!', style: ts(9)),
        ];
      },
    ),
  );
  return pdf.save();
}

pw.Widget _row(String label, String value, pw.TextStyle style) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );

PdfColor _tint(PdfColor c, double amount) {
  double mix(double v) => v + (1 - v) * amount;
  return PdfColor(mix(c.red), mix(c.green), mix(c.blue));
}
