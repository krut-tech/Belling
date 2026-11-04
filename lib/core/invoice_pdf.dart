import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import 'money.dart';

/// Helper to load font bytes with fallback for test environment
Future<Uint8List> loadFontBytes(String path) async {
  try {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  } catch (_) {
    final file = File(path);
    if (file.existsSync()) {
      return file.readAsBytesSync();
    }
    rethrow;
  }
}

/// Converts paise to Indian currency words (Lakh, Crore, etc.)
String amountInWords(int totalPaise) {
  if (totalPaise <= 0) return 'Zero Rupees Only';

  final rupees = totalPaise ~/ 100;
  final paise = totalPaise % 100;

  final parts = <String>[];

  if (rupees > 0) {
    final words = _numToWords(rupees);
    parts.add('$words ${rupees == 1 ? "Rupee" : "Rupees"}');
  }

  if (paise > 0) {
    final words = _numToWords(paise);
    parts.add('$words ${paise == 1 ? "Paisa" : "Paise"}');
  }

  return '${parts.join(" and ")} Only';
}

const _units = [
  '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
  'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
  'Seventeen', 'Eighteen', 'Nineteen'
];

const _tens = [
  '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
];

String _numToWords(int n) {
  if (n == 0) return '';
  if (n < 20) return _units[n];
  if (n < 100) {
    final ten = n ~/ 10;
    final rem = n % 10;
    return rem == 0 ? _tens[ten] : '${_tens[ten]} ${_units[rem]}';
  }
  if (n < 1000) {
    final hundred = n ~/ 100;
    final rem = n % 100;
    return rem == 0
        ? '${_units[hundred]} Hundred'
        : '${_units[hundred]} Hundred ${_numToWords(rem)}';
  }
  if (n < 100000) { // < 1 Lakh
    final thousand = n ~/ 1000;
    final rem = n % 1000;
    return rem == 0
        ? '${_numToWords(thousand)} Thousand'
        : '${_numToWords(thousand)} Thousand ${_numToWords(rem)}';
  }
  if (n < 10000000) { // < 1 Crore
    final lakh = n ~/ 100000;
    final rem = n % 100000;
    return rem == 0
        ? '${_numToWords(lakh)} Lakh'
        : '${_numToWords(lakh)} Lakh ${_numToWords(rem)}';
  }
  // >= 1 Crore
  final crore = n ~/ 10000000;
  final rem = n % 10000000;
  return rem == 0
      ? '${_numToWords(crore)} Crore'
      : '${_numToWords(crore)} Crore ${_numToWords(rem)}';
}

/// Formats paise integer to standard UPI amount string (e.g. 105 paise -> "1.05").
/// Builds string from integer paise only without double math.
String formatPaiseForUpi(int p) {
  return '${p ~/ 100}.${(p % 100).toString().padLeft(2, '0')}';
}

/// Validates UPI ID format (name@handle). Returns error string if invalid, null if valid/empty.
String? validateUpiId(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final trimmed = value.trim();
  final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+$');
  if (!upiRegex.hasMatch(trimmed)) {
    return 'Invalid UPI ID format (name@handle)';
  }
  return null;
}

/// Builds UPI QR Code URI data string if UPI payment is applicable.
/// Returns null if docType is 'credit_note', balance <= 0, or upiId is empty/null.
String? buildUpiQrUri({
  required String? upiId,
  required String sellerName,
  required String number,
  required int balancePaise,
  required String docType,
}) {
  if (docType == 'credit_note') return null;
  if (balancePaise <= 0) return null;
  if (upiId == null || upiId.trim().isEmpty) return null;
  return 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(sellerName)}&tn=${Uri.encodeComponent(number)}&am=${formatPaiseForUpi(balancePaise)}&cu=INR';
}

