import 'package:drift/drift.dart';

import '../database.dart';
import '../../core/bill_settlement.dart';

class DocumentWithParty {
  final Document document;
  final Party? party;

  DocumentWithParty({required this.document, this.party});
}

/// One row of the "All Bills" list.
class BillRow {
  final String id;
  final String number;
  final String docType;
  final String status;
  final int totalPaise;
  final DateTime issuedAt;
  final String? partyId;
  final String? partyName;
  final String? customerName;
  final BillSettlement? settlement; // invoices only

  const BillRow({
    required this.id,
    required this.number,
    required this.docType,
    required this.status,
    required this.totalPaise,
    required this.issuedAt,
    required this.partyId,
    required this.partyName,
    required this.customerName,
    required this.settlement,
  });

  String? get displayName => partyName ?? customerName;
}

class BillsOverview {
  final List<BillRow> rows;
  final Map<String, int> advanceByParty;
  const BillsOverview(this.rows, this.advanceByParty);
  late final Map<String, BillRow> byId = {for (final r in rows) r.id: r};
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

  /// Every bill ever issued (newest first) with paid / due worked out, live.
  Stream<BillsOverview> watchBillsOverview() {
    final q = db.customSelect(
      'SELECT 1',
      readsFrom: {db.documents, db.payments, db.parties},
    );
    return q.watch().asyncMap((_) async {
      final docRows = await db.customSelect(
        '''
        SELECT d.id, d.number, d.doc_type, d.status, d.total_paise, d.issued_at, d.party_id,
               d.ref_document_id, p.name AS party_name,
               json_extract(d.snapshot_json, '\$.customer_name') AS customer_name
        FROM documents d LEFT JOIN parties p ON p.id = d.party_id
        WHERE d.business_id = ?
        ORDER BY d.issued_at DESC, d.created_at DESC
        ''',
        variables: [Variable.withString(businessId)],
      ).get();
      final payRows = await db.customSelect(
        'SELECT document_id, party_id, amount_paise FROM payments WHERE business_id = ?',
        variables: [Variable.withString(businessId)],
      ).get();

      final settleDocs = <SettleDoc>[];
      for (final r in docRows) {
        settleDocs.add(SettleDoc(
          id: r.read<String>('id'),
          partyId: r.read<String?>('party_id'),
          docType: r.read<String>('doc_type'),
          status: r.read<String>('status'),
          totalPaise: r.read<int>('total_paise'),
          refDocumentId: r.read<String?>('ref_document_id'),
          issuedAt: r.read<DateTime>('issued_at'),
        ));
      }
      final result = settleBills(
        settleDocs,
        [
          for (final r in payRows)
            SettlePayment(
              documentId: r.read<String?>('document_id'),
              partyId: r.read<String?>('party_id'),
              amountPaise: r.read<int>('amount_paise'),
            ),
        ],
      );
      final rows = <BillRow>[
        for (final r in docRows)
          BillRow(
            id: r.read<String>('id'),
            number: r.read<String>('number'),
            docType: r.read<String>('doc_type'),
            status: r.read<String>('status'),
            totalPaise: r.read<int>('total_paise'),
            issuedAt: r.read<DateTime>('issued_at'),
            partyId: r.read<String?>('party_id'),
            partyName: r.read<String?>('party_name'),
            customerName: r.read<String?>('customer_name'),
            settlement: result.byInvoice[r.read<String>('id')],
          ),
      ];
      return BillsOverview(rows, result.advanceByParty);
    });
  }

  Future<Document> issueInvoice({
    required List<IssueDocumentLineParam> lines,
    String? partyId,
    required bool isInterState,
    List<PaymentParam>? payments,
    DateTime? issuedAt,
    String? customerName,
  }) async {
    final fy = getFinancialYear(issuedAt ?? DateTime.now());
    return db.issueDocument(
      customerName: customerName,
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
