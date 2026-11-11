import 'package:belling/core/bill_settlement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SettleDoc inv(String id, int total, int day, {String party = 'p1', String status = 'issued'}) => SettleDoc(
        id: id,
        partyId: party,
        docType: 'invoice',
        status: status,
        totalPaise: total,
        refDocumentId: null,
        issuedAt: DateTime(2026, 1, day),
      );

  test('later payment settles the oldest bill first, extra is advance', () {
    final r = settleBills(
      [inv('a', 10000, 1), inv('b', 5000, 2)],
      [
        const SettlePayment(documentId: 'a', partyId: 'p1', amountPaise: 4000), // paid at billing
        const SettlePayment(documentId: null, partyId: 'p1', amountPaise: 6000), // 4 days later
      ],
    );
    expect(r.byInvoice['a']!.duePaise, 0);
    expect(r.byInvoice['b']!.duePaise, 5000);
    final r2 = settleBills(
      [inv('a', 10000, 1), inv('b', 5000, 2)],
      [
        const SettlePayment(documentId: null, partyId: 'p1', amountPaise: 20000),
      ],
    );
    expect(r2.byInvoice['a']!.duePaise, 0);
    expect(r2.byInvoice['b']!.duePaise, 0);
    expect(r2.advanceByParty['p1'], 5000);
  });

  test('cancelled bill is not due and its refund is not reused', () {
    final docs = [
      inv('a', 10000, 1, status: 'cancelled'),
      const SettleDoc(
          id: 'cn', partyId: 'p1', docType: 'credit_note', status: 'issued', totalPaise: 10000, refDocumentId: 'a', issuedAt: DateTime(2026, 1, 3)),
    ];
    final r = settleBills(docs, [
      const SettlePayment(documentId: 'a', partyId: 'p1', amountPaise: 10000),
      const SettlePayment(documentId: 'cn', partyId: 'p1', amountPaise: -10000),
    ]);
    expect(r.byInvoice['a']!.duePaise, 0);
    expect(r.advanceByParty.isEmpty, true);
  });
}