/// Generates an A4 PDF Tax Invoice using ONLY snapshot_json and document lines.
Future<Uint8List> generateInvoicePdf({
  required String snapshotJson,
  required List<DocumentLine> lines,
  String? docNumber,
  String? docType,
  String? status,
  DateTime? issuedAt,
  Uint8List? interRegularBytes,
  Uint8List? interBoldBytes,
  Uint8List? devanagariBytes,
  Uint8List? gujaratiBytes,
}) async {
  final regBytes = interRegularBytes ?? await loadFontBytes('assets/fonts/Inter-Regular.ttf');
  final boldBytes = interBoldBytes ?? await loadFontBytes('assets/fonts/Inter-Bold.ttf');
  final devBytes = devanagariBytes ?? await loadFontBytes('assets/fonts/NotoSansDevanagari-Regular.ttf');
  final gujBytes = gujaratiBytes ?? await loadFontBytes('assets/fonts/NotoSansGujarati-Regular.ttf');

  final fontRegular = pw.Font.ttf(regBytes.buffer.asByteData());
  final fontBold = pw.Font.ttf(boldBytes.buffer.asByteData());
  final fontDevanagari = pw.Font.ttf(devBytes.buffer.asByteData());
  final fontGujarati = pw.Font.ttf(gujBytes.buffer.asByteData());

  final theme = pw.ThemeData.withFont(
    base: fontRegular,
    bold: fontBold,
    fontFallback: [fontDevanagari, fontGujarati],
  );

  final snapshotMap = jsonDecode(snapshotJson) as Map<String, dynamic>;
  final seller = snapshotMap['seller'] as Map<String, dynamic>? ?? {};
  final buyer = snapshotMap['buyer'] as Map<String, dynamic>?;
  final taxBreakup = snapshotMap['tax_breakup'] as Map<String, dynamic>? ?? {};

  final sellerName = seller['name'] as String? ?? 'Business';
  final sellerGstin = seller['gstin'] as String?;
  final sellerAddress = seller['address'] as String? ?? '';
  final sellerStateCode = seller['state_code'] as String? ?? '';
  final upiId = seller['upi_id'] as String?;
  final invoiceTerms = seller['invoice_terms'] as String?;

  final buyerName = buyer?['name'] as String? ?? 'Walk-in Customer';
  final buyerPhone = buyer?['phone'] as String?;
  final buyerGstin = buyer?['gstin'] as String?;
  final buyerStateCode = buyer?['state_code'] as String?;

  final taxablePaise = (taxBreakup['taxable_paise'] as num?)?.toInt() ?? 0;
  final cgstPaise = (taxBreakup['cgst_paise'] as num?)?.toInt() ?? 0;
  final sgstPaise = (taxBreakup['sgst_paise'] as num?)?.toInt() ?? 0;
  final igstPaise = (taxBreakup['igst_paise'] as num?)?.toInt() ?? 0;
  final roundOffPaise = (taxBreakup['round_off_paise'] as num?)?.toInt() ?? 0;
  final totalPaise = (taxBreakup['total_paise'] as num?)?.toInt() ?? 0;

  final paidPaise = (snapshotMap['paid_paise'] as num?)?.toInt() ?? 0;
  final balancePaise = (snapshotMap['balance_paise'] as num?)?.toInt() ?? (totalPaise - paidPaise);

  final number = docNumber ?? (snapshotMap['number'] as String? ?? 'INVOICE');
  final type = docType ?? (snapshotMap['doc_type'] as String? ?? 'invoice');
  final docStatus = status ?? (snapshotMap['status'] as String? ?? 'issued');

  final upiQrUri = buildUpiQrUri(
    upiId: upiId,
    sellerName: sellerName,
    number: number,
    balancePaise: balancePaise,
    docType: type,
  );

  final dateStr = issuedAt != null
      ? '${issuedAt.day.toString().padLeft(2, '0')}/${issuedAt.month.toString().padLeft(2, '0')}/${issuedAt.year}'
      : (snapshotMap['issued_at'] != null
          ? snapshotMap['issued_at'].toString().substring(0, 10)
          : '');

  String documentTitle;
  if (type == 'credit_note') {
    documentTitle = 'CREDIT NOTE';
  } else if (sellerGstin != null && sellerGstin.trim().isNotEmpty) {
    documentTitle = 'TAX INVOICE';
  } else {
    documentTitle = 'BILL OF SUPPLY';
  }

  final pdf = pw.Document(theme: theme);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return [
          // Cancelled Header Banner
          if (docStatus == 'cancelled')
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(6),
              margin: const pw.EdgeInsets.only(bottom: 12),
              color: PdfColors.red100,
              child: pw.Center(
                child: pw.Text(
                  'CANCELLED',
                  style: const pw.TextStyle(
                    color: PdfColors.red900,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          // Header Row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    sellerName,
                    style: const pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (sellerAddress.isNotEmpty)
                    pw.Text(sellerAddress, style: const pw.TextStyle(fontSize: 10)),
                  if (sellerGstin != null && sellerGstin.isNotEmpty)
                    pw.Text('GSTIN: $sellerGstin', style: const pw.TextStyle(fontSize: 10)),
                  if (sellerStateCode.isNotEmpty)
                    pw.Text('State Code: $sellerStateCode', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    documentTitle,
                    style: const pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Number: $number', style: const pw.TextStyle(fontSize: 10)),
                  if (dateStr.isNotEmpty)
                    pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 8),

          // Bill To Section
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(buyerName, style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                if (buyerPhone != null && buyerPhone.isNotEmpty)
                  pw.Text('Phone: $buyerPhone', style: const pw.TextStyle(fontSize: 9)),
                if (buyerGstin != null && buyerGstin.isNotEmpty)
                  pw.Text('GSTIN: $buyerGstin', style: const pw.TextStyle(fontSize: 9)),
                if (buyerStateCode != null && buyerStateCode.isNotEmpty)
                  pw.Text('State Code: $buyerStateCode', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          // Items Table
          pw.TableHelper.fromTextArray(
            headers: const ['Item', 'HSN', 'Qty', 'Rate', 'Disc', 'Taxable', 'GST %', 'Amount'],
            headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            columnWidths: const {
              0: pw.FlexColumnWidth(3), // Item
              1: pw.FlexColumnWidth(1.2), // HSN
              2: pw.FlexColumnWidth(1), // Qty
              3: pw.FlexColumnWidth(1.3), // Rate
              4: pw.FlexColumnWidth(1), // Disc
              5: pw.FlexColumnWidth(1.4), // Taxable
              6: pw.FlexColumnWidth(1.1), // GST %
              7: pw.FlexColumnWidth(1.5), // Amount
            },
            data: lines.map((l) {
              final qtyStr = formatMilliUnits(l.qtyMilli);
              final rateStr = formatRupees(l.ratePaise);
              final discStr = formatRupees(l.discountPaise);
              final taxableStr = formatRupees(l.taxablePaise);
              final gstRateStr = '${formatGstRateBp(l.gstRateBp)}%';
              final amountStr = formatRupees(l.lineTotalPaise);

              return [
                l.name,
                l.hsn,
                qtyStr,
                rateStr,
                discStr,
                taxableStr,
                gstRateStr,
                amountStr,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 12),

          // Tax Summary & Totals Row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Tax Summary Table
              pw.Expanded(
                flex: 5,
                child: _buildTaxSummaryTable(lines, igstPaise > 0),
              ),
              pw.SizedBox(width: 16),
              // Totals Box
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    children: [
                      _totalRow('Taxable Amount', formatRupees(taxablePaise)),
                      if (cgstPaise > 0) _totalRow('CGST', formatRupees(cgstPaise)),
                      if (sgstPaise > 0) _totalRow('SGST', formatRupees(sgstPaise)),
                      if (igstPaise > 0) _totalRow('IGST', formatRupees(igstPaise)),
                      if (roundOffPaise != 0) _totalRow('Round-off', formatRupees(roundOffPaise)),
                      pw.Divider(),
                      _totalRow('Grand Total', formatRupees(totalPaise), isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 12),

          // Amount in Words
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            color: PdfColors.grey100,
            child: pw.Text(
              'Amount in Words: ${amountInWords(totalPaise)}',
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),

          pw.SizedBox(height: 16),

          // Bottom Section (QR Code / Terms & Signature Box)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (upiQrUri != null) ...[
                    pw.Text('Pay via UPI:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.SizedBox(height: 4),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: upiQrUri,
                      width: 55,
                      height: 55,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('UPI ID: $upiId', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 8),
                  ],
                  if (invoiceTerms != null && invoiceTerms.isNotEmpty) ...[
                    pw.Text('Terms & Conditions:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.SizedBox(height: 2),
                    pw.Text(invoiceTerms, style: const pw.TextStyle(fontSize: 8)),
                  ],
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('For $sellerName', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.SizedBox(height: 30),
                  pw.Text('Authorised Signatory', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildTaxSummaryTable(List<DocumentLine> lines, bool isInterState) {
  final rateGroups = <int, List<DocumentLine>>{};
  for (final l in lines) {
    rateGroups.putIfAbsent(l.gstRateBp, () => []).add(l);
  }

  final rows = <List<String>>[];
  for (final entry in rateGroups.entries) {
    final rateBp = entry.key;
    final groupLines = entry.value;
    final ratePct = formatGstRateBp(rateBp);

    final taxAmount = groupLines.fold<int>(0, (sum, l) => sum + l.taxablePaise);
    final cgstAmount = groupLines.fold<int>(0, (sum, l) => sum + l.cgstPaise);
    final sgstAmount = groupLines.fold<int>(0, (sum, l) => sum + l.sgstPaise);
    final igstAmount = groupLines.fold<int>(0, (sum, l) => sum + l.igstPaise);

    if (isInterState) {
      rows.add([
        '$ratePct% IGST',
        formatRupees(taxAmount),
        formatRupees(igstAmount),
      ]);
    } else {
      final totalTax = cgstAmount + sgstAmount;
      rows.add([
        '$ratePct% GST',
        formatRupees(taxAmount),
        formatRupees(cgstAmount),
        formatRupees(sgstAmount),
        formatRupees(totalTax),
      ]);
    }
  }

  final headers = isInterState
      ? const ['Rate', 'Taxable', 'IGST']
      : const ['Rate', 'Taxable', 'CGST', 'SGST', 'Total Tax'];

  return pw.TableHelper.fromTextArray(
    headers: headers,
    headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
    cellStyle: const pw.TextStyle(fontSize: 8),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    data: rows,
  );
}

pw.Widget _totalRow(String label, String value, {bool isBold = false}) {
  final style = pw.TextStyle(
    fontSize: 9,
    fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(value, style: style),
      ],
    ),
  );
}

/// Helper function to share invoice PDF via system share sheet
Future<void> shareInvoicePdf(AppDatabase db, Document doc, BuildContext context) async {
  final lines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc.id))).get();
  final pdfBytes = await generateInvoicePdf(
    snapshotJson: doc.snapshotJson,
    lines: lines,
    docNumber: doc.number,
    docType: doc.docType,
    status: doc.status,
    issuedAt: doc.issuedAt,
  );

  final tempDir = await getTemporaryDirectory();
  final fileName = '${doc.number}.pdf';
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(pdfBytes);

  final snapshotMap = jsonDecode(doc.snapshotJson) as Map<String, dynamic>;
  final sellerMap = snapshotMap['seller'] as Map<String, dynamic>?;
  final sellerName = sellerMap?['name'] as String? ?? 'Business';

  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Invoice ${doc.number} from $sellerName',
  );
}

/// Helper function to print invoice PDF using printing package
Future<void> printInvoicePdf(AppDatabase db, Document doc) async {
  final lines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc.id))).get();
  final pdfBytes = await generateInvoicePdf(
    snapshotJson: doc.snapshotJson,
    lines: lines,
    docNumber: doc.number,
    docType: doc.docType,
    status: doc.status,
    issuedAt: doc.issuedAt,
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdfBytes,
    name: doc.number,
  );
}
