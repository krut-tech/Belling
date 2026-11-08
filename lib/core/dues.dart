import 'package:intl/intl.dart';

import 'money.dart';

/// A document row reduced to what the dues calculation needs.
class DueDoc {
  final String id;
  final String number;
  final DateTime issuedAt;
  final String docType; // 'invoice' | 'credit_note'
  final String status; // 'issued' | 'cancelled'
  final int totalPaise;
  final String? refDocumentId;

  const DueDoc({
    required this.id,
    required this.number,
    required this.issuedAt,
    required this.docType,
    required this.status,
    required this.totalPaise,
    this.refDocumentId,
  });
}

/// A payment row reduced to what the dues calculation needs.
class DuePayment {
  final String? documentId;
  final int amountPaise;
  const DuePayment({this.documentId, required this.amountPaise});
}

class DueLine {
  final String name;
  final int qtyMilli;
  final int ratePaise;
  final int lineTotalPaise;
  const DueLine({
    required this.name,
    required this.qtyMilli,
    required this.ratePaise,
    required this.lineTotalPaise,
  });
}

/// One bill that still has money pending.
class OpenInvoice {
  final String id;
  final String number;
  final DateTime issuedAt;
  final int totalPaise;
  final int paidPaise; // everything settled against this bill so far
  final int duePaise;
  final List<DueLine> lines;

  const OpenInvoice({
    required this.id,
    required this.number,
    required this.issuedAt,
    required this.totalPaise,
    required this.paidPaise,
    required this.duePaise,
    this.lines = const [],
  });

  bool get isPartlyPaid => paidPaise > 0;

  OpenInvoice withLines(List<DueLine> l) => OpenInvoice(
        id: id,
        number: number,
        issuedAt: issuedAt,
        totalPaise: totalPaise,
        paidPaise: paidPaise,
        duePaise: duePaise,
        lines: l,
      );
}

class DuesResult {
  final List<OpenInvoice> openInvoices; // oldest first
  final int totalDuePaise;
  final int totalBilledPaise; // of the open bills
  final int totalPaidPaise; // against the open bills
  final int advancePaise; // credit left over after every bill is settled

  const DuesResult({
    required this.openInvoices,
    required this.totalDuePaise,
    required this.totalBilledPaise,
    required this.totalPaidPaise,
    required this.advancePaise,
  });

  bool get hasDues => totalDuePaise > 0;
}

/// Works out which bills of a customer are still unpaid, and by how much.
///
/// * A payment linked to a bill settles that bill.
/// * Payments not linked to any bill (a general "received from customer") and
///   any amount paid beyond a bill's total settle the oldest bills first.
/// * Cancelled bills, and the credit notes / refunds created by cancelling
///   them, cancel each other out and are ignored.
/// * A credit note for a live bill reduces that bill.
///
/// The total always equals the customer's ledger balance
/// (bills - credit notes - payments) while that balance is positive.
DuesResult computeDues({
  required List<DueDoc> docs,
  required List<DuePayment> payments,
}) {
  final invoices = docs.where((d) => d.docType == 'invoice').toList();
  final cancelledIds = {for (final d in invoices.where((d) => d.status == 'cancelled')) d.id};
  final live = invoices.where((d) => d.status != 'cancelled').toList()
    ..sort((a, b) => a.issuedAt.compareTo(b.issuedAt));
  final liveIds = {for (final d in live) d.id};

  // Credit notes of cancelled bills, and their refund payments, net to zero.
  final ignoredDocIds = <String>{...cancelledIds};
  final creditByInvoice = <String, int>{};
  var pool = 0; // money that is not tied to a particular live bill

  for (final d in docs.where((d) => d.docType == 'credit_note')) {
    if (d.refDocumentId != null && cancelledIds.contains(d.refDocumentId)) {
      ignoredDocIds.add(d.id);
    } else if (d.refDocumentId != null && liveIds.contains(d.refDocumentId)) {
      creditByInvoice[d.refDocumentId!] = (creditByInvoice[d.refDocumentId!] ?? 0) + d.totalPaise;
    } else {
      pool += d.totalPaise;
    }
  }

  final paidByInvoice = <String, int>{};
  for (final p in payments) {
    final docId = p.documentId;
    if (docId != null && ignoredDocIds.contains(docId)) continue;
    if (docId != null && liveIds.contains(docId)) {
      paidByInvoice[docId] = (paidByInvoice[docId] ?? 0) + p.amountPaise;
    } else {
      pool += p.amountPaise;
    }
  }

  final dueById = <String, int>{};
  final settledById = <String, int>{};
  for (final d in live) {
    final settled = (paidByInvoice[d.id] ?? 0) + (creditByInvoice[d.id] ?? 0);
    var due = d.totalPaise - settled;
    if (due < 0) {
      pool += -due; // paid more than the bill: the excess goes to older/other bills
      due = 0;
    }
    dueById[d.id] = due;
    settledById[d.id] = d.totalPaise - due;
  }

  // Spread the unlinked money over the oldest bills first.
  if (pool > 0) {
    for (final d in live) {
      if (pool <= 0) break;
      final due = dueById[d.id]!;
      if (due <= 0) continue;
      final use = pool < due ? pool : due;
      dueById[d.id] = due - use;
      settledById[d.id] = settledById[d.id]! + use;
      pool -= use;
    }
  }

  final open = <OpenInvoice>[];
  var totalDue = 0;
  var billed = 0;
  var paid = 0;
  for (final d in live) {
    final due = dueById[d.id]!;
    if (due <= 0) continue;
    open.add(OpenInvoice(
      id: d.id,
      number: d.number,
      issuedAt: d.issuedAt,
      totalPaise: d.totalPaise,
      paidPaise: settledById[d.id]!,
      duePaise: due,
    ));
    totalDue += due;
    billed += d.totalPaise;
    paid += settledById[d.id]!;
  }

  return DuesResult(
    openInvoices: open,
    totalDuePaise: totalDue,
    totalBilledPaise: billed,
    totalPaidPaise: paid,
    advancePaise: pool > 0 ? pool : 0,
  );
}

