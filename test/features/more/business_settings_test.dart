import 'package:belling/data/database.dart';
import 'package:belling/data/providers.dart';
import 'package:belling/features/more/more_page.dart';
import 'package:belling/l10n/app_localizations.dart';
import 'package:belling/sync/sync_providers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Task 10: Business Settings & Bootstrap Tests', () {
    test('1. Brand new in-memory database already has business and device row', () async {
      // Query businesses
      final businesses = await db.select(db.businesses).get();
      expect(businesses.length, equals(1));
      expect(businesses.first.id, equals('local-business'));
      expect(businesses.first.name, equals('My Business'));
      expect(businesses.first.stateCode, equals('24'));

      // Query devices
      final devices = await db.select(db.devices).get();
      expect(devices.length, equals(1));
      expect(devices.first.id, equals('local-device'));
      expect(devices.first.seriesPrefix, equals('A'));
    });

    test('2. Saving settings on a database whose businesses table is empty works', () async {
      // Empty businesses table
      await db.delete(db.businesses).go();
      final countBefore = (await db.select(db.businesses).get()).length;
      expect(countBefore, equals(0));

      // Save settings via upsertBusinessSettings
      final updated = await db.upsertBusinessSettings(
        businessId: 'local-business',
        deviceId: 'local-device',
        name: 'Empty Table Store',
        gstin: '24ABCDE1234F1Z5',
        stateCode: '24',
        address: '456 New Road',
      );

      expect(updated.name, equals('Empty Table Store'));
      expect(updated.stateCode, equals('24'));
      expect(updated.address, equals('456 New Road'));

      // Check businesses table has 1 row now
      final businesses = await db.select(db.businesses).get();
      expect(businesses.length, equals(1));
      expect(businesses.first.name, equals('Empty Table Store'));

      // Check outbox command enqueued
      final outbox = await db.select(db.outboxCommands).get();
      expect(outbox.length, equals(1));
      expect(outbox.first.commandType, equals('upsert_business'));
    });

    testWidgets('3. Validation for State and GSTIN state prefix mismatch', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            connectivityStreamProvider.overrideWith((ref) => Stream.value([ConnectivityResult.wifi])),
            currentBusinessStreamProvider.overrideWith((ref) => Stream.value(
                  Business(
                    id: 'local-business',
                    businessId: 'local-business',
                    name: 'My Business',
                    stateCode: '24',
                    address: 'Main Store',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                )),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: MorePage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final saveButton = find.text('Save Business Settings');
      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Business settings saved'), findsOneWidget);

      // Enter invalid GSTIN prefix (27 for state 24)
      final gstinFinder = find.widgetWithText(TextFormField, 'GSTIN (Optional)');
      await tester.enterText(gstinFinder, '27ABCDE1234F1Z5');

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('GSTIN state code must match selected state'), findsOneWidget);

      // Enter short GSTIN
      await tester.enterText(gstinFinder, '24ABC');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('GSTIN must be 15 characters'), findsOneWidget);

      // Correct GSTIN
      await tester.enterText(gstinFinder, '24ABCDE1234F1Z5');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Business settings saved'), findsOneWidget);

      // Unmount inside the test so drift's stream-cleanup timer runs before
      // the test ends (otherwise: "A Timer is still pending").
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  });
}
