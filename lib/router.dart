import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/business/estimates_page.dart';
import 'features/business/item_details_page.dart';
import 'features/business/reminders_page.dart';
import 'features/business/staff_page.dart';
import 'features/business/expenses_page.dart';
import 'features/business/new_purchase_page.dart';
import 'features/business/suppliers_page.dart';
import 'features/items/items_page.dart';
import 'features/more/backup_sync_page.dart';
import 'features/more/invoice_design_page.dart';
import 'features/more/more_page.dart';
import 'features/parties/parties_page.dart';
import 'features/reports/gst_summary_page.dart';
import 'features/reports/reports_page.dart';
import 'features/sell/done_page.dart';
import 'features/sell/new_bill_page.dart';
import 'features/sell/sell_page.dart';
import 'features/update/update_dialog.dart';
import 'core/widgets/motion.dart';
import 'l10n/app_localizations.dart';

import 'features/parties/party_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/sell',
  redirect: (context, state) {
    final loc = state.uri.toString();
    // Google/OAuth deep link (io.supabase.belling://login-callback/?code=...):
    // supabase_flutter consumes it by itself, the router must just stay on the app.
    if (loc.startsWith('io.supabase.belling') || state.uri.host == 'login-callback') {
      return '/sell';
    }
    if (state.uri.path == '/' || state.uri.path.isEmpty) return '/sell';
    return null;
  },
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
                GoRoute(
                  path: 'suppliers',
                  builder: (context, state) => const SuppliersPage(),
                ),
                GoRoute(
                  path: 'purchase/new',
                  builder: (context, state) => const NewPurchasePage(),
                ),
                GoRoute(
                  path: 'staff',
                  builder: (context, state) => const StaffPage(),
                ),
                GoRoute(
                  path: 'item-details',
                  builder: (context, state) => const ItemDetailsPage(),
                ),
                GoRoute(
                  path: 'reminders',
                  builder: (context, state) => const RemindersPage(),
                ),
                GoRoute(
                  path: 'estimates',
                  builder: (context, state) => const EstimatesPage(),
                ),
                GoRoute(
                  path: 'expenses',
                  builder: (context, state) => const ExpensesPage(),
                ),
                GoRoute(
                  path: 'invoice-design',
                  builder: (context, state) => const InvoiceDesignPage(),
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
      body: UpdateChecker(
        child: TabFadeIn(index: navigationShell.currentIndex, child: navigationShell),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        animationDuration: const Duration(milliseconds: 400),
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale_outlined),
            selectedIcon: const Icon(Icons.point_of_sale),
            label: l10n.tabSell,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.tabItems,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.tabParties,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.tabReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.tabMore,
          ),
        ],
      ),
    );
  }
}