/// Digits-only phone number with India's country code for wa.me links.
/// Returns null when there is no usable number.
String? normalizeIndianPhone(String? raw) {
  if (raw == null) return null;
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.length == 11 && digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length == 10) return '91$digits';
  if (digits.length == 12 && digits.startsWith('91')) return digits;
  if (digits.length >= 11 && digits.length <= 15) return digits; // other country
  return null;
}

/// The reminder text: every unpaid bill with its items, what was already
/// paid, what is still due, the grand total, and where to pay.
String buildDuesMessage({
  required String partyName,
  required String shopName,
  required DuesResult dues,
  String? upiId,
  String languageCode = 'en',
  int maxItemsPerBill = 6,
}) {
  final lang = (languageCode == 'hi' || languageCode == 'gu') ? languageCode : 'en';
  final t = {
    'en': {
      'hello': 'Namaste {n},',
      'intro': 'This is a payment reminder from {s}.',
      'bill': 'Bill {no} ({d})',
      'total': 'Total',
      'paid': 'Paid',
      'due': 'Due',
      'more': '+{k} more items',
      'grand': 'Total amount due',
      'upi': 'Pay by UPI',
      'thanks': 'Thank you!',
    },
    'hi': {
      'hello': 'नमस्ते {n},',
      'intro': '{s} की ओर से भुगतान की याद दिलाई जा रही है।',
      'bill': 'बिल {no} ({d})',
      'total': 'कुल',
      'paid': 'जमा',
      'due': 'बाकी',
      'more': '+{k} और आइटम',
      'grand': 'कुल बकाया',
      'upi': 'UPI से भुगतान',
      'thanks': 'धन्यवाद!',
    },
    'gu': {
      'hello': 'નમસ્તે {n},',
      'intro': '{s} તરફથી ચુકવણીની યાદ અપાવવામાં આવે છે.',
      'bill': 'બિલ {no} ({d})',
      'total': 'કુલ',
      'paid': 'જમા',
      'due': 'બાકી',
      'more': '+{k} વધુ વસ્તુઓ',
      'grand': 'કુલ બાકી રકમ',
      'upi': 'UPI થી ચુકવણી',
      'thanks': 'આભાર!',
    },
  }[lang]!;

  String f(String key, [Map<String, String> v = const {}]) {
    var s = t[key]!;
    v.forEach((k, val) => s = s.replaceAll('{$k}', val));
    return s;
  }

  final dateFmt = DateFormat('dd MMM yyyy');
  final b = StringBuffer()
    ..writeln(f('hello', {'n': partyName}))
    ..writeln(f('intro', {'s': shopName}))
    ..writeln();

  for (final inv in dues.openInvoices) {
    b.writeln('*${f('bill', {'no': inv.number, 'd': dateFmt.format(inv.issuedAt)})}*');
    final shown = inv.lines.take(maxItemsPerBill);
    for (final l in shown) {
      b.writeln('• ${l.name} ${formatMilliUnits(l.qtyMilli)} × ${formatRupees(l.ratePaise)} = ${formatRupees(l.lineTotalPaise)}');
    }
    if (inv.lines.length > maxItemsPerBill) {
      b.writeln('  ${f('more', {'k': '${inv.lines.length - maxItemsPerBill}'})}');
    }
    if (inv.isPartlyPaid) {
      b.writeln('${f('total')} ${formatRupees(inv.totalPaise)} | ${f('paid')} ${formatRupees(inv.paidPaise)} | ${f('due')} ${formatRupees(inv.duePaise)}');
    } else {
      b.writeln('${f('due')}: ${formatRupees(inv.duePaise)}');
    }
    b.writeln();
  }

  b.writeln('*${f('grand')}: ${formatRupees(dues.totalDuePaise)}*');
  if (upiId != null && upiId.trim().isNotEmpty) {
    b.writeln('${f('upi')}: ${upiId.trim()}');
  }
  b.writeln();
  b.write(f('thanks'));
  return b.toString();
}
