import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dues.dart';
import '../database.dart';
import '../providers.dart';

/// Everything needed to remind one customer about unpaid bills.
class PartyDues {
  final Party party;
  final Business? business;
  final DuesResult dues;
  const PartyDues({required this.party, required this.business, required this.dues});
}

class DuesRepository {
  final AppDatabase db;
  final String businessId;
  DuesRepository(this.db, this.businessId);

  Future<PartyDues?> getPartyDues(String partyId) async {
    final party = await (db.select(db.parties)..where((t) => t.id.equals(partyId))).getSingleOrNull();
    if (party == null) return null;

    final business = await (db.select(db.businesses)..where((t) => t.id.equals(businessId))).getSingleOrNull();

    final docs = await (db.select(db.documents)..where((t) => t.partyId.equals(partyId))).get();
    final pays = await (db.select(db.payments)..where((t) => t.partyId.equals(partyId))).get();

    final result = computeDues(
      docs: [
        for (final d in docs)
          DueDoc(
            id: d.id,
            number: d.number,
            issuedAt: d.issuedAt,
            docType: d.docType,
            status: d.status,
            totalPaise: d.totalPaise,
            refDocumentId: d.refDocumentId,
          ),
      ],
      payments: [for (final p in pays) DuePayment(documentId: p.documentId, amountPaise: p.amountPaise)],
    );

    // Attach the items of each open bill.
    final ids = result.openInvoices.map((i) => i.id).toList();
    final lineRows = ids.isEmpty
        ? <DocumentLine>[]
        : await (db.select(db.documentLines)
              ..where((t) => t.documentId.isIn(ids))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final byDoc = <String, List<DueLine>>{};
    for (final l in lineRows) {
      byDoc.putIfAbsent(l.documentId, () => []).add(DueLine(
            name: l.name,
            qtyMilli: l.qtyMilli,
            ratePaise: l.ratePaise,
            lineTotalPaise: l.lineTotalPaise,
          ));
    }

    return PartyDues(
      party: party,
      business: business,
      dues: DuesResult(
        openInvoices: [for (final i in result.openInvoices) i.withLines(byDoc[i.id] ?? const [])],
        totalDuePaise: result.totalDuePaise,
        totalBilledPaise: result.totalBilledPaise,
        totalPaidPaise: result.totalPaidPaise,
        advancePaise: result.advancePaise,
      ),
    );
  }
}

final duesRepositoryProvider = Provider<DuesRepository>((ref) {
  return DuesRepository(ref.watch(databaseProvider), ref.watch(currentBusinessIdProvider));
});
