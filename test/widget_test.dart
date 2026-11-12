import 'package:belling/core/widgets/belling_ui.dart';
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
    expect(find.text('Belling'), findsOneWidget);
    expect(find.byType(PillNavBar), findsNothing);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(PillNavBar), findsOneWidget);
    // selected tab shows its label; others are icon-only (with semantics labels)
    expect(find.text('Sell'), findsWidgets);
    expect(find.bySemanticsLabel('Items'), findsOneWidget);
    expect(find.bySemanticsLabel('Parties'), findsOneWidget);
    expect(find.bySemanticsLabel('Reports'), findsOneWidget);
    expect(find.bySemanticsLabel('More'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
