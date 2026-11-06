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

  /// GSTR-1 style workbook-in-one-CSV for the CA: B2B, B2C small, credit notes
  /// and HSN summary. Cancelled invoices stay in B2B/B2CS and are offset by
  /// their credit note in the credit-note sections, exactly as they were filed.
  Future<void> exportGstr1Csv(DateTime startDate, DateTime endDate) async {
    final business = await (db.select(db.businesses)..where((t) => t.id.equals(businessId))).getSingleOrNull();
    final ownState = business?.stateCode ?? '';

    final docs = await (db.select(db.documents)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.issuedAt.isBiggerOrEqualValue(startDate) &
              t.issuedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.issuedAt)]))
        .get();
    final parties = {
      for (final p in await (db.select(db.parties)..where((t) => t.businessId.equals(businessId))).get()) p.id: p,
    };
    final lines = await (db.select(db.documentLines)
          ..where((t) => t.businessId.equals(businessId) & t.documentId.isIn(docs.map((d) => d.id).toList())))
        .get();
    final linesByDoc = <String, List<DocumentLine>>{};
    for (final l in lines) {
      linesByDoc.putIfAbsent(l.documentId, () => []).add(l);
    }

    String money(int paise) => formatPaiseToRupeesInput(paise);
    String rate(int bp) => (bp / 100).toStringAsFixed(bp % 100 == 0 ? 0 : 2);
    String date(DateTime d) => d.toIso8601String().substring(0, 10);

    // per doc, per rate
    Map<int, List<int>> byRate(Document d) {
      final m = <int, List<int>>{}; // bp -> [taxable, cgst, sgst, igst]
      for (final l in linesByDoc[d.id] ?? const <DocumentLine>[]) {
        final a = m.putIfAbsent(l.gstRateBp, () => [0, 0, 0, 0]);
        a[0] += l.taxablePaise;
        a[1] += l.cgstPaise;
        a[2] += l.sgstPaise;
        a[3] += l.igstPaise;
      }
      return m;
    }

    final b = StringBuffer();

    // ---- B2B ----
    b.writeln('B2B - Invoices to registered buyers');
    b.writeln('GSTIN,Receiver,Invoice No,Invoice Date,Invoice Value,Place of Supply,Rate %,Taxable Value,IGST,CGST,SGST');
    for (final d in docs.where((d) => d.docType == 'invoice')) {
      final party = d.partyId == null ? null : parties[d.partyId];
      final gstin = (party?.gstin ?? '').trim();
      if (gstin.isEmpty) continue;
      for (final e in byRate(d).entries) {
        b.writeln([
          gstin,
          _escapeCsv(party?.name ?? ''),
          d.number,
          date(d.issuedAt),
          money(d.totalPaise),
          party?.stateCode ?? ownState,
          rate(e.key),
          money(e.value[0]),
          money(e.value[3]),
          money(e.value[1]),
          money(e.value[2]),
        ].join(','));
      }
    }

    // ---- B2CS (aggregated by place of supply + rate) ----
    b.writeln();
    b.writeln('B2CS - Sales to unregistered buyers (aggregated)');
    b.writeln('Place of Supply,Rate %,Taxable Value,IGST,CGST,SGST');
    final b2cs = <String, List<int>>{};
    for (final d in docs.where((d) => d.docType == 'invoice')) {
      final party = d.partyId == null ? null : parties[d.partyId];
      if ((party?.gstin ?? '').trim().isNotEmpty) continue;
      final pos = party?.stateCode ?? ownState;
      for (final e in byRate(d).entries) {
        final a = b2cs.putIfAbsent('$pos|${e.key}', () => [0, 0, 0, 0]);
        for (var i = 0; i < 4; i++) {
          a[i] += e.value[i];
        }
      }
    }
    for (final k in (b2cs.keys.toList()..sort())) {
      final parts = k.split('|');
      final a = b2cs[k]!;
      b.writeln([parts[0], rate(int.parse(parts[1])), money(a[0]), money(a[3]), money(a[1]), money(a[2])].join(','));
    }

    // ---- Credit notes ----
    b.writeln();
    b.writeln('CDNR / CDNUR - Credit notes');
    b.writeln('Type,GSTIN,Receiver,Note No,Note Date,Original Invoice,Note Value,Place of Supply,Rate %,Taxable Value,IGST,CGST,SGST');
    final byId = {for (final d in docs) d.id: d};
    for (final d in docs.where((d) => d.docType == 'credit_note')) {
      final party = d.partyId == null ? null : parties[d.partyId];
      final gstin = (party?.gstin ?? '').trim();
      final orig = d.refDocumentId == null ? null : byId[d.refDocumentId];
      for (final e in byRate(d).entries) {
        b.writeln([
          gstin.isEmpty ? 'CDNUR' : 'CDNR',
          gstin,
          _escapeCsv(party?.name ?? ''),
          d.number,
          date(d.issuedAt),
          orig?.number ?? '',
          money(d.totalPaise),
          party?.stateCode ?? ownState,
          rate(e.key),
          money(e.value[0]),
          money(e.value[3]),
          money(e.value[1]),
          money(e.value[2]),
        ].join(','));
      }
    }

    // ---- HSN summary (net of credit notes) ----
    b.writeln();
    b.writeln('HSN Summary (net of credit notes)');
    b.writeln('HSN,Rate %,Qty,Taxable Value,IGST,CGST,SGST');
    final hsn = <String, List<int>>{}; // [qtyMilli, taxable, igst, cgst, sgst]
    for (final d in docs) {
      final mult = d.docType == 'credit_note' ? -1 : 1;
      for (final l in linesByDoc[d.id] ?? const <DocumentLine>[]) {
        final a = hsn.putIfAbsent('${l.hsn}|${l.gstRateBp}', () => [0, 0, 0, 0, 0]);
        a[0] += mult * l.qtyMilli;
        a[1] += mult * l.taxablePaise;
        a[2] += mult * l.igstPaise;
        a[3] += mult * l.cgstPaise;
        a[4] += mult * l.sgstPaise;
      }
    }
    for (final k in (hsn.keys.toList()..sort())) {
      final parts = k.split('|');
      final a = hsn[k]!;
      b.writeln([
        parts[0],
        rate(int.parse(parts[1])),
        formatMilliUnits(a[0]),
        money(a[1]),
        money(a[2]),
        money(a[3]),
        money(a[4]),
      ].join(','));
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/gstr1_${date(startDate)}_${date(endDate)}.csv');
    await file.writeAsBytes(_encodeWithBom(b.toString()));
    await Share.shareXFiles([XFile(file.path)], text: 'GSTR-1 ${date(startDate)} to ${date(endDate)}');
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
