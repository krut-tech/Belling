import 'dart:convert';

import '../data/database.dart';

String _dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

double _r(int paise) => paise / 100.0;

String _unit(int milli) => 'NOS';

/// Why a document cannot be exported as e-invoice, or null when it can.
String? einvoiceProblem(Document doc, Map<String, dynamic> snapshot) {
  if (doc.docType != 'invoice' && doc.docType != 'credit_note') return 'Sirf invoice ya credit note';
  final seller = (snapshot['seller'] as Map?) ?? const {};
  final buyer = (snapshot['buyer'] as Map?) ?? const {};
  if (((seller['gstin'] as String?) ?? '').trim().length != 15) return 'Aapka GSTIN set nahi hai (More > Business settings)';
  if (((buyer['gstin'] as String?) ?? '').trim().length != 15) return 'E-invoice sirf B2B (customer ka GSTIN ho) ke liye hota hai';
  return null;
}

/// Builds the NIC e-invoice (IRP) JSON, schema 1.1, for a B2B invoice / credit
/// note. Fields Belling does not store (PIN codes, location) are filled with
/// the placeholders the IRP asks you to correct; check before uploading.
Map<String, dynamic> buildEinvoiceJson(Document doc, List<DocumentLine> lines, Map<String, dynamic> snapshot) {
  final seller = (snapshot['seller'] as Map?)?.cast<String, dynamic>() ?? {};
  final buyer = (snapshot['buyer'] as Map?)?.cast<String, dynamic>() ?? {};
  final sellerState = ((seller['state_code'] as String?) ?? '').padLeft(2, '0');
  final buyerState = ((buyer['state_code'] as String?) ?? sellerState).padLeft(2, '0');
  final sign = doc.docType == 'credit_note' ? 'CRN' : 'INV';

  final items = <Map<String, dynamic>>[];
  var i = 1;
  for (final l in lines) {
    final gross = (l.qtyMilli * l.ratePaise / 1000).round();
    items.add({
      'SlNo': '${i++}',
      'PrdDesc': l.name,
      'IsServc': 'N',
      'HsnCd': l.hsn,
      'Qty': l.qtyMilli / 1000.0,
      'Unit': _unit(l.qtyMilli),
      'UnitPrice': _r(l.ratePaise),
      'TotAmt': _r(gross),
      'Discount': _r(l.discountPaise),
      'AssAmt': _r(l.taxablePaise),
      'GstRt': l.gstRateBp / 100.0,
      'IgstAmt': _r(l.igstPaise),
      'CgstAmt': _r(l.cgstPaise),
      'SgstAmt': _r(l.sgstPaise),
      'TotItemVal': _r(l.lineTotalPaise),
    });
  }

  return {
    'Version': '1.1',
    'TranDtls': {'TaxSch': 'GST', 'SupTyp': 'B2B', 'RegRev': 'N', 'IgstOnIntra': 'N'},
    'DocDtls': {'Typ': sign, 'No': doc.number, 'Dt': _dmy(doc.issuedAt)},
    'SellerDtls': {
      'Gstin': seller['gstin'],
      'LglNm': seller['name'],
      'Addr1': (seller['address'] as String?)?.isNotEmpty == true ? seller['address'] : 'CHECK ADDRESS',
      'Loc': 'CHECK LOCATION',
      'Pin': 0, // fill the 6-digit PIN before uploading
      'Stcd': sellerState,
    },
    'BuyerDtls': {
      'Gstin': buyer['gstin'],
      'LglNm': buyer['name'] ?? '',
      'Pos': buyerState,
      'Addr1': 'CHECK ADDRESS',
      'Loc': 'CHECK LOCATION',
      'Pin': 0,
      'Stcd': buyerState,
    },
    'ItemList': items,
    'ValDtls': {
      'AssVal': _r(doc.taxablePaise),
      'CgstVal': _r(doc.cgstPaise),
      'SgstVal': _r(doc.sgstPaise),
      'IgstVal': _r(doc.igstPaise),
      'RndOffAmt': _r(doc.roundOffPaise),
      'TotInvVal': _r(doc.totalPaise),
    },
  };
}

/// E-way bill bulk-upload JSON (portal "Generate in bulk"). Transport details
/// come from the user.
Map<String, dynamic> buildEwayBillJson(
  Document doc,
  List<DocumentLine> lines,
  Map<String, dynamic> snapshot, {
  required int distanceKm,
  required String vehicleNo,
}) {
  final seller = (snapshot['seller'] as Map?)?.cast<String, dynamic>() ?? {};
  final buyer = (snapshot['buyer'] as Map?)?.cast<String, dynamic>() ?? {};
  final from = int.tryParse((seller['state_code'] as String?) ?? '') ?? 0;
  final to = int.tryParse((buyer['state_code'] as String?) ?? '') ?? from;
  final inter = doc.igstPaise != 0;
  return {
    'version': '1.0.0621',
    'billLists': [
      {
        'userGstin': seller['gstin'],
        'supplyType': 'O',
        'subSupplyType': 1,
        'docType': doc.docType == 'credit_note' ? 'CNT' : 'INV',
        'docNo': doc.number,
        'docDate': _dmy(doc.issuedAt),
        'fromGstin': seller['gstin'],
        'fromStateCode': from,
        'actualFromStateCode': from,
        'toGstin': (buyer['gstin'] as String?)?.isNotEmpty == true ? buyer['gstin'] : 'URP',
        'toStateCode': to,
        'actualToStateCode': to,
        'transactionType': 1,
        'totalValue': _r(doc.taxablePaise),
        'cgstValue': _r(doc.cgstPaise),
        'sgstValue': _r(doc.sgstPaise),
        'igstValue': _r(doc.igstPaise),
        'cessValue': 0,
        'totInvValue': _r(doc.totalPaise),
        'transMode': 1,
        'transDistance': distanceKm,
        'vehicleNo': vehicleNo.replaceAll(RegExp(r'\s'), '').toUpperCase(),
        'vehicleType': 'R',
        'itemList': [
          for (final l in lines)
            {
              'productName': l.name,
              'hsnCode': int.tryParse(l.hsn) ?? 0,
              'quantity': l.qtyMilli / 1000.0,
              'qtyUnit': 'NOS',
              'taxableAmount': _r(l.taxablePaise),
              'sgstRate': inter ? 0 : l.gstRateBp / 200.0,
              'cgstRate': inter ? 0 : l.gstRateBp / 200.0,
              'igstRate': inter ? l.gstRateBp / 100.0 : 0,
              'cessRate': 0,
            }
        ],
      }
    ],
  };
}

String prettyJson(Object o) => const JsonEncoder.withIndent('  ').convert(o);
