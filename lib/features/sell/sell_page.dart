import 'dart:convert';

import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../data/repositories/document_repository.dart';
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

    final split = ref.watch(todayPaymentSplitProvider).valueOrNull ?? const <String, int>{};
    final yesterday = ref.watch(yesterdaySalesProvider).valueOrNull ?? 0;
    final receivedPaise = split.values.fold<int>(0, (a, b) => a + b);
    final udharPaise = salesPaise > receivedPaise ? salesPaise - receivedPaise : 0;
    final changePct = yesterday > 0 ? ((salesPaise - yesterday) * 100 / yesterday).round() : null;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => context.go('/sell/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newBill, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: (businessName == null || businessName.isEmpty) ? l10n.tabSell : businessName,
              actions: const [SyncChip()],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  HeroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.todayBills,
                                style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (changePct != null)
                              StatusBadge(
                                '${changePct >= 0 ? '▲' : '▼'} ${changePct.abs()}% kal se',
                                color: changePct >= 0 ? AppColors.lightSuccess : AppColors.lightDanger,
                                background: changePct >= 0 ? AppColors.goodBg : AppColors.dueBg,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatRupees(salesPaise),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0x26FFFFFF)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _heroStat('Bills', '$billCount'),
                            _heroStat('Mila (cash+UPI)', formatRupees(receivedPaise)),
                            _heroStat('Udhar', formatRupees(udharPaise)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickAction(
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.accent,
                        background: AppColors.accentBg,
                        label: l10n.newBill,
                        onTap: () => context.go('/sell/new'),
                      ),
                      _QuickAction(
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.violet,
                        background: AppColors.violetBg,
                        label: 'Purchase',
                        onTap: () => context.push('/more/purchase/new'),
                      ),
                      _QuickAction(
                        icon: Icons.description_outlined,
                        color: AppColors.warn,
                        background: AppColors.warnBg,
                        label: 'Estimate',
                        onTap: () => context.push('/more/estimates'),
                      ),
                      _QuickAction(
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.lightSuccess,
                        background: AppColors.goodBg,
                        label: 'Expenses',
                        onTap: () => context.push('/more/expenses'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.todayBills,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        todayDocsAsync.when(
                          data: (docs) {
                            if (docs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 28),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.noBillsToday,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (var index = 0; index < docs.length; index++)
                                  _billRow(context, l10n, docs[index], index, tabularStyle),
                              ],
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, st) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Center(child: Text('Error: $e')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _billRow(
    BuildContext context,
    AppLocalizations l10n,
    DocumentWithParty item,
    int index,
    TextStyle tabularStyle,
  ) {
    final doc = item.document;
    final party = item.party;
    final timeStr = DateFormat('hh:mm a').format(doc.issuedAt);
    final isCancelled = doc.status == 'cancelled';
    final nameOrNull = party?.name ?? _customerName(doc.snapshotJson);
    final displayName = nameOrNull ?? doc.number;

    return FadeSlideIn(
      index: index,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('/sell/done/${doc.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              MonoTile(
                initialsOf(displayName),
                color: isCancelled ? AppColors.lightDanger : tileColorFor(displayName),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${nameOrNull != null ? doc.number : l10n.walkIn} • $timeStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupees(doc.totalPaise),
                    style: tabularStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                      color: isCancelled ? Colors.grey : AppColors.lightText,
                    ),
                  ),
                  if (isCancelled) ...[
                    const SizedBox(height: 4),
                    StatusBadge.due(l10n.statusCancelled),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            IconTile(icon: icon, color: color, background: background, size: 56),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
