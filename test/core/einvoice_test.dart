import 'dart:convert';

import 'package:belling/core/einvoice.dart';
import 'package:belling/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final doc = Document(
    id: 'd1',
    businessId: 'b',
    deviceId: 'dv',
    docType: 'invoice',
    number: 'A/26-27/0001',
    partyId: null,
    issuedAt: DateTime(2026, 11, 9),
    status: 'issued',
    taxablePaise: 10000,
    cgstPaise: 900,
    sgstPaise: 900,
    igstPaise: 0,
    roundOffPaise: 0,
    totalPaise: 11800,
    snapshotJson: '{}',
    refDocumentId: null,
    createdAt: DateTime(2026, 11, 9),
    serverSeq: null,
  );
  final line = DocumentLine(
    id: 'l1',
    documentId: 'd1',
    businessId: 'b',
    productId: 'p',
    name: 'Rice',
    hsn: '1006',
    qtyMilli: 2000,
    ratePaise: 5000,
    discountPaise: 0,
    gstRateBp: 1800,
    taxablePaise: 10000,
    cgstPaise: 900,
    sgstPaise: 900,
    igstPaise: 0,
    lineTotalPaise: 11800,
    createdAt: DateTime(2026, 11, 9),
    serverSeq: null,
  );
  final snap = {
    'seller': {'gstin': '27ABCDE1234F1Z5', 'name': 'Shop', 'state_code': '27', 'address': 'Pune'},
    'buyer': {'gstin': '27PQRSX9876L1Z2', 'name': 'Buyer', 'state_code': '27'},
  };

  test('einvoice problem detection', () {
    expect(einvoiceProblem(doc, snap), isNull);
    expect(einvoiceProblem(doc, {'seller': snap['seller'], 'buyer': {}}), isNotNull);
    expect(einvoiceProblem(doc, {'seller': {}, 'buyer': snap['buyer']}), isNotNull);
  });

  test('einvoice json has schema fields and rupee amounts', () {
    final j = buildEinvoiceJson(doc, [line], snap);
    expect(j['Version'], '1.1');
    expect((j['DocDtls'] as Map)['Dt'], '09/11/2026');
    expect((j['ValDtls'] as Map)['TotInvVal'], 118.0);
    final item = (j['ItemList'] as List).single as Map;
    expect(item['Qty'], 2.0);
    expect(item['GstRt'], 18.0);
    expect(() => jsonEncode(j), returnsNormally);
  });

  test('eway json splits GST rate for intra-state', () {
    final j = buildEwayBillJson(doc, [line], snap, distanceKm: 50, vehicleNo: 'mh 12 ab 1234');
    final b = (j['billLists'] as List).single as Map;
    expect(b['vehicleNo'], 'MH12AB1234');
    final it = (b['itemList'] as List).single as Map;
    expect(it['cgstRate'], 9.0);
    expect(it['igstRate'], 0);
  });
}
