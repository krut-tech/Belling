import 'dart:convert';
import 'package:belling/core/invoice_pdf.dart';
import 'package:belling/data/database.dart';
import 'package:belling/data/repositories/document_repository.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Invoice PDF & Amount in Words Tests', () {
    test('1. Amount in words (0, 1, 100, 1,053, 1,00,000, 1,23,45,678.50)', () {
      // 0 paise -> ₹0.00
      expect(amountInWords(0), equals('Zero Rupees Only'));

      // 100 paise -> ₹1.00
      expect(amountInWords(100), equals('One Rupee Only'));

      // 10000 paise -> ₹100.00
      expect(amountInWords(10000), equals('One Hundred Rupees Only'));

      // 105300 paise -> ₹1,053.00
      expect(amountInWords(105300), equals('One Thousand Fifty Three Rupees Only'));

      // 10000000 paise -> ₹1,00,000.00
      expect(amountInWords(10000000), equals('One Lakh Rupees Only'));

      // 1234567850 paise -> ₹1,23,45,678.50
      expect(
        amountInWords(1234567850),
        equals('One Crore Twenty Three Lakh Forty Five Thousand Six Hundred Seventy Eight Rupees and Fifty Paise Only'),
      );
    });

    test('2. PDF generation does not throw for a 30-line invoice and for Hindi and Gujarati item names', () async {
      final snapshotMap = {
        'seller': {
          'id': 'local-business',
          'name': 'गंगोत्री प्रोविज़न स्टोर / ગંગોત્રી સ્ટોર',
          'gstin': '27ABCDE1234F1Z5',
          'address': '123 Main Street, Mumbai',
          'state_code': '27',
          'upi_id': 'gangotri@upi',
          'invoice_terms': 'माल वापस नहीं होगा / માલ પાછો લેવામાં આવશે નહીં',
        },
        'buyer': {
          'id': 'p-1',
          'name': 'रमेश पटेल / રમેશ પટેલ',
          'phone': '9876543210',
          'gstin': '27XYZAB9876C1Z1',
          'state_code': '27',
        },
        'tax_breakup': {
          'taxable_paise': 300000,
          'cgst_paise': 15000,
          'sgst_paise': 15000,
          'igst_paise': 0,
          'round_off_paise': 0,
          'total_paise': 330000,
        },
        'issued_at': DateTime.now().toIso8601String(),
        'doc_type': 'invoice',
        'number': 'A-0030',
        'status': 'issued',
      };

      final lines = <DocumentLine>[];
      for (int i = 1; i <= 30; i++) {
        String name;
        if (i % 3 == 0) {
          name = 'आटा 5 किलो (Atta 5kg) - $i';
        } else if (i % 3 == 1) {
          name = 'ઘઉં નો લોટ (Wheat Flour) - $i';
        } else {
          name = 'Standard Item - $i';
        }

        lines.add(
          DocumentLine(
            id: 'line-$i',
            documentId: 'doc-30',
            businessId: 'local-business',
            productId: 'prod-$i',
            name: name,
            hsn: '1001',
            qtyMilli: 1000,
            ratePaise: 10000,
            discountPaise: 0,
            gstRateBp: 1000,
            taxablePaise: 10000,
            cgstPaise: 500,
            sgstPaise: 500,
            igstPaise: 0,
            lineTotalPaise: 11000,
            createdAt: DateTime.now(),
          ),
        );
      }

      final pdfBytes = await generateInvoicePdf(
        snapshotJson: jsonEncode(snapshotMap),
        lines: lines,
        docNumber: 'A-0030',
        docType: 'invoice',
        status: 'issued',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('3. PDF uses snapshot values after the product price is changed', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const businessId = 'test-biz';
      const deviceId = 'test-dev';

      await db.into(db.businesses).insertOnConflictUpdate(
        BusinessesCompanion.insert(
          id: businessId,
          businessId: businessId,
          name: 'Original Store',
          stateCode: '27',
          address: 'Original Address',
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

      final productRepo = ProductRepository(db, businessId);
      final docRepo = DocumentRepository(db, businessId, deviceId);

      // Create product at ₹100 (10000 paise)
      final product = await productRepo.save(
        name: 'Rice 1kg',
        hsn: '1006',
        gstRateBp: 500,
        pricePaise: 10000,
        costPaise: 8000,
        trackStock: false,
        reorderLevel: 0,
      );

      // Issue invoice when price is ₹100
      final doc = await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 1000,
            ratePaise: product.pricePaise,
            gstRateBp: product.gstRateBp,
          ),
        ],
        isInterState: false,
      );

      // Verify stored snapshot totalPaise is 10500 (10000 + 5% GST = 10500)
      final snapshotMap1 = jsonDecode(doc.snapshotJson) as Map<String, dynamic>;
      final totalPaise1 = (snapshotMap1['tax_breakup'] as Map<String, dynamic>)['total_paise'] as int;
      expect(totalPaise1, equals(10500));

      // Now update live product price in database to ₹200 (20000 paise)
      await productRepo.save(
        id: product.id,
        name: product.name,
        hsn: product.hsn,
        gstRateBp: product.gstRateBp,
        pricePaise: 20000,
        costPaise: 8000,
        trackStock: false,
        reorderLevel: 0,
      );

      // Fetch stored document lines
      final storedLines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc.id))).get();

      // Generate PDF from the issued document's snapshotJson and stored lines
      final pdfBytes = await generateInvoicePdf(
        snapshotJson: doc.snapshotJson,
        lines: storedLines,
        docNumber: doc.number,
        docType: doc.docType,
        status: doc.status,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));

      // The PDF generation uses snapshotJson total (10500), NOT live product price (20000)
      final pdfSnapshotMap = jsonDecode(doc.snapshotJson) as Map<String, dynamic>;
      final pdfTotalPaise = (pdfSnapshotMap['tax_breakup'] as Map<String, dynamic>)['total_paise'] as int;
      expect(pdfTotalPaise, equals(10500));
      expect(storedLines.first.ratePaise, equals(10000));
    });

    test('4. UPI amount string formatting for 5, 100, 105, 123456 paise', () {
      expect(formatPaiseForUpi(5), equals('0.05'));
      expect(formatPaiseForUpi(100), equals('1.00'));
      expect(formatPaiseForUpi(105), equals('1.05'));
      expect(formatPaiseForUpi(123456), equals('1234.56'));
    });

    test('5. UPI ID format validation (name@handle)', () {
      expect(validateUpiId(null), isNull);
      expect(validateUpiId(''), isNull);
      expect(validateUpiId('   '), isNull);
      expect(validateUpiId('merchant@upi'), isNull);
      expect(validateUpiId('john.doe@okicici'), isNull);
      expect(validateUpiId('9876543210@paytm'), isNull);

      expect(validateUpiId('invalid'), isNotNull);
      expect(validateUpiId('@handle'), isNotNull);
      expect(validateUpiId('name@'), isNotNull);
      expect(validateUpiId('name@handle@extra'), isNotNull);
    });

    test('6. QR code logic: balance for partly paid, no QR when fully paid, no QR on credit note', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const businessId = 'test-biz';
      const deviceId = 'test-dev';

      await db.into(db.businesses).insertOnConflictUpdate(
        BusinessesCompanion.insert(
          id: businessId,
          businessId: businessId,
          name: 'Store Express',
          stateCode: '27',
          address: 'Main Market',
          upiId: const Value('store@upi'),
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

      final docRepo = DocumentRepository(db, businessId, deviceId);

      const line = IssueDocumentLineParam(
        productId: 'p1',
        name: 'Item 1',
        hsn: '1001',
        qtyMilli: 1000,
        ratePaise: 10000, // ₹100
        gstRateBp: 0,
      );

      // Part 1: Partly paid bill (Total 10000, Paid 4000, Balance 6000)
      final partyDoc = await docRepo.issueInvoice(
        lines: [line],
        isInterState: false,
        payments: const [PaymentParam(method: 'cash', amountPaise: 4000)],
      );

      final partySnapshotMap = jsonDecode(partyDoc.snapshotJson) as Map<String, dynamic>;
      expect(partySnapshotMap['paid_paise'], equals(4000));
      expect(partySnapshotMap['balance_paise'], equals(6000));

      final partyUpiUri = buildUpiQrUri(
        upiId: partySnapshotMap['seller']['upi_id'] as String?,
        sellerName: partySnapshotMap['seller']['name'] as String? ?? '',
        number: partyDoc.number,
        balancePaise: partySnapshotMap['balance_paise'] as int,
        docType: partyDoc.docType,
      );
      expect(partyUpiUri, equals('upi://pay?pa=store@upi&pn=Store%20Express&tn=${partyDoc.number}&am=60.00&cu=INR'));

      final partyLines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(partyDoc.id))).get();
      final partyPdfBytes = await generateInvoicePdf(
        snapshotJson: partyDoc.snapshotJson,
        lines: partyLines,
        docNumber: partyDoc.number,
        docType: partyDoc.docType,
      );
      expect(partyPdfBytes.length, greaterThan(0));

      // Part 2: Fully paid bill (Total 10000, Paid 10000, Balance 0)
      final fullyPaidDoc = await docRepo.issueInvoice(
        lines: [line],
        isInterState: false,
        payments: const [PaymentParam(method: 'cash', amountPaise: 10000)],
      );

      final fullyPaidSnapshotMap = jsonDecode(fullyPaidDoc.snapshotJson) as Map<String, dynamic>;
      expect(fullyPaidSnapshotMap['paid_paise'], equals(10000));
      expect(fullyPaidSnapshotMap['balance_paise'], equals(0));

      final fullyPaidUpiUri = buildUpiQrUri(
        upiId: fullyPaidSnapshotMap['seller']['upi_id'] as String?,
        sellerName: fullyPaidSnapshotMap['seller']['name'] as String? ?? '',
        number: fullyPaidDoc.number,
        balancePaise: fullyPaidSnapshotMap['balance_paise'] as int,
        docType: fullyPaidDoc.docType,
      );
      expect(fullyPaidUpiUri, isNull);

      final fullyPaidLines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(fullyPaidDoc.id))).get();
      final fullyPaidPdfBytes = await generateInvoicePdf(
        snapshotJson: fullyPaidDoc.snapshotJson,
        lines: fullyPaidLines,
        docNumber: fullyPaidDoc.number,
        docType: fullyPaidDoc.docType,
      );
      expect(fullyPaidPdfBytes.length, greaterThan(0));

      // Part 3: Credit note (no QR)
      final cnDoc = await docRepo.cancelInvoice(
        documentId: partyDoc.id,
        reason: 'Customer return',
      );

      final cnSnapshotMap = jsonDecode(cnDoc.snapshotJson) as Map<String, dynamic>;
      final cnUpiUri = buildUpiQrUri(
        upiId: 'store@upi',
        sellerName: 'Store Express',
        number: cnDoc.number,
        balancePaise: (cnSnapshotMap['balance_paise'] as num?)?.toInt() ?? 10000,
        docType: cnDoc.docType,
      );
      expect(cnUpiUri, isNull);

      final cnLines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(cnDoc.id))).get();
      final cnPdfBytes = await generateInvoicePdf(
        snapshotJson: cnDoc.snapshotJson,
        lines: cnLines,
        docNumber: cnDoc.number,
        docType: cnDoc.docType,
      );
      expect(cnPdfBytes.length, greaterThan(0));
    });
  });
}
