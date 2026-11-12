import 'package:belling/data/database.dart';
import 'package:belling/data/providers.dart';
import 'package:belling/data/repositories/document_repository.dart';
import 'package:belling/data/repositories/party_repository.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:belling/features/sell/new_bill_notifier.dart';
import 'package:belling/features/sell/new_bill_page.dart';
import 'package:belling/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late AppDatabase db;
  late PartyRepository partyRepo;
  late DocumentRepository docRepo;
  late ProductRepository productRepo;

  const businessId = 'test-business';
  const deviceId = 'test-device';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());

    await db.into(db.businesses).insertOnConflictUpdate(BusinessesCompanion.insert(
          id: businessId,
          businessId: businessId,
          name: 'Test Store',
          stateCode: '27',
          address: 'Main Street',
          upiId: const Value('test@upi'),
          createdAt: DateTime.now(),
        ));

    await db.into(db.devices).insertOnConflictUpdate(DevicesCompanion.insert(
          id: deviceId,
          businessId: businessId,
          name: 'POS 1',
          seriesPrefix: 'A',
          createdAt: DateTime.now(),
        ));

    partyRepo = PartyRepository(db, businessId);
    docRepo = DocumentRepository(db, businessId, deviceId);
    productRepo = ProductRepository(db, businessId);
  });

  tearDown(() async {
    await db.close();
  });

  group('Task 6: Party & Customer Ledger Tests', () {
    test('1. Balance after invoice', () async {
      final party = await partyRepo.save(
        name: 'Rahul Kumar',
        phone: '9876543210',
        stateCode: '27',
      );

      final balance0 = await partyRepo.getPartyBalancePaise(party.id);
      expect(balance0, equals(0));

      final product = await productRepo.save(
        name: 'Item 1',
        hsn: '1234',
        pricePaise: 100000, // ₹1,000
        costPaise: 50000,
        gstRateBp: 0,
        trackStock: false,
        reorderLevel: 0,
      );

      await docRepo.issueInvoice(
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
        partyId: party.id,
        isInterState: false,
        payments: [], // Unpaid invoice
      );

      final balance1 = await partyRepo.getPartyBalancePaise(party.id);
      expect(balance1, equals(100000)); // Customer owes ₹1,000
    });

    test('2. Partial payment', () async {
      final party = await partyRepo.save(
        name: 'Suresh Patel',
        phone: '9876500000',
        stateCode: '27',
      );

      final product = await productRepo.save(
        name: 'Item 2',
        hsn: '1234',
        pricePaise: 100000, // ₹1,000
        costPaise: 50000,
        gstRateBp: 0,
        trackStock: false,
        reorderLevel: 0,
      );

      // Issue invoice ₹1,000 with partial payment ₹400
      await docRepo.issueInvoice(
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
        partyId: party.id,
        isInterState: false,
        payments: [
          const PaymentParam(method: 'cash', amountPaise: 40000), // Paid ₹400
        ],
      );

      final balance1 = await partyRepo.getPartyBalancePaise(party.id);
      expect(balance1, equals(60000)); // Outstanding ₹600

      // Add separate payment of ₹200
      await partyRepo.addPayment(
        partyId: party.id,
        amountPaise: 20000,
        method: 'upi',
      );

      final balance2 = await partyRepo.getPartyBalancePaise(party.id);
      expect(balance2, equals(40000)); // Outstanding ₹400
    });

    test('3. Credit note cancels invoice balance', () async {
      final party = await partyRepo.save(
        name: 'Anita Verma',
        phone: '9876511111',
        stateCode: '27',
      );

      final product = await productRepo.save(
        name: 'Item 3',
        hsn: '1234',
        pricePaise: 50000, // ₹500
        costPaise: 20000,
        gstRateBp: 0,
        trackStock: false,
        reorderLevel: 0,
      );

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
        partyId: party.id,
        isInterState: false,
      );

      final balanceBefore = await partyRepo.getPartyBalancePaise(party.id);
      expect(balanceBefore, equals(50000));

      // Cancel invoice creates credit note
      await docRepo.cancelInvoice(documentId: doc.id, reason: 'Returned');

      final balanceAfter = await partyRepo.getPartyBalancePaise(party.id);
      expect(balanceAfter, equals(0));
    });

    test('4. Advance payment creates negative balance (You give)', () async {
      final party = await partyRepo.save(
        name: 'Vikram Singh',
        phone: '9876522222',
        stateCode: '27',
      );

      // Add payment of ₹500 advance
      await partyRepo.addPayment(
        partyId: party.id,
        amountPaise: 50000,
        method: 'cash',
        note: 'Advance deposit',
      );

      final balance = await partyRepo.getPartyBalancePaise(party.id);
      expect(balance, equals(-50000)); // Negative balance = You give ₹500
    });

    test('5. Ledger running balance order (newest first)', () async {
      final party = await partyRepo.save(
        name: 'Amit Shah',
        phone: '9876533333',
        stateCode: '27',
      );

      final product = await productRepo.save(
        name: 'Widget',
        hsn: '1234',
        pricePaise: 100,
        costPaise: 50,
        gstRateBp: 0,
        trackStock: false,
        reorderLevel: 0,
      );

      final t1 = DateTime(2025, 1, 1, 10, 0);
      final t2 = DateTime(2025, 1, 2, 10, 0);
      final t3 = DateTime(2025, 1, 3, 10, 0);
      final t4 = DateTime(2025, 1, 4, 10, 0);

      // Day 1: Invoice ₹100
      await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 100000, // 100 units = ₹100
            ratePaise: 100,
            gstRateBp: 0,
          ),
        ],
        partyId: party.id,
        isInterState: false,
        issuedAt: t1,
      );

      // Day 2: Payment ₹40
      await partyRepo.addPayment(
        partyId: party.id,
        amountPaise: 4000,
        method: 'cash',
        paidAt: t2,
      );

      // Day 3: Invoice ₹50
      await docRepo.issueInvoice(
        lines: [
          IssueDocumentLineParam(
            productId: product.id,
            name: product.name,
            hsn: product.hsn,
            qtyMilli: 50000, // 50 units = ₹50
            ratePaise: 100,
            gstRateBp: 0,
          ),
        ],
        partyId: party.id,
        isInterState: false,
        issuedAt: t3,
      );

      // Day 4: Payment ₹110
      await partyRepo.addPayment(
        partyId: party.id,
        amountPaise: 11000,
        method: 'upi',
        paidAt: t4,
      );

      final ledger = await partyRepo.watchPartyLedger(party.id).first;

      expect(ledger.length, equals(4));

      // Order should be newest first (Day 4, Day 3, Day 2, Day 1)
      expect(ledger[0].date, equals(t4));
      expect(ledger[0].runningBalancePaise, equals(0));

      expect(ledger[1].date, equals(t3));
      expect(ledger[1].runningBalancePaise, equals(11000));

      expect(ledger[2].date, equals(t2));
      expect(ledger[2].runningBalancePaise, equals(6000));

      expect(ledger[3].date, equals(t1));
      expect(ledger[3].runningBalancePaise, equals(10000));
    });

    test('6. Credit limit warning check logic', () async {
      final party = await partyRepo.save(
        name: 'Limit Party',
        phone: '9999999999',
        stateCode: '27',
        creditLimitPaise: 10000, // Credit limit ₹100
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          currentBusinessIdProvider.overrideWithValue(businessId),
          currentDeviceIdProvider.overrideWithValue(deviceId),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(newBillProvider.notifier);
      notifier.setParty(party);
      notifier.setPaymentMethod('credit'); // Credit sale

      // Current balance = 0, Limit = 10000 (₹100)
      final product = await productRepo.save(
        name: 'Item X',
        hsn: '1234',
        pricePaise: 15000, // ₹150
        costPaise: 5000,
        gstRateBp: 0,
        trackStock: false,
        reorderLevel: 0,
      );

      final pws = ProductWithStock(product: product, stockMilli: 100);
      notifier.addProduct(pws);

      // Cart total = ₹150 > limit ₹100
      final isExceeded = await notifier.checkCreditLimitExceeded();
      expect(isExceeded, isTrue);

      // Reduce line quantity to make cart total = ₹50 <= limit ₹100
      notifier.updateLineQty(0, 333); // ~ ₹50
      final isExceededAfterReduction = await notifier.checkCreditLimitExceeded();
      expect(isExceededAfterReduction, isFalse);
    });

    testWidgets('7. Credit limit warning UI dialog on New bill screen', (tester) async {
      final party = await partyRepo.save(
        name: 'Credit Test Party',
        phone: '9876543210',
        stateCode: '27',
        creditLimitPaise: 5000, // ₹50 limit
      );

      final product = await productRepo.save(
        name: 'Expensive Item',
        hsn: '1234',
        pricePaise: 10000, // ₹100
        costPaise: 5000,
        gstRateBp: 0,
        trackStock: false,
        reorderLevel: 0,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          currentBusinessIdProvider.overrideWithValue(businessId),
          currentDeviceIdProvider.overrideWithValue(deviceId),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/sell/new',
        routes: [
          GoRoute(
            path: '/sell/new',
            builder: (context, state) => const NewBillPage(),
          ),
          GoRoute(
            path: '/sell/done/:id',
            builder: (context, state) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('gu'),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add product & party & payment method credit
      final notifier = container.read(newBillProvider.notifier);
      notifier.setParty(party);
      notifier.setPaymentMethod('credit');
      notifier.addProduct(ProductWithStock(product: product, stockMilli: 100));

      await tester.pumpAndSettle();

      // Items are picked first; open the bill to see the Issue button.
      await tester.tap(find.text('Review bill'));
      await tester.pumpAndSettle();

      // Tap "Issue Invoice" button
      final issueButton = find.text('Issue Invoice');
      expect(issueButton, findsOneWidget);
      await tester.tap(issueButton);
      await tester.pumpAndSettle();

      // Dialog "Credit Limit Exceeded" should appear
      expect(find.text('Credit Limit Exceeded'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Proceed Anyway'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify invoice was NOT issued (cart still contains line)
      expect(container.read(newBillProvider).lines.length, equals(1));

      // Tap "Issue Invoice" again
      await tester.tap(issueButton);
      await tester.pumpAndSettle();

      // Tap "Proceed Anyway"
      await tester.tap(find.text('Proceed Anyway'));
      await tester.pumpAndSettle();

      // Verify invoice WAS issued (cart cleared)
      expect(container.read(newBillProvider).lines, isEmpty);
    });
  });
}
