import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/items/items_page.dart';
import 'features/more/backup_sync_page.dart';
import 'features/more/more_page.dart';
import 'features/parties/parties_page.dart';
import 'features/reports/gst_summary_page.dart';
import 'features/reports/reports_page.dart';
import 'features/sell/done_page.dart';
import 'features/sell/new_bill_page.dart';
import 'features/sell/sell_page.dart';
import 'l10n/app_localizations.dart';

import 'features/parties/party_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/sell',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sell',
              builder: (context, state) => const SellPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const NewBillPage(),
                ),
                GoRoute(
                  path: 'done/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return DonePage(documentId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/items',
              builder: (context, state) => const ItemsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/parties',
              builder: (context, state) => const PartiesPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return PartyDetailPage(partyId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsPage(),
              routes: [
                GoRoute(
                  path: 'gst-summary',
                  builder: (context, state) => const GstSummaryPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MorePage(),
              routes: [
                GoRoute(
                  path: 'backup-sync',
                  builder: (context, state) => const BackupAndSyncPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.point_of_sale),
            label: l10n.tabSell,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: l10n.tabItems,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.tabParties,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.tabReports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: l10n.tabMore,
          ),
        ],
      ),
    );
  }
}
