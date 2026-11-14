import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import 'reports_providers.dart';

class HsnRow {
  HsnRow(this.hsn, this.rateBp);
  final String hsn;
  final int rateBp;
  int qtyMilli = 0;
  int taxable = 0;
  int tax = 0;
}

class NoteRow {
  NoteRow(this.number, this.date, this.party, this.original, this.total, this.tax);
  final String number;
  final DateTime date;
  final String party;
  final String original;
  final int total;
  final int tax;
}

class GstDetail {
  GstDetail(this.hsn, this.notes);
  final List<HsnRow> hsn;
  final List<NoteRow> notes;
}

final gstDetailProvider = FutureProvider.autoDispose<GstDetail>((ref) async {
  ref.watch(reportsRefreshProvider);
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  final range = ref.watch(reportsDateRangeProvider);
  final docs = await (db.select(db.documents)
        ..where((t) =>
            t.businessId.equals(businessId) &
            t.issuedAt.isBiggerOrEqualValue(range.start) &
            t.issuedAt.isSmallerOrEqualValue(range.end)))
      .get();
  final ids = docs.map((d) => d.id).toList();
  final lines = await (db.select(db.documentLines)
        ..where((t) => t.businessId.equals(businessId) & t.documentId.isIn(ids)))
      .get();
  final parties = {
    for (final p in await (db.select(db.parties)..where((t) => t.businessId.equals(businessId))).get()) p.id: p,
  };
  final byDoc = <String, List<DocumentLine>>{};
  for (final l in lines) {
    byDoc.putIfAbsent(l.documentId, () => []).add(l);
  }
  final docById = {for (final d in docs) d.id: d};
  final hsn = <String, HsnRow>{};
  final notes = <NoteRow>[];
  for (final d in docs) {
    final mult = d.docType == 'credit_note' ? -1 : 1;
    var taxSum = 0;
    for (final l in byDoc[d.id] ?? const <DocumentLine>[]) {
      final row = hsn.putIfAbsent('${l.hsn}|${l.gstRateBp}', () => HsnRow(l.hsn, l.gstRateBp));
      row.qtyMilli += mult * l.qtyMilli;
      row.taxable += mult * l.taxablePaise;
      final t = l.cgstPaise + l.sgstPaise + l.igstPaise;
      row.tax += mult * t;
      taxSum += t;
    }
    if (d.docType == 'credit_note') {
      notes.add(NoteRow(
        d.number,
        d.issuedAt,
        d.partyId == null ? 'Walk-in' : (parties[d.partyId]?.name ?? ''),
        d.refDocumentId == null ? '' : (docById[d.refDocumentId]?.number ?? ''),
        d.totalPaise,
        taxSum,
      ));
    }
  }
  final hsnRows = hsn.values.toList()..sort((a, b) => a.hsn.compareTo(b.hsn));
  notes.sort((a, b) => b.date.compareTo(a.date));
  return GstDetail(hsnRows, notes);
});

