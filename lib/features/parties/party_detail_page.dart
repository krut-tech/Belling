import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/party_repository.dart';
import '../../l10n/app_localizations.dart';
import 'dues_reminder_sheet.dart';
import 'party_form_dialog.dart';
import 'receive_payment_dialog.dart';
import '../../core/tr_text.dart';

class PartyDetailPage extends ConsumerWidget {
  final String partyId;

  const PartyDetailPage({super.key, required this.partyId});

  void _sendReminder({
    required BuildContext context,
    required Party party,
    required int balancePaise,
    required Business? business,
  }) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final shopName = business?.name ?? 'Store';
    final upiId = business?.upiId;
    final formattedBalance = formatRupees(balancePaise);

    String text;
    if (localeCode == 'hi') {
      text = 'नमस्ते ${party.name}, $shopName पर आपका बकाया $formattedBalance है।';
      if (upiId != null && upiId.trim().isNotEmpty) {
        text += ' UPI: ${upiId.trim()}';
      }
    } else if (localeCode == 'gu') {
      text = 'નમસ્તે ${party.name}, $shopName ખાતે તમારું બાકી $formattedBalance છે.';
      if (upiId != null && upiId.trim().isNotEmpty) {
        text += ' UPI: ${upiId.trim()}';
      }
    } else {
      text = 'Namaste ${party.name}, your balance at $shopName is $formattedBalance.';
      if (upiId != null && upiId.trim().isNotEmpty) {
        text += ' UPI: ${upiId.trim()}';
      }
    }

    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final partyAsync = ref.watch(partyStreamProvider(partyId));
    final balanceAsync = ref.watch(partyBalanceStreamProvider(partyId));
    final ledgerAsync = ref.watch(partyLedgerStreamProvider(partyId));
    final businessAsync = ref.watch(currentBusinessStreamProvider);
    final billById = ref.watch(billsOverviewProvider).valueOrNull?.byId ?? const <String, BillRow>{};

    return partyAsync.when(
      data: (party) {
        if (party == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.partyDetails)),
            body: const Center(child: Text('Party not found')),
          );
        }

        final balancePaise = balanceAsync.asData?.value ?? 0;
        final business = businessAsync.asData?.value;

        return Scaffold(
          appBar: AppBar(
            title: Text(party.name),
            actions: [
              IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.edit),
                tooltip: l10n.editParty,
                onPressed: () => PartyFormDialog.show(context, party: party),
              ),
            ],
          ),
          body: Column(
            children: [
              // Header Card
              Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  party.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.phone}: ${party.phone}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (party.gstin != null && party.gstin!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l10n.gstin}: ${party.gstin}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                                if (party.creditLimitPaise > 0) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l10n.creditLimit}: ${formatRupees(party.creditLimitPaise)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.balance,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              _buildBalanceBadge(context, l10n, balancePaise),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              onPressed: () async {
                                await ReceivePaymentDialog.show(context, party: party);
                              },
                              icon: const Icon(Icons.add_card),
                              label: Text(l10n.receivePayment),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(48, 48),
                              ),
                              onPressed: () {
                                if (balancePaise > 0) {
                                  showDuesReminderSheet(context, partyId: party.id);
                                } else {
                                  _sendReminder(
                                    context: context,
                                    party: party,
                                    balancePaise: balancePaise,
                                    business: business,
                                  );
                                }
                              },
                              icon: const Icon(Icons.share),
                              label: Text(l10n.sendReminder),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Ledger Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.ledger,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // Ledger List
              Expanded(
                child: ledgerAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noTransactions,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return FadeSlideIn(index: index, child: _buildLedgerTile(context, l10n, item, billById[item.documentId]));
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.partyDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: Text(l10n.partyDetails)),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBalanceBadge(BuildContext context, AppLocalizations l10n, int balancePaise) {
    if (balancePaise > 0) {
      return Text(
        l10n.youGet(formatRupees(balancePaise)),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
      );
    } else if (balancePaise < 0) {
      return Text(
        l10n.youGive(formatRupees(balancePaise.abs())),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
      );
    } else {
      return Text(
        l10n.settled,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
      );
    }
  }

  Widget _buildLedgerTile(BuildContext context, AppLocalizations l10n, LedgerItem item, BillRow? bill) {
    IconData icon;
    Color iconColor;
    String sign;
    Color amountColor;

    switch (item.type) {
      case LedgerItemType.invoice:
        icon = Icons.receipt_long;
        iconColor = Colors.orange.shade700;
        sign = '+';
        amountColor = Colors.red.shade700;
        break;
      case LedgerItemType.creditNote:
        icon = Icons.assignment_return;
        iconColor = Colors.purple.shade700;
        sign = '-';
        amountColor = Colors.green.shade700;
        break;
      case LedgerItemType.payment:
        icon = Icons.payments;
        iconColor = Colors.green.shade700;
        sign = '-';
        amountColor = Colors.green.shade700;
        break;
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.date);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      leading: CircleAvatar(
        backgroundColor: iconColor.withAlpha(30),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr, style: const TextStyle(fontSize: 12)),
          if (item.type == LedgerItemType.invoice && bill?.settlement != null)
            Text(
              bill!.status == 'cancelled'
                  ? 'Cancelled'
                  : (bill.settlement!.duePaise > 0
                      ? 'Paid ${formatRupees(bill.settlement!.paidPaise)} · Baaki ${formatRupees(bill.settlement!.duePaise)}'
                      : 'Paid in full'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: (bill.settlement!.duePaise > 0 && bill.status != 'cancelled')
                    ? Colors.red.shade700
                    : Colors.green.shade700,
              ),
            ),
          if (item.note != null && item.note!.isNotEmpty)
            Text(
              '${l10n.note}: ${item.note}',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign ${formatRupees(item.amountPaise)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.runningBalance(formatRupees(item.runningBalancePaise)),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
