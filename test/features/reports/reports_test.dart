import 'dart:convert';
import 'package:belling/data/database.dart';
import 'package:belling/data/providers.dart';
import 'package:belling/data/repositories/document_repository.dart';
import 'package:belling/data/repositories/party_repository.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:belling/features/reports/gst_summary_page.dart';
import 'package:belling/features/reports/reports_providers.dart';
import 'package:belling/features/reports/reports_repository.dart';
import 'package:belling/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 7: Reports & GST Summary Tests', () {
    late AppDatabase db;
    late ProductRepository productRepo;
    late PartyRepository partyRepo;
    late DocumentRepository docRepo;
    late ReportsRepository reportsRepo;
    const businessId = kLocalBusinessId;
    const deviceId = kLocalDeviceId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      productRepo = ProductRepository(db, businessId);
      partyRepo = PartyRepository(db, businessId);
      docRepo = DocumentRepository(db, businessId, deviceId);
      reportsRepo = ReportsRepository(db, businessId);

      // Seed business & device
      await db.into(db.businesses).insertOnConflictUpdate(
            BusinessesCompanion.insert(
              id: businessId,
              businessId: businessId,
              name: 'Test Store',
              stateCode: '27',
              address: '123 Market St',
              createdAt: DateTime.now(),
            ),
          );

      await db.into(db.devices).insertOnConflictUpdate(
            DevicesCompanion.insert(
              id: deviceId,
              businessId: businessId,
              name: 'Terminal 1',
              seriesPrefix: 'A',
              createdAt: DateTime.now(),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('1. Report totals across days', () async {
      final p1 = await productRepo.save(
        name: 'Product A',
        hsn: '1001',
        gstRateBp: 1800,
        pricePaise: 10000,
        costPaise: 5000,
      );

      final day1 = DateTime(2025, 5, 10, 10, 0);
      final day2 = DateTime(2025, 5, 11, 14, 0);

      // Day 1 Invoice
      await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: p1.id,
            name: p1.name,
            hsn: p1.hsn,
            qtyMilli: 2000, // 2 units
            ratePaise: p1.pricePaise,
            gstRateBp: p1.gstRateBp,
          ),
        ],
        payments: [
          const PaymentParam(method: 'cash', amountPaise: 10000),
          const PaymentParam(method: 'upi', amountPaise: 13600),
        ],
        isInterState: false,
        issuedAt: day1,
      );

      // Day 2 Invoice
      await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: p1.id,
            name: p1.name,
            hsn: p1.hsn,
            qtyMilli: 1000, // 1 unit
            ratePaise: p1.pricePaise,
            gstRateBp: p1.gstRateBp,
          ),
        ],
        payments: [
          const PaymentParam(method: 'card', amountPaise: 11800),
        ],
        isInterState: false,
        issuedAt: day2,
      );

      // Query Day 1 only
      final reportDay1 = await reportsRepo.getSalesReport(
        DateTime(2025, 5, 10, 0, 0),
        DateTime(2025, 5, 10, 23, 59, 59),
      );
      expect(reportDay1.numberOfBills, equals(1));
      expect(reportDay1.salesTotalPaise, equals(23600)); // 200 * 1.18 = 236
      expect(reportDay1.paymentsReceivedCashPaise, equals(10000));
      expect(reportDay1.paymentsReceivedUpiPaise, equals(13600));

      // Query Day 1 to Day 2
      final reportBoth = await reportsRepo.getSalesReport(
        DateTime(2025, 5, 10, 0, 0),
        DateTime(2025, 5, 11, 23, 59, 59),
      );
      expect(reportBoth.numberOfBills, equals(2));
      expect(reportBoth.salesTotalPaise, equals(23600 + 11800));
      expect(reportBoth.paymentsReceivedCardPaise, equals(11800));
    });

    test('2. Top items by amount and quantity', () async {
      final p1 = await productRepo.save(
        name: 'Widget High Price',
        hsn: '2001',
        gstRateBp: 1800,
        pricePaise: 50000, // Rs 500
        costPaise: 20000,
      );

      final p2 = await productRepo.save(
        name: 'Widget High Qty',
        hsn: '2002',
        gstRateBp: 500,
        pricePaise: 1000, // Rs 10
        costPaise: 500,
      );

      final now = DateTime.now();

      await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: p1.id,
            name: p1.name,
            hsn: p1.hsn,
            qtyMilli: 1000, // 1 unit
            ratePaise: p1.pricePaise,
            gstRateBp: p1.gstRateBp,
          ),
          IssueDocumentLineParam(
            productId: p2.id,
            name: p2.name,
            hsn: p2.hsn,
            qtyMilli: 50000, // 50 units
            ratePaise: p2.pricePaise,
            gstRateBp: p2.gstRateBp,
          ),
        ],
        isInterState: false,
        issuedAt: now,
      );

      final start = DateTime(now.year, now.month, now.day, 0, 0);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final topByAmt = await reportsRepo.getTopItemsByAmount(start, end);
      expect(topByAmt.first.productName, equals('Widget High Price'));

      final topByQty = await reportsRepo.getTopItemsByQty(start, end);
      expect(topByQty.first.productName, equals('Widget High Qty'));
      expect(topByQty.first.totalQtyMilli, equals(50000));
    });

    test('3. GST by rate with a mix of B2B, B2C and a credit note', () async {
      final b2bParty = await partyRepo.save(
        name: 'Reg Enterprise',
        phone: '9876543210',
        gstin: '27AAAAA0000A1Z5',
        stateCode: '27',
      );

      final p18 = await productRepo.save(
        name: 'Item 18%',
        hsn: '1000',
        gstRateBp: 1800,
        pricePaise: 10000,
        costPaise: 5000,
      );

      final p5 = await productRepo.save(
        name: 'Item 5%',
        hsn: '2000',
        gstRateBp: 500,
        pricePaise: 20000,
        costPaise: 10000,
      );

      final now = DateTime.now();

      // B2B Invoice
      final b2bDoc = await docRepo.issueInvoice(
        partyId: b2bParty.id,
        lines: [
          IssueDocumentLineParam(
            productId: p18.id,
            name: p18.name,
            hsn: p18.hsn,
            qtyMilli: 1000,
            ratePaise: p18.pricePaise,
            gstRateBp: p18.gstRateBp,
          ),
        ],
        isInterState: false,
        issuedAt: now,
      );

      // B2C Invoice (Walk-in, no GSTIN)
      await docRepo.issueInvoice(
        partyId: null,
        lines: [
          IssueDocumentLineParam(
            productId: p5.id,
            name: p5.name,
            hsn: p5.hsn,
            qtyMilli: 1000,
            ratePaise: p5.pricePaise,
            gstRateBp: p5.gstRateBp,
          ),
        ],
        isInterState: false,
        issuedAt: now,
      );

      // Credit Note cancelling B2B invoice
      await docRepo.cancelInvoice(
        documentId: b2bDoc.id,
        reason: 'Customer return',
      );

      final start = DateTime(now.year, now.month, now.day, 0, 0);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final summary = await reportsRepo.getGstSummary(start, end);

      // B2B should have 18% row with 0 net taxable/amount because invoice was cancelled by credit note!
      final b2b18 = summary.b2bRows.firstWhere((r) => r.gstRateBp == 1800);
      expect(b2b18.taxablePaise, equals(0));
      expect(b2b18.totalAmountPaise, equals(0));

      // B2C should have 5% row with 20000 taxable (Rs 200)
      final b2c5 = summary.b2cRows.firstWhere((r) => r.gstRateBp == 500);
      expect(b2c5.taxablePaise, equals(20000));
      expect(b2c5.totalAmountPaise, equals(21000)); // 20000 + 1000 tax = 21000

      expect(summary.totalsMatch, isTrue);
    });

    test('4. CSV UTF-8 with BOM and Hindi/Gujarati text', () async {
      const textHindi = 'यूनिवर्सल बिलिंग';
      const textGujarati = 'યુનિવર્સલ બિલિંગ';

      const csvContent = 'Header\n"$textHindi","$textGujarati"';
      final bytes = utf8.encode('\uFEFF$csvContent');

      // Verify BOM signature
      expect(bytes[0], equals(0xEF));
      expect(bytes[1], equals(0xBB));
      expect(bytes[2], equals(0xBF));

      // Verify text decoding after BOM
      final decoded = utf8.decode(bytes.sublist(3));
      expect(decoded, contains(textHindi));
      expect(decoded, contains(textGujarati));
    });

    testWidgets('5. Totals check banner widget test', (tester) async {
      const mismatchedSummary = GstSectionSummary(
        b2bRows: [],
        b2cRows: [],
        b2bTotal: GstRateSummaryRow(
          gstRateBp: -1,
          taxablePaise: 0,
          cgstPaise: 0,
          sgstPaise: 0,
          igstPaise: 0,
          totalTaxPaise: 0,
          totalAmountPaise: 0,
        ),
        b2cTotal: GstRateSummaryRow(
          gstRateBp: -1,
          taxablePaise: 0,
          cgstPaise: 0,
          sgstPaise: 0,
          igstPaise: 0,
          totalTaxPaise: 0,
          totalAmountPaise: 0,
        ),
        grandTotal: GstRateSummaryRow(
          gstRateBp: -1,
          taxablePaise: 0,
          cgstPaise: 0,
          sgstPaise: 0,
          igstPaise: 0,
          totalTaxPaise: 0,
          totalAmountPaise: 0,
        ),
        sumOfDocsTotalPaise: 10000,
        sumOfLinesTotalPaise: 12000, // Mismatch!
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gstSummaryProvider.overrideWith((ref) => Future.value(mismatchedSummary)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: GstSummaryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify red warning banner is displayed
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('Warning: Document totals do not match line item totals!'), findsOneWidget);
    });
  });
}
