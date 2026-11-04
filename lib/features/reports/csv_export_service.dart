import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import 'reports_repository.dart';

class CsvExportService {
  final AppDatabase db;
  final String businessId;

  CsvExportService(this.db, this.businessId);

  List<int> _encodeWithBom(String csvContent) {
    return utf8.encode('\uFEFF$csvContent');
  }

  Future<void> exportSalesRegisterCsv(DateTime startDate, DateTime endDate) async {
    final docsWithParties = await (db.select(db.documents).join([
      leftOuterJoin(db.parties, db.parties.id.equalsExp(db.documents.partyId)),
    ])
          ..where(db.documents.businessId.equals(businessId) &
              db.documents.issuedAt.isBiggerOrEqualValue(startDate) &
              db.documents.issuedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([OrderingTerm.asc(db.documents.issuedAt)]))
        .get();

    final buffer = StringBuffer();
    buffer.writeln(
        'Date,Invoice No,Party Name,Party GSTIN,Taxable Value,CGST,SGST,IGST,Round Off,Total Amount,Doc Type,Status');

    for (final row in docsWithParties) {
      final doc = row.readTable(db.documents);
      final party = row.readTableOrNull(db.parties);

      final dateStr = doc.issuedAt.toIso8601String().substring(0, 10);
      final mult = doc.docType == 'credit_note' ? -1 : 1;

      final partyName = _escapeCsv(party?.name ?? 'Walk-in');
      final partyGstin = party?.gstin ?? '';
      final taxable = formatPaiseToRupeesInput(doc.taxablePaise * mult);
      final cgst = formatPaiseToRupeesInput(doc.cgstPaise * mult);
      final sgst = formatPaiseToRupeesInput(doc.sgstPaise * mult);
      final igst = formatPaiseToRupeesInput(doc.igstPaise * mult);
      final roundOff = formatPaiseToRupeesInput(doc.roundOffPaise * mult);
      final total = formatPaiseToRupeesInput(doc.totalPaise * mult);

      buffer.writeln(
          '$dateStr,${doc.number},$partyName,$partyGstin,$taxable,$cgst,$sgst,$igst,$roundOff,$total,${doc.docType},${doc.status}');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/sales_register_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsBytes(_encodeWithBom(buffer.toString()));

    await Share.shareXFiles([XFile(file.path)], text: 'Sales Register');
  }

  Future<void> exportGstSummaryCsv(GstSectionSummary summary) async {
    final buffer = StringBuffer();
    buffer.writeln('Section,GST Rate %,Taxable Value,CGST,SGST,IGST,Total Tax,Total Amount');

    void writeRow(String section, GstRateSummaryRow row) {
      final rateStr = row.gstRateBp >= 0 ? formatGstRateBp(row.gstRateBp) : 'Total';
      final t = formatPaiseToRupeesInput(row.taxablePaise);
      final c = formatPaiseToRupeesInput(row.cgstPaise);
      final s = formatPaiseToRupeesInput(row.sgstPaise);
      final i = formatPaiseToRupeesInput(row.igstPaise);
      final tax = formatPaiseToRupeesInput(row.totalTaxPaise);
      final amt = formatPaiseToRupeesInput(row.totalAmountPaise);

      buffer.writeln('$section,$rateStr,$t,$c,$s,$i,$tax,$amt');
    }

    for (final r in summary.b2bRows) {
      writeRow('B2B', r);
    }
    writeRow('B2B Total', summary.b2bTotal);

    for (final r in summary.b2cRows) {
      writeRow('B2C', r);
    }
    writeRow('B2C Total', summary.b2cTotal);

    writeRow('Grand Total', summary.grandTotal);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/gst_summary_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsBytes(_encodeWithBom(buffer.toString()));

    await Share.shareXFiles([XFile(file.path)], text: 'GST Summary');
  }

  Future<void> exportPartyBalancesCsv() async {
    final query = db.customSelect(
      '''
      SELECT 
        p.name, p.phone, p.gstin, p.state_code,
        COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = p.id AND d.doc_type = 'invoice'), 0) -
        COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = p.id AND d.doc_type = 'credit_note'), 0) -
        COALESCE((SELECT SUM(pay.amount_paise) FROM payments pay WHERE pay.party_id = p.id), 0) AS calculated_balance
      FROM parties p
      WHERE p.business_id = ?
      ORDER BY p.name ASC
      ''',
      variables: [Variable.withString(businessId)],
      readsFrom: {db.parties, db.documents, db.payments},
    );

    final rows = await query.get();
    final buffer = StringBuffer();
    buffer.writeln('Party Name,Phone,GSTIN,State Code,Balance');

    for (final r in rows) {
      final name = _escapeCsv(r.read<String>('name'));
      final phone = r.read<String>('phone');
      final gstin = r.read<String?>('gstin') ?? '';
      final stateCode = r.read<String>('state_code');
      final balance = formatPaiseToRupeesInput(r.read<int>('calculated_balance'));

      buffer.writeln('$name,$phone,$gstin,$stateCode,$balance');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/party_balances_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsBytes(_encodeWithBom(buffer.toString()));

    await Share.shareXFiles([XFile(file.path)], text: 'Party Balances');
  }

  String _escapeCsv(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      final escaped = val.replaceAll('"', '""');
      return '"$escaped"';
    }
    return val;
  }
}
