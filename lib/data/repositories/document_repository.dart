import 'package:drift/drift.dart';

import '../database.dart';

class DocumentWithParty {
  final Document document;
  final Party? party;

  DocumentWithParty({required this.document, this.party});
}

class DocumentRepository {
  final AppDatabase db;
  final String businessId;
  final String deviceId;

  DocumentRepository(this.db, this.businessId, this.deviceId);

  Stream<List<DocumentWithParty>> watchTodayDocuments() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final query = db.select(db.documents).join([
      leftOuterJoin(db.parties, db.parties.id.equalsExp(db.documents.partyId)),
    ])
      ..where(db.documents.businessId.equals(businessId) &
          db.documents.issuedAt.isBiggerOrEqualValue(startOfToday) &
          db.documents.issuedAt.isSmallerOrEqualValue(endOfToday))
      ..orderBy([OrderingTerm.desc(db.documents.issuedAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DocumentWithParty(
          document: row.readTable(db.documents),
          party: row.readTableOrNull(db.parties),
        );
      }).toList();
    });
  }

  Future<DocumentWithParty?> getDocumentWithParty(String documentId) async {
    final query = db.select(db.documents).join([
      leftOuterJoin(db.parties, db.parties.id.equalsExp(db.documents.partyId)),
    ])..where(db.documents.id.equals(documentId));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return DocumentWithParty(
      document: row.readTable(db.documents),
      party: row.readTableOrNull(db.parties),
    );
  }

  Future<Document> issueInvoice({
    required List<IssueDocumentLineParam> lines,
    String? partyId,
    required bool isInterState,
    List<PaymentParam>? payments,
    DateTime? issuedAt,
  }) async {
    final fy = getFinancialYear(issuedAt ?? DateTime.now());
    return db.issueDocument(
      businessId: businessId,
      deviceId: deviceId,
      docType: 'invoice',
      financialYear: fy,
      partyId: partyId,
      lines: lines,
      isInterState: isInterState,
      payments: payments,
      issuedAt: issuedAt,
    );
  }

  Future<Document> cancelInvoice({
    required String documentId,
    required String reason,
  }) async {
    return db.cancelInvoice(
      businessId: businessId,
      deviceId: deviceId,
      documentId: documentId,
      reason: reason,
    );
  }

  Future<Document> returnItems({
    required String documentId,
    required Map<String, int> returnQtyByLineId,
    required String reason,
  }) {
    return db.returnItems(
      businessId: businessId,
      deviceId: deviceId,
      documentId: documentId,
      returnQtyByLineId: returnQtyByLineId,
      reason: reason,
    );
  }

  Future<void> saveDraftCart({
    String? partyId,
    required String cartJson,
  }) async {
    final now = DateTime.now();
    await db.into(db.draftCarts).insertOnConflictUpdate(
      DraftCartsCompanion.insert(
        id: 'active_draft',
        businessId: businessId,
        partyId: Value(partyId),
        cartJson: cartJson,
        updatedAt: now,
      ),
    );
  }

  Future<DraftCart?> getDraftCart() async {
    return (db.select(db.draftCarts)
          ..where((tbl) => tbl.businessId.equals(businessId)))
        .getSingleOrNull();
  }

  Future<void> clearDraftCart() async {
    await (db.delete(db.draftCarts)..where((tbl) => tbl.businessId.equals(businessId))).go();
  }
}
