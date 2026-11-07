import 'package:belling/data/database.dart';
import 'package:belling/data/providers.dart';
import 'package:belling/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash shows first, then the app with navigation tabs', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          appReadyProvider.overrideWith((ref) async {}),
        ],
        child: const UniversalBillingApp(),
      ),
    );
    await tester.pump();

    // Splash is visible straight away (no black/blank frame)
    expect(find.text('Universal Billing'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Sell'), findsWidgets);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Parties'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
