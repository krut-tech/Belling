import 'package:belling/data/providers.dart';
import 'package:belling/features/items/items_page.dart';
import 'package:belling/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ItemsPage renders empty state when no items exist', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsStreamProvider('').overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ItemsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state elements
    expect(find.text('No items found'), findsOneWidget);
    expect(find.text("Tap '+' to add your first item."), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
