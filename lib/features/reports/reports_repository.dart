import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../data/database.dart';

enum DateRangePreset {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  thisFinancialYear,
  custom,
}

DateTimeRange getDateRangeForPreset(
  DateRangePreset preset, {
  DateTimeRange? customRange,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  switch (preset) {
    case DateRangePreset.today:
      final start = DateTime(current.year, current.month, current.day);
      final end = DateTime(current.year, current.month, current.day, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    case DateRangePreset.yesterday:
      final y = current.subtract(const Duration(days: 1));
      final start = DateTime(y.year, y.month, y.day);
      final end = DateTime(y.year, y.month, y.day, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    case DateRangePreset.thisWeek:
      final weekday = current.weekday; // 1 = Mon, 7 = Sun
      final start = DateTime(current.year, current.month, current.day).subtract(Duration(days: weekday - 1));
      final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
      return DateTimeRange(start: start, end: end);
    case DateRangePreset.thisMonth:
      final start = DateTime(current.year, current.month, 1);
      final end = DateTime(current.year, current.month + 1, 0, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    case DateRangePreset.lastMonth:
      final prevMonthDate = DateTime(current.year, current.month - 1, 1);
      final start = DateTime(prevMonthDate.year, prevMonthDate.month, 1);
      final end = DateTime(prevMonthDate.year, prevMonthDate.month + 1, 0, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    case DateRangePreset.thisFinancialYear:
      final fyYear = current.month >= 4 ? current.year : current.year - 1;
      final start = DateTime(fyYear, 4, 1);
      final end = DateTime(fyYear + 1, 3, 31, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    case DateRangePreset.custom:
      return customRange ?? getDateRangeForPreset(DateRangePreset.today, now: current);
  }
}

class ProfitData {
  final int revenuePaise; // sales excluding GST, net of returns
  final int costPaise; // qty x current cost price
  final int itemsWithoutCost; // distinct sold items that have no cost price set

  const ProfitData({required this.revenuePaise, required this.costPaise, required this.itemsWithoutCost});

  int get profitPaise => revenuePaise - costPaise;
  double get marginPercent => revenuePaise <= 0 ? 0 : profitPaise * 100 / revenuePaise;
}

class SalesReportData {
  final int salesTotalPaise;
  final int numberOfBills;
  final int creditGivenPaise;
  final int paymentsReceivedCashPaise;
  final int paymentsReceivedUpiPaise;
  final int paymentsReceivedCardPaise;

  const SalesReportData({
    required this.salesTotalPaise,
    required this.numberOfBills,
    required this.creditGivenPaise,
    required this.paymentsReceivedCashPaise,
    required this.paymentsReceivedUpiPaise,
    required this.paymentsReceivedCardPaise,
  });

  int get paymentsReceivedTotalPaise =>
      paymentsReceivedCashPaise + paymentsReceivedUpiPaise + paymentsReceivedCardPaise;
}

class TopItemData {
  final String productId;
  final String productName;
  final int totalAmountPaise;
  final int totalQtyMilli;

  const TopItemData({
    required this.productId,
    required this.productName,
    required this.totalAmountPaise,
    required this.totalQtyMilli,
  });
}

class LowStockData {
  final String productId;
  final String productName;
  final int currentStockMilli;
  final int reorderLevel;

  const LowStockData({
    required this.productId,
    required this.productName,
    required this.currentStockMilli,
    required this.reorderLevel,
  });
}

class ReceivableData {
  final String partyId;
  final String partyName;
  final String phone;
  final int balancePaise;

  const ReceivableData({
    required this.partyId,
    required this.partyName,
    required this.phone,
    required this.balancePaise,
  });
}

class GstRateSummaryRow {
  final int gstRateBp;
  final int taxablePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  final int totalTaxPaise;
  final int totalAmountPaise;

  const GstRateSummaryRow({
    required this.gstRateBp,
    required this.taxablePaise,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.totalTaxPaise,
    required this.totalAmountPaise,
  });
}

class GstSectionSummary {
  final List<GstRateSummaryRow> b2bRows;
  final List<GstRateSummaryRow> b2cRows;
  final GstRateSummaryRow b2bTotal;
  final GstRateSummaryRow b2cTotal;
  final GstRateSummaryRow grandTotal;
  final int sumOfDocsTotalPaise;
  final int sumOfLinesTotalPaise;

  const GstSectionSummary({
    required this.b2bRows,
    required this.b2cRows,
    required this.b2bTotal,
    required this.b2cTotal,
    required this.grandTotal,
    required this.sumOfDocsTotalPaise,
    required this.sumOfLinesTotalPaise,
  });

  bool get totalsMatch => sumOfDocsTotalPaise == sumOfLinesTotalPaise;
}

class ReportsRepository {
  final AppDatabase db;
  final String businessId;

  ReportsRepository(this.db, this.businessId);

  Future<SalesReportData> getSalesReport(DateTime startDate, DateTime endDate) async {
    final docs = await (db.select(db.documents)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.issuedAt.isBiggerOrEqualValue(startDate) &
              t.issuedAt.isSmallerOrEqualValue(endDate)))
        .get();

    int salesTotal = 0;
    int billCount = 0;
    int creditGiven = 0;

    for (final doc in docs) {
      if (doc.docType == 'invoice') {
        salesTotal += doc.totalPaise;
        billCount++;

        // Get payments made for this invoice
        final docPayments = await (db.select(db.payments)..where((t) => t.documentId.equals(doc.id))).get();
        final paidOnDoc = docPayments.fold<int>(0, (sum, p) => sum + p.amountPaise);
        final unpaid = doc.totalPaise - paidOnDoc;
        if (unpaid > 0 && doc.partyId != null) {
          creditGiven += unpaid;
        }
      } else if (doc.docType == 'credit_note') {
        salesTotal -= doc.totalPaise;
      }
    }

    final payments = await (db.select(db.payments)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.paidAt.isBiggerOrEqualValue(startDate) &
              t.paidAt.isSmallerOrEqualValue(endDate)))
        .get();

    int cash = 0;
    int upi = 0;
    int card = 0;

    for (final p in payments) {
      if (p.method == 'cash') cash += p.amountPaise;
      if (p.method == 'upi') upi += p.amountPaise;
      if (p.method == 'card') card += p.amountPaise;
    }

    return SalesReportData(
      salesTotalPaise: salesTotal,
      numberOfBills: billCount,
      creditGivenPaise: creditGiven,
      paymentsReceivedCashPaise: cash,
      paymentsReceivedUpiPaise: upi,
      paymentsReceivedCardPaise: card,
    );
  }

  /// Estimated profit = sales (ex-GST) - cost of goods sold. Credit notes (cancels,
  /// returns) subtract. Uses each item's *current* cost price.
  Future<ProfitData> getProfit(DateTime startDate, DateTime endDate) async {
    final docs = await (db.select(db.documents)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.issuedAt.isBiggerOrEqualValue(startDate) &
              t.issuedAt.isSmallerOrEqualValue(endDate)))
        .get();
    if (docs.isEmpty) return const ProfitData(revenuePaise: 0, costPaise: 0, itemsWithoutCost: 0);

    final sign = {for (final d in docs) d.id: d.docType == 'credit_note' ? -1 : (d.docType == 'invoice' ? 1 : 0)};
    final lines = await (db.select(db.documentLines)
          ..where((t) => t.businessId.equals(businessId) & t.documentId.isIn(docs.map((d) => d.id).toList())))
        .get();
    final products = {
      for (final p in await (db.select(db.products)..where((t) => t.businessId.equals(businessId))).get()) p.id: p,
    };

    var revenue = 0;
    var cost = 0;
    final noCost = <String>{};
    for (final l in lines) {
      final sg = sign[l.documentId] ?? 0;
      if (sg == 0) continue;
      final unitCost = products[l.productId]?.costPaise ?? 0;
      if (unitCost == 0) noCost.add(l.productId);
      revenue += sg * l.taxablePaise;
      cost += sg * ((l.qtyMilli * unitCost) / 1000).round();
    }
    return ProfitData(revenuePaise: revenue, costPaise: cost, itemsWithoutCost: noCost.length);
  }

  Future<List<TopItemData>> getTopItemsByAmount(DateTime startDate, DateTime endDate, {int limit = 10}) async {
    final rows = await getTopItemsRaw(startDate, endDate);
    rows.sort((a, b) => b.totalAmountPaise.compareTo(a.totalAmountPaise));
    return rows.take(limit).toList();
  }

  Future<List<TopItemData>> getTopItemsByQty(DateTime startDate, DateTime endDate, {int limit = 10}) async {
    final rows = await getTopItemsRaw(startDate, endDate);
    rows.sort((a, b) => b.totalQtyMilli.compareTo(a.totalQtyMilli));
    return rows.take(limit).toList();
  }

  Future<List<TopItemData>> getTopItemsRaw(DateTime startDate, DateTime endDate) async {
    final query = db.select(db.documentLines).join([
      innerJoin(db.documents, db.documents.id.equalsExp(db.documentLines.documentId)),
    ])
      ..where(db.documents.businessId.equals(businessId) &
          db.documents.issuedAt.isBiggerOrEqualValue(startDate) &
          db.documents.issuedAt.isSmallerOrEqualValue(endDate));

    final results = await query.get();
    final itemMap = <String, TopItemData>{};

    for (final row in results) {
      final line = row.readTable(db.documentLines);
      final doc = row.readTable(db.documents);
      final mult = doc.docType == 'credit_note' ? -1 : 1;

      final pId = line.productId;
      final existing = itemMap[pId];
      final addedAmt = line.lineTotalPaise * mult;
      final addedQty = line.qtyMilli * mult;

      if (existing == null) {
        itemMap[pId] = TopItemData(
          productId: pId,
          productName: line.name,
          totalAmountPaise: addedAmt,
          totalQtyMilli: addedQty,
        );
      } else {
        itemMap[pId] = TopItemData(
          productId: pId,
          productName: line.name,
          totalAmountPaise: existing.totalAmountPaise + addedAmt,
          totalQtyMilli: existing.totalQtyMilli + addedQty,
        );
      }
    }

    return itemMap.values.toList();
  }

  Future<List<LowStockData>> getLowStockItems() async {
    final prods = await (db.select(db.products)
          ..where((t) => t.businessId.equals(businessId) & t.trackStock.equals(true)))
        .get();

    final lowStockList = <LowStockData>[];

    for (final p in prods) {
      final movements = await (db.select(db.stockMovements)..where((t) => t.productId.equals(p.id))).get();
      final currentStock = movements.fold<int>(0, (sum, m) => sum + m.qtyMilli);

      if (currentStock <= p.reorderLevel) {
        lowStockList.add(LowStockData(
          productId: p.id,
          productName: p.name,
          currentStockMilli: currentStock,
          reorderLevel: p.reorderLevel,
        ));
      }
    }

    lowStockList.sort((a, b) => a.currentStockMilli.compareTo(b.currentStockMilli));
    return lowStockList;
  }

  Future<List<ReceivableData>> getTopReceivables({int limit = 10}) async {
    final query = db.customSelect(
      '''
      SELECT id, name, phone, calculated_balance FROM (
        SELECT
          p.id AS id, p.name AS name, p.phone AS phone,
          COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = p.id AND d.doc_type = 'invoice'), 0) -
          COALESCE((SELECT SUM(d.total_paise) FROM documents d WHERE d.party_id = p.id AND d.doc_type = 'credit_note'), 0) -
          COALESCE((SELECT SUM(pay.amount_paise) FROM payments pay WHERE pay.party_id = p.id), 0) AS calculated_balance
        FROM parties p
        WHERE p.business_id = ?
      )
      WHERE calculated_balance > 0
      ORDER BY calculated_balance DESC
      LIMIT ?
      ''',
      variables: [Variable.withString(businessId), Variable.withInt(limit)],
      readsFrom: {db.parties, db.documents, db.payments},
    );

    final rows = await query.get();
    return rows.map((r) {
      return ReceivableData(
        partyId: r.read<String>('id'),
        partyName: r.read<String>('name'),
        phone: r.read<String>('phone'),
        balancePaise: r.read<int>('calculated_balance'),
      );
    }).toList();
  }

  Future<GstSectionSummary> getGstSummary(DateTime startDate, DateTime endDate) async {
    // 1. Documents in range
    final docs = await (db.select(db.documents)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.issuedAt.isBiggerOrEqualValue(startDate) &
              t.issuedAt.isSmallerOrEqualValue(endDate)))
        .get();

    int sumDocs = 0;
    for (final d in docs) {
      // Compare before round-off: the round-off is on the document, not on any line.
      final beforeRoundOff = d.totalPaise - d.roundOffPaise;
      if (d.docType == 'invoice') {
        sumDocs += beforeRoundOff;
      } else if (d.docType == 'credit_note') {
        sumDocs -= beforeRoundOff;
      }
    }

    // 2. Lines in range joined with documents & parties
    final query = db.select(db.documentLines).join([
      innerJoin(db.documents, db.documents.id.equalsExp(db.documentLines.documentId)),
      leftOuterJoin(db.parties, db.parties.id.equalsExp(db.documents.partyId)),
    ])
      ..where(db.documents.businessId.equals(businessId) &
          db.documents.issuedAt.isBiggerOrEqualValue(startDate) &
          db.documents.issuedAt.isSmallerOrEqualValue(endDate));

    final results = await query.get();

    final b2bMap = <int, GstRateSummaryRow>{};
    final b2cMap = <int, GstRateSummaryRow>{};

    int sumLines = 0;

    for (final row in results) {
      final line = row.readTable(db.documentLines);
      final doc = row.readTable(db.documents);
      final party = row.readTableOrNull(db.parties);

      final mult = doc.docType == 'credit_note' ? -1 : 1;
      final isB2b = party != null && party.gstin != null && party.gstin!.trim().isNotEmpty;

      final map = isB2b ? b2bMap : b2cMap;
      final rateBp = line.gstRateBp;

      final tPaise = line.taxablePaise * mult;
      final cPaise = line.cgstPaise * mult;
      final sPaise = line.sgstPaise * mult;
      final iPaise = line.igstPaise * mult;
      final totTax = cPaise + sPaise + iPaise;
      final totAmt = line.lineTotalPaise * mult;

      sumLines += totAmt;

      final existing = map[rateBp];
      if (existing == null) {
        map[rateBp] = GstRateSummaryRow(
          gstRateBp: rateBp,
          taxablePaise: tPaise,
          cgstPaise: cPaise,
          sgstPaise: sPaise,
          igstPaise: iPaise,
          totalTaxPaise: totTax,
          totalAmountPaise: totAmt,
        );
      } else {
        map[rateBp] = GstRateSummaryRow(
          gstRateBp: rateBp,
          taxablePaise: existing.taxablePaise + tPaise,
          cgstPaise: existing.cgstPaise + cPaise,
          sgstPaise: existing.sgstPaise + sPaise,
          igstPaise: existing.igstPaise + iPaise,
          totalTaxPaise: existing.totalTaxPaise + totTax,
          totalAmountPaise: existing.totalAmountPaise + totAmt,
        );
      }
    }

    final b2bRows = b2bMap.values.toList()..sort((a, b) => a.gstRateBp.compareTo(b.gstRateBp));
    final b2cRows = b2cMap.values.toList()..sort((a, b) => a.gstRateBp.compareTo(b.gstRateBp));

    GstRateSummaryRow sumRows(List<GstRateSummaryRow> rows, int rateBp) {
      int t = 0, c = 0, s = 0, i = 0, tax = 0, amt = 0;
      for (final r in rows) {
        t += r.taxablePaise;
        c += r.cgstPaise;
        s += r.sgstPaise;
        i += r.igstPaise;
        tax += r.totalTaxPaise;
        amt += r.totalAmountPaise;
      }
      return GstRateSummaryRow(
        gstRateBp: rateBp,
        taxablePaise: t,
        cgstPaise: c,
        sgstPaise: s,
        igstPaise: i,
        totalTaxPaise: tax,
        totalAmountPaise: amt,
      );
    }

    final b2bTotal = sumRows(b2bRows, -1);
    final b2cTotal = sumRows(b2cRows, -1);
    final grandTotal = sumRows([...b2bRows, ...b2cRows], -1);

    return GstSectionSummary(
      b2bRows: b2bRows,
      b2cRows: b2cRows,
      b2bTotal: b2bTotal,
      b2cTotal: b2cTotal,
      grandTotal: grandTotal,
      sumOfDocsTotalPaise: sumDocs,
      sumOfLinesTotalPaise: sumLines,
    );
  }
}
