/// Works out, for every invoice, how much has been paid and how much is still
/// due, counting payments received later ("jama") and applying a party's
/// unallocated payments to its oldest dues first. Pure function: no database.
class SettleDoc {
  final String id;
  final String? partyId;
  final String docType; // invoice | credit_note
  final String status; // issued | cancelled
  final int totalPaise;
  final String? refDocumentId;
  final DateTime issuedAt;

  const SettleDoc({
    required this.id,
    required this.partyId,
    required this.docType,
    required this.status,
    required this.totalPaise,
    required this.refDocumentId,
    required this.issuedAt,
  });
}

class SettlePayment {
  final String? documentId;
  final String? partyId;
  final int amountPaise; // negative = refund

  const SettlePayment({required this.documentId, required this.partyId, required this.amountPaise});
}

class BillSettlement {
  /// Bill amount after returns (0 for a cancelled bill).
  final int netPaise;
  final int paidPaise;
  final int duePaise;

  const BillSettlement({required this.netPaise, required this.paidPaise, required this.duePaise});

  bool get isSettled => duePaise <= 0;
}

class SettlementResult {
  final Map<String, BillSettlement> byInvoice;

  /// Money a party paid beyond all of its bills (advance), by party id.
  final Map<String, int> advanceByParty;

  const SettlementResult(this.byInvoice, this.advanceByParty);
}

SettlementResult settleBills(List<SettleDoc> docs, List<SettlePayment> payments) {
  final invoices = docs.where((d) => d.docType == 'invoice').toList();
  final owner = <String, String>{}; // document id -> invoice id it belongs to
  final credits = <String, int>{};
  for (final d in docs) {
    if (d.docType == 'invoice') {
      owner[d.id] = d.id;
    } else if (d.docType == 'credit_note' && d.refDocumentId != null) {
      owner[d.id] = d.refDocumentId!;
      credits[d.refDocumentId!] = (credits[d.refDocumentId!] ?? 0) + d.totalPaise;
    }
  }

  final direct = <String, int>{};
  final pool = <String, int>{}; // partyId -> unallocated money
  for (final p in payments) {
    final inv = p.documentId == null ? null : owner[p.documentId!];
    if (inv != null) {
      direct[inv] = (direct[inv] ?? 0) + p.amountPaise;
    } else if (p.partyId != null) {
      pool[p.partyId!] = (pool[p.partyId!] ?? 0) + p.amountPaise;
    }
  }

  final net = <String, int>{};
  final due = <String, int>{};
  for (final inv in invoices) {
    final n = inv.status == 'cancelled' ? 0 : (inv.totalPaise - (credits[inv.id] ?? 0)).clamp(0, 1 << 40);
    final paidDirect = direct[inv.id] ?? 0;
    net[inv.id] = n;
    due[inv.id] = (n - paidDirect) > 0 ? n - paidDirect : 0;
    final excess = paidDirect - n;
    if (excess > 0 && inv.partyId != null) {
      pool[inv.partyId!] = (pool[inv.partyId!] ?? 0) + excess;
    }
  }

  // Oldest dues first.
  final sorted = invoices.where((i) => i.partyId != null).toList()..sort((a, b) => a.issuedAt.compareTo(b.issuedAt));
  for (final inv in sorted) {
    final available = pool[inv.partyId!] ?? 0;
    final d = due[inv.id]!;
    if (available <= 0 || d <= 0) continue;
    final use = available < d ? available : d;
    due[inv.id] = d - use;
    pool[inv.partyId!] = available - use;
  }

  final result = <String, BillSettlement>{};
  for (final inv in invoices) {
    final n = net[inv.id]!;
    final d = due[inv.id]!;
    result[inv.id] = BillSettlement(netPaise: n, paidPaise: n - d, duePaise: d);
  }
  final advance = <String, int>{};
  pool.forEach((k, v) {
    if (v > 0) advance[k] = v;
  });
  return SettlementResult(result, advance);
}
