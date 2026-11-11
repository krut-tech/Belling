import 'dart:convert';

import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/sync_chip.dart';
import '../../core/tr_text.dart';

String? _customerName(String snapshotJson) {
  if (!snapshotJson.contains('customer_name')) return null;
  try {
    final m = jsonDecode(snapshotJson);
    final n = m is Map ? m['customer_name'] : null;
    return n is String && n.isNotEmpty ? n : null;
  } catch (_) {
    return null;
  }
}

class SellPage extends ConsumerWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final todayDocsAsync = ref.watch(todayDocumentsStreamProvider);
    const tabularStyle = TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    final businessName = ref.watch(activeBusinessProvider).valueOrNull?.name;
    final docs = todayDocsAsync.valueOrNull ?? const [];
    var salesPaise = 0;
    var billCount = 0;
    for (final d in docs) {
      if (d.document.status == 'cancelled') continue;
      if (d.document.docType == 'invoice') {
        salesPaise += d.document.totalPaise;
        billCount++;
      } else if (d.document.docType == 'credit_note') {
        salesPaise -= d.document.totalPaise;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          // Haldi header: saffron-to-crimson gradient with today's sales card.
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.saffron, AppColors.crimson, AppColors.wine],
                stops: [0, 0.7, 1],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (businessName == null || businessName.isEmpty) ? l10n.tabSell : businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const SyncChip(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Color(0x38000000), blurRadius: 24, offset: Offset(0, 12))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.todayBills,
                              style: const TextStyle(fontSize: 13, color: AppColors.lightMuted, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRupees(salesPaise),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.ink,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$billCount',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  context.go('/sell/new');
                },
                icon: const Icon(Icons.add_shopping_cart, size: 26),
                label: Text(
                  l10n.newBill,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                        backgroundColor: isCancelled ? Colors.red.shade100 : AppColors.softSaffron,
                        child: Icon(
                          isCancelled ? Icons.cancel : Icons.receipt,
                          color: isCancelled ? Colors.red : AppColors.lightPrimary,
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
                        '${party?.name ?? _customerName(doc.snapshotJson) ?? l10n.walkIn} • $timeStr',
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
