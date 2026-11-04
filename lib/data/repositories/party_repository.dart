import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class PartyWithBalance {
  final Party party;
  final int balancePaise;

  PartyWithBalance({
    required this.party,
    required this.balancePaise,
  });
}

enum LedgerItemType {
  invoice,
  creditNote,
  payment,
}

class LedgerItem {
  final String id;
  final LedgerItemType type;
  final String title;
  final DateTime date;
  final int amountPaise;
  final int runningBalancePaise;
  final String? note;
  final String? documentId;
  final String? refDocumentNumber;

  LedgerItem({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.amountPaise,
    required this.runningBalancePaise,
    this.note,
    this.documentId,
    this.refDocumentNumber,
  });
}

class PartyRepository {
  final AppDatabase db;
  final String businessId;
  final String deviceId;

  PartyRepository(this.db, this.businessId, [this.deviceId = 'local-device']);

  Stream<List<Party>> watchParties({String search = ''}) {
    final query = db.select(db.parties)
      ..where((tbl) => tbl.businessId.equals(businessId) & tbl.archivedAt.isNull());

    if (search.isNotEmpty) {
      final term = '%${search.toLowerCase()}%';
      query.where((tbl) => tbl.name.lower().like(term) | tbl.phone.like(term));
    }

    query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Stream<List<PartyWithBalance>> watchPartiesWithBalance({String search = ''}) {
    final query = db.customSelect(
      '''
      SELECT 
        p.id, p.business_id, p.name, p.phone, p.gstin, p.state_code, p.credit_limit_paise, p.created_at, p.updated_at, p.archived_at,
        COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = p.id AND d.doc_type = 'invoice'), 0) -
        COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = p.id AND d.doc_type = 'credit_note'), 0) -
        COALESCE((SELECT SUM(pay.amount_paise) FROM payments pay WHERE pay.party_id = p.id), 0) AS calculated_balance
      FROM parties p
      WHERE p.business_id = ? AND p.archived_at IS NULL
      ORDER BY p.name ASC
      ''',
      variables: [Variable.withString(businessId)],
      readsFrom: {db.parties, db.documents, db.payments},
    );

    return query.watch().map((rows) {
      final list = <PartyWithBalance>[];
      for (final row in rows) {
        final party = Party(
          id: row.read<String>('id'),
          businessId: row.read<String>('business_id'),
          name: row.read<String>('name'),
          phone: row.read<String>('phone'),
          gstin: row.read<String?>('gstin'),
          stateCode: row.read<String>('state_code'),
          creditLimitPaise: row.read<int>('credit_limit_paise'),
          createdAt: row.read<DateTime>('created_at'),
          updatedAt: row.read<DateTime>('updated_at'),
          archivedAt: row.read<DateTime?>('archived_at'),
        );
        final balance = row.read<int>('calculated_balance');
        if (search.isNotEmpty) {
          final term = search.toLowerCase();
          if (!party.name.toLowerCase().contains(term) && !party.phone.contains(term)) {
            continue;
          }
        }
        list.add(PartyWithBalance(party: party, balancePaise: balance));
      }
      return list;
    });
  }

  Future<Party?> getById(String id) {
    return (db.select(db.parties)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> getPartyBalancePaise(String partyId) async {
    final docs = await (db.select(db.documents)..where((t) => t.partyId.equals(partyId))).get();
    int invoices = 0;
    int creditNotes = 0;
    for (final d in docs) {
      if (d.docType == 'invoice') {
        invoices += d.totalPaise;
      } else if (d.docType == 'credit_note') {
        creditNotes += d.totalPaise;
      }
    }
    final pays = await (db.select(db.payments)..where((t) => t.partyId.equals(partyId))).get();
    int paid = pays.fold<int>(0, (sum, p) => sum + p.amountPaise);
    return invoices - creditNotes - paid;
  }

  Stream<int> watchPartyBalancePaise(String partyId) {
    final query = db.customSelect(
      '''
      SELECT 
        COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = ? AND d.doc_type = 'invoice'), 0) -
        COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = ? AND d.doc_type = 'credit_note'), 0) -
        COALESCE((SELECT SUM(pay.amount_paise) FROM payments pay WHERE pay.party_id = ?), 0) AS calculated_balance
      ''',
      variables: [
        Variable.withString(partyId),
        Variable.withString(partyId),
        Variable.withString(partyId),
      ],
      readsFrom: {db.documents, db.payments},
    );

    return query.watchSingle().map((row) => row.read<int>('calculated_balance'));
  }

  Stream<List<LedgerItem>> watchPartyLedger(String partyId) {
    final docsQuery = db.select(db.documents)..where((t) => t.partyId.equals(partyId));
    final paysQuery = db.select(db.payments)..where((t) => t.partyId.equals(partyId));

    final custom = db.customSelect(
      'SELECT 1',
      readsFrom: {db.documents, db.payments},
    );

    return custom.watch().asyncMap((_) async {
      final docs = await docsQuery.get();
      final pays = await paysQuery.get();

      final rawList = <_RawLedgerEntry>[];

      for (final d in docs) {
        if (d.docType == 'invoice') {
          rawList.add(_RawLedgerEntry(
            id: d.id,
            type: LedgerItemType.invoice,
            title: 'Invoice #${d.number}',
            date: d.issuedAt,
            createdAt: d.createdAt,
            amountPaise: d.totalPaise,
            effect: d.totalPaise,
            documentId: d.id,
          ));
        } else if (d.docType == 'credit_note') {
          rawList.add(_RawLedgerEntry(
            id: d.id,
            type: LedgerItemType.creditNote,
            title: 'Credit Note #${d.number}',
            date: d.issuedAt,
            createdAt: d.createdAt,
            amountPaise: d.totalPaise,
            effect: -d.totalPaise,
            documentId: d.id,
          ));
        }
      }

      for (final p in pays) {
        rawList.add(_RawLedgerEntry(
          id: p.id,
          type: LedgerItemType.payment,
          title: 'Payment (${p.method.toUpperCase()})',
          date: p.paidAt,
          createdAt: p.createdAt,
          amountPaise: p.amountPaise,
          effect: -p.amountPaise,
          note: p.note,
          documentId: p.documentId,
        ));
      }

      rawList.sort((a, b) {
        final dateComp = a.date.compareTo(b.date);
        if (dateComp != 0) return dateComp;
        return a.createdAt.compareTo(b.createdAt);
      });

      int currentBalance = 0;
      final computedItems = <LedgerItem>[];

      for (final item in rawList) {
        currentBalance += item.effect;
        computedItems.add(LedgerItem(
          id: item.id,
          type: item.type,
          title: item.title,
          date: item.date,
          amountPaise: item.amountPaise,
          runningBalancePaise: currentBalance,
          note: item.note,
          documentId: item.documentId,
        ));
      }

      return computedItems.reversed.toList();
    });
  }

  Future<Payment> addPayment({
    required String partyId,
    required int amountPaise,
    required String method,
    DateTime? paidAt,
    String? note,
    String? documentId,
  }) async {
    final now = DateTime.now();
    final paymentId = const Uuid().v4();

    final companion = PaymentsCompanion.insert(
      id: paymentId,
      businessId: businessId,
      partyId: Value(partyId),
      documentId: Value(documentId),
      method: method,
      amountPaise: amountPaise,
      paidAt: paidAt ?? now,
      note: Value(note),
      createdAt: now,
    );

    await db.transaction(() async {
      await db.into(db.payments).insert(companion);
      await db.enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'push_payment',
        payload: {'payment_id': paymentId},
      );
    });

    final inserted = await (db.select(db.payments)..where((t) => t.id.equals(paymentId))).getSingleOrNull();
    if (inserted == null) {
      throw StateError('Payment record not found');
    }
    return inserted;
  }

  Future<Party> save({
    String? id,
    required String name,
    required String phone,
    String? gstin,
    required String stateCode,
    int creditLimitPaise = 0,
  }) async {
    return db.transaction(() async {
      final now = DateTime.now();
      final partyId = id ?? const Uuid().v4();

      final companion = PartiesCompanion(
        id: Value(partyId),
        businessId: Value(businessId),
        name: Value(name),
        phone: Value(phone),
        gstin: Value(gstin),
        stateCode: Value(stateCode),
        creditLimitPaise: Value(creditLimitPaise),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      if (id == null) {
        await db.into(db.parties).insert(companion);
      } else {
        await (db.update(db.parties)..where((tbl) => tbl.id.equals(id))).write(companion);
      }

      final party = (await getById(partyId))!;

      await db.enqueueOutboxCommand(
        businessId: businessId,
        deviceId: deviceId,
        commandType: 'upsert_party',
        payload: partyToPayload(party),
      );

      return party;
    });
  }

  Future<void> archive(String partyId) async {
    return db.transaction(() async {
      final now = DateTime.now();
      await (db.update(db.parties)..where((tbl) => tbl.id.equals(partyId))).write(
        PartiesCompanion(
          archivedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final party = await getById(partyId);
      if (party != null) {
        await db.enqueueOutboxCommand(
          businessId: businessId,
          deviceId: deviceId,
          commandType: 'upsert_party',
          payload: partyToPayload(party),
        );
      }
    });
  }
}

class _RawLedgerEntry {
  final String id;
  final LedgerItemType type;
  final String title;
  final DateTime date;
  final DateTime createdAt;
  final int amountPaise;
  final int effect;
  final String? note;
  final String? documentId;

  _RawLedgerEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.createdAt,
    required this.amountPaise,
    required this.effect,
    this.note,
    this.documentId,
  });
}
