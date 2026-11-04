import 'package:belling/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads and displays bottom navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UniversalBillingApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Sell'), findsWidgets);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Parties'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}
