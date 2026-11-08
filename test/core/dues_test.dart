import 'package:belling/core/dues.dart';
import 'package:belling/core/dues_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

DueDoc inv(String id, int day, int total, {String status = 'issued'}) => DueDoc(
      id: id,
      number: 'A-000$id',
      issuedAt: DateTime(2026, 11, day),
      docType: 'invoice',
      status: status,
      totalPaise: total,
    );

void main() {
  group('computeDues', () {
    test('fully credit bill is fully due', () {
      final r = computeDues(docs: [inv('1', 1, 100000)], payments: []);
      expect(r.totalDuePaise, 100000);
      expect(r.openInvoices.single.paidPaise, 0);
      expect(r.openInvoices.single.isPartlyPaid, isFalse);
    });

    test('half paid at billing leaves the other half due', () {
      final r = computeDues(
        docs: [inv('1', 1, 100000)],
        payments: [const DuePayment(documentId: '1', amountPaise: 50000)],
      );
      expect(r.totalDuePaise, 50000);
      expect(r.openInvoices.single.paidPaise, 50000);
      expect(r.openInvoices.single.isPartlyPaid, isTrue);
    });

    test('fully paid bill is not listed', () {
      final r = computeDues(
        docs: [inv('1', 1, 100000)],
        payments: [const DuePayment(documentId: '1', amountPaise: 100000)],
      );
      expect(r.hasDues, isFalse);
      expect(r.openInvoices, isEmpty);
    });

    test('general payment settles the oldest bill first', () {
      final r = computeDues(
        docs: [inv('1', 1, 100000), inv('2', 5, 60000)],
        payments: [const DuePayment(amountPaise: 120000)],
      );
      expect(r.openInvoices.length, 1);
      expect(r.openInvoices.single.id, '2');
      expect(r.openInvoices.single.duePaise, 40000);
      expect(r.openInvoices.single.paidPaise, 20000);
      expect(r.totalDuePaise, 40000);
    });

    test('overpaying one bill carries over to the next', () {
      final r = computeDues(
        docs: [inv('1', 1, 10000), inv('2', 2, 30000)],
        payments: [const DuePayment(documentId: '1', amountPaise: 15000)],
      );
      expect(r.openInvoices.single.id, '2');
      expect(r.openInvoices.single.duePaise, 25000);
    });

    test('cancelled bill with its credit note and refund is ignored', () {
      final r = computeDues(
        docs: [
          inv('1', 1, 100000, status: 'cancelled'),
          DueDoc(
            id: 'cn1',
            number: 'CN-1',
            issuedAt: _d,
            docType: 'credit_note',
            status: 'issued',
            totalPaise: 100000,
            refDocumentId: '1',
          ),
          inv('2', 3, 50000),
        ],
        payments: [
          const DuePayment(documentId: '1', amountPaise: 100000),
          const DuePayment(documentId: 'cn1', amountPaise: -100000),
        ],
      );
      expect(r.totalDuePaise, 50000);
      expect(r.openInvoices.single.id, '2');
    });

    test('credit note for a live bill reduces it', () {
      final r = computeDues(
        docs: [
          inv('1', 1, 100000),
          DueDoc(
            id: 'cn1',
            number: 'CN-1',
            issuedAt: DateTime(2026, 11, 2),
            docType: 'credit_note',
            status: 'issued',
            totalPaise: 30000,
            refDocumentId: '1',
          ),
        ],
        payments: [],
      );
      expect(r.totalDuePaise, 70000);
    });

    test('customer who paid in advance has no dues and shows advance', () {
      final r = computeDues(
        docs: [inv('1', 1, 10000)],
        payments: [const DuePayment(amountPaise: 25000)],
      );
      expect(r.hasDues, isFalse);
      expect(r.advancePaise, 15000);
    });

    test('total due matches the ledger balance (bills - credit notes - payments)', () {
      final docs = [inv('1', 1, 100000), inv('2', 2, 45050), inv('3', 3, 2000)];
      final pays = [
        const DuePayment(documentId: '2', amountPaise: 5050),
        const DuePayment(amountPaise: 30000),
      ];
      final r = computeDues(docs: docs, payments: pays);
      final ledger = 100000 + 45050 + 2000 - 5050 - 30000;
      expect(r.totalDuePaise, ledger);
    });
  });

  group('phone', () {
    test('normalises Indian numbers', () {
      expect(normalizeIndianPhone('98765 43210'), '919876543210');
      expect(normalizeIndianPhone('09876543210'), '919876543210');
      expect(normalizeIndianPhone('+91 98765-43210'), '919876543210');
      expect(normalizeIndianPhone('919876543210'), '919876543210');
    });

    test('unusable numbers give null', () {
      expect(normalizeIndianPhone(null), isNull);
      expect(normalizeIndianPhone(''), isNull);
      expect(normalizeIndianPhone('12345'), isNull);
    });
  });

  group('message and PDF', () {
    final dues = computeDues(
      docs: [inv('1', 1, 100000), inv('2', 5, 60000)],
      payments: [const DuePayment(documentId: '1', amountPaise: 40000)],
    );
    final withLines = DuesResult(
      openInvoices: [
        dues.openInvoices[0].withLines(const [
          DueLine(name: 'Atta 5kg', qtyMilli: 2000, ratePaise: 28500, lineTotalPaise: 57000),
        ]),
        dues.openInvoices[1],
      ],
      totalDuePaise: dues.totalDuePaise,
      totalBilledPaise: dues.totalBilledPaise,
      totalPaidPaise: dues.totalPaidPaise,
      advancePaise: 0,
    );

    test('message lists bills, items, paid, due, total and UPI', () {
      final m = buildDuesMessage(partyName: 'Ramesh', shopName: 'Shop', dues: withLines, upiId: 'shop@upi');
      expect(m, contains('Ramesh'));
      expect(m, contains('A-0001'));
      expect(m, contains('A-0002'));
      expect(m, contains('Atta 5kg'));
      expect(m, contains('Paid'));
      expect(m, contains('shop@upi'));
      expect(m, contains('Total amount due'));
    });

    test('message works in Hindi and Gujarati', () {
      final hi = buildDuesMessage(partyName: 'R', shopName: 'S', dues: withLines, languageCode: 'hi');
      final gu = buildDuesMessage(partyName: 'R', shopName: 'S', dues: withLines, languageCode: 'gu');
      expect(hi, contains('कुल बकाया'));
      expect(gu, contains('કુલ બાકી રકમ'));
    });

    test('PDF is generated', () async {
      final bytes = await generateDuesPdf(
        partyName: 'Ramesh',
        partyPhone: '9876543210',
        shopName: 'Shop',
        upiId: 'shop@upi',
        dues: withLines,
      );
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });
  });
}

final _d = DateTime(2026, 11, 1);
