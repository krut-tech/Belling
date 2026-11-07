import 'dart:convert';

import 'package:belling/core/invoice_pdf.dart';
import 'package:belling/core/invoice_style.dart';
import 'package:belling/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

DocumentLine _line() => DocumentLine(
      id: 'l1',
      documentId: 'd1',
      businessId: 'b',
      productId: 'p',
      name: 'Atta 5kg',
      hsn: '1101',
      qtyMilli: 1000,
      ratePaise: 10000,
      discountPaise: 0,
      gstRateBp: 500,
      taxablePaise: 10000,
      cgstPaise: 250,
      sgstPaise: 250,
      igstPaise: 0,
      lineTotalPaise: 10500,
      createdAt: DateTime(2026),
    );

String _snapshot() => jsonEncode({
      'seller': {'name': 'Shop', 'gstin': '24ABCDE1234F1Z5', 'state_code': '24', 'address': 'Road', 'upi_id': 'a@upi'},
      'buyer': null,
      'tax_breakup': {
        'taxable_paise': 10000,
        'cgst_paise': 250,
        'sgst_paise': 250,
        'igst_paise': 0,
        'round_off_paise': 0,
        'total_paise': 10500,
      },
      'paid_paise': 0,
      'balance_paise': 10500,
      'number': 'A-0001',
      'doc_type': 'invoice',
      'issued_at': '2026-11-07T10:00:00.000',
    });

bool _isPdf(List<int> b) => b.length > 4 && String.fromCharCodes(b.sublist(0, 4)) == '%PDF';

void main() {
  group('InvoiceStyle', () {
    test('map round trip keeps every field', () {
      const s = InvoiceStyle(
        paper: InvoicePaper.thermal80,
        layout: InvoiceLayout.receipt,
        marginTopMm: 2,
        accentColor: 0x0F766E,
        fontScale: 1.2,
        showQr: false,
        showHsn: false,
        logoPath: '/x/logo.png',
        backgroundPath: '/x/bg.png',
        backgroundFit: BackgroundFit.contain,
      );
      final back = InvoiceStyle.fromMap(jsonDecode(jsonEncode(s.toMap())) as Map<String, dynamic>);
      expect(back.toMap(), s.toMap());
    });

    test('damaged values fall back to safe defaults', () {
      final s = InvoiceStyle.fromMap({
        'paper': 'nonsense',
        'fontScale': 99,
        'marginTopMm': -5,
        'customWidthMm': 'x',
        'showQr': 'yes',
      });
      expect(s.paper, InvoicePaper.auto);
      expect(s.fontScale, 1.5);
      expect(s.marginTopMm, 0);
      expect(s.customWidthMm, 210);
      expect(s.showQr, isTrue);
    });

    test('auto layout follows paper width', () {
      const s = InvoiceStyle();
      expect(s.effectiveLayout(PdfPageFormat.a4), InvoiceLayout.classic);
      expect(s.effectiveLayout(PdfPageFormat.a5), InvoiceLayout.compact);
      expect(s.effectiveLayout(const PdfPageFormat(80 * PdfPageFormat.mm, 200 * PdfPageFormat.mm)),
          InvoiceLayout.receipt);
    });

    test('auto paper uses the print dialog paper, A4 without a dialog', () {
      const s = InvoiceStyle();
      expect(s.pageFormat().width, PdfPageFormat.a4.width);
      expect(s.pageFormat().height, PdfPageFormat.a4.height);
      expect(s.pageFormat(dialogFormat: PdfPageFormat.a5).width, PdfPageFormat.a5.width);
    });

    test('thermal margins are capped so the roll is not wasted', () {
      const s = InvoiceStyle(marginLeftMm: 20);
      final m = s.margins(const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity));
      expect(m.left, 3 * PdfPageFormat.mm);
    });

    test('store saves and loads', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect((await InvoiceStyleStore.load(db)).paper, InvoicePaper.auto);
      await InvoiceStyleStore.save(db, const InvoiceStyle(paper: InvoicePaper.a5, accentColor: 0xB91C1C));
      final loaded = await InvoiceStyleStore.load(db);
      expect(loaded.paper, InvoicePaper.a5);
      expect(loaded.accentColor, 0xB91C1C);
    });
  });

  group('generateInvoicePdf with styles', () {
    final cases = <String, InvoiceStyle>{
      'default': const InvoiceStyle(),
      'a5 compact': const InvoiceStyle(paper: InvoicePaper.a5),
      'letter': const InvoiceStyle(paper: InvoicePaper.letter, accentColor: 0xB91C1C),
      'custom size': const InvoiceStyle(paper: InvoicePaper.custom, customWidthMm: 120, customHeightMm: 180),
      'thermal 80': const InvoiceStyle(paper: InvoicePaper.thermal80),
      'thermal 58': const InvoiceStyle(paper: InvoicePaper.thermal58),
      'no extras': const InvoiceStyle(showHsn: false, showQr: false, showTerms: false, showSignature: false),
      'big text': const InvoiceStyle(fontScale: 1.5),
    };
    cases.forEach((name, style) {
      test('$name produces a PDF', () async {
        final bytes = await generateInvoicePdf(
          snapshotJson: _snapshot(),
          lines: [_line()],
          style: style,
        );
        expect(_isPdf(bytes), isTrue);
      });
    });

    test('auto paper follows the dialog paper (narrow -> receipt)', () async {
      final bytes = await generateInvoicePdf(
        snapshotJson: _snapshot(),
        lines: [_line()],
        dialogFormat: const PdfPageFormat(80 * PdfPageFormat.mm, 200 * PdfPageFormat.mm),
      );
      expect(_isPdf(bytes), isTrue);
    });

    test('unreadable logo/background bytes do not crash printing', () async {
      final bytes = await generateInvoicePdf(
        snapshotJson: _snapshot(),
        lines: [_line()],
        style: const InvoiceStyle(),
        assets: InvoiceAssets(logo: null, background: null),
      );
      expect(_isPdf(bytes), isTrue);
    });
  });
}
