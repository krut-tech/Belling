import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/sync_chip.dart';

class SellPage extends ConsumerWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final todayDocsAsync = ref.watch(todayDocumentsStreamProvider);
    const tabularStyle = TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSell),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SyncChip(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.go('/sell/new');
                },
                icon: const Icon(Icons.add_shopping_cart, size: 28),
                label: Text(
                  l10n.newBill,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.todayBills,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          Expanded(
            child: todayDocsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noBillsToday,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final item = docs[index];
                    final doc = item.document;
                    final party = item.party;
                    final timeStr = DateFormat('hh:mm a').format(doc.issuedAt);
                    final isCancelled = doc.status == 'cancelled';

                    return FadeSlideIn(index: index, child: ListTile(
                      minVerticalPadding: 12,
                      leading: CircleAvatar(
                        backgroundColor: isCancelled ? Colors.red.shade100 : Colors.blue.shade100,
                        child: Icon(
                          isCancelled ? Icons.cancel : Icons.receipt,
                          color: isCancelled ? Colors.red : Colors.blue.shade900,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            doc.number,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isCancelled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (isCancelled) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.statusCancelled,
                                style: TextStyle(fontSize: 10, color: Colors.red.shade900),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${party?.name ?? l10n.walkIn} • $timeStr',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      trailing: Text(
                        formatRupees(doc.totalPaise),
                        style: Theme.of(context).textTheme.titleMedium?.merge(tabularStyle).copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCancelled ? TextDecoration.lineThrough : null,
                              color: isCancelled ? Colors.grey : null,
                            ),
                      ),
                      onTap: () {
                        context.go('/sell/done/${doc.id}');
                      },
                    ));
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
