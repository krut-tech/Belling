import 'dart:io';
import 'package:flutter/material.dart' hide Text;
import 'package:path_provider/path_provider.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/invoice_style.dart';
import '../../core/money.dart';
import '../../core/statement_pdf.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
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

  Future<void> _shareStatement(
    BuildContext context,
    WidgetRef ref,
    Party party,
    Business? business,
    List<LedgerItem> items,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(databaseProvider);
      final style = await InvoiceStyleStore.load(db);
      final assets = await InvoiceStyleStore.loadAssets(style);
      final bytes = await generateStatementPdf(
        partyName: party.name,
        partyPhone: party.phone,
        partyGstin: party.gstin,
        shopName: business?.name ?? 'Store',
        shopGstin: business?.gstin,
        shopAddress: business?.address,
        items: items,
        style: style,
        assets: assets,
      );
      final dir = await getTemporaryDirectory();
      final safe = party.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      final file = File('${dir.path}/Statement_$safe.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: 'Statement_$safe.pdf')],
        text: '${business?.name ?? 'Store'} - account statement for ${party.name}',
        subject: 'Account statement',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('PDF nahi ban paya: $e')));
    }
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
          body: SafeArea(
            child: Column(
              children: [
                BellingHeader(
                  title: party.name,
                  subtitle: party.phone,
                  showBack: true,
                  actions: [
                    SoftIconButton(
                      icon: Icons.picture_as_pdf_outlined,
                      tooltip: 'Statement PDF',
                      onTap: () => _shareStatement(context, ref, party, business, ledgerAsync.valueOrNull ?? const []),
                    ),
                    SoftIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: l10n.editParty,
                      onTap: () => PartyFormDialog.show(context, party: party),
                    ),
                  ],
                ),
                Expanded(
                  child: ledgerAsync.when(
                    data: (items) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                        children: [
                          // Hero balance card
                          HeroCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.balance,
                                  style: const TextStyle(
                                    color: Color(0xB3FFFFFF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildBalanceBadge(context, l10n, balancePaise),
                                if (party.gstin != null && party.gstin!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${l10n.gstin}: ${party.gstin}',
                                    style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                                  ),
                                ],
                                if (party.creditLimitPaise > 0) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l10n.creditLimit}: ${formatRupees(party.creditLimitPaise)}',
                                    style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _heroButton(
                                        label: l10n.receivePayment,
                                        icon: Icons.add_card,
                                        gradient: true,
                                        onTap: () async {
                                          await ReceivePaymentDialog.show(context, party: party);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _heroButton(
                                        label: l10n.sendReminder,
                                        icon: Icons.share,
                                        gradient: false,
                                        onTap: () {
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.ledger,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          if (items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  l10n.noTransactions,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            )
                          else
                            for (var index = 0; index < items.length; index++)
                              FadeSlideIn(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildLedgerTile(
                                    context,
                                    l10n,
                                    items[index],
                                    billById[items[index].documentId],
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
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

  Widget _heroButton({
    required String label,
    required IconData icon,
    required bool gradient,
    required VoidCallback onTap,
  }) {
    final fg = gradient ? Colors.white : AppColors.lightText;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            gradient: gradient ? AppColors.accentGradient : null,
            color: gradient ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceBadge(BuildContext context, AppLocalizations l10n, int balancePaise) {
    const style = TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5);
    if (balancePaise > 0) {
      return Text(l10n.youGet(formatRupees(balancePaise)), style: style);
    } else if (balancePaise < 0) {
      return Text(l10n.youGive(formatRupees(balancePaise.abs())), style: style);
    } else {
      return Text(l10n.settled, style: style);
    }
  }

  Widget _buildLedgerTile(BuildContext context, AppLocalizations l10n, LedgerItem item, BillRow? bill) {
    IconData icon;
    Color iconColor;
    Color iconBg;
    String sign;
    Color amountColor;

    switch (item.type) {
      case LedgerItemType.invoice:
        icon = Icons.receipt_long;
        iconColor = AppColors.accent;
        iconBg = AppColors.accentBg;
        sign = '+';
        amountColor = AppColors.lightDanger;
        break;
      case LedgerItemType.creditNote:
        icon = Icons.assignment_return;
        iconColor = AppColors.violet;
        iconBg = AppColors.violetBg;
        sign = '-';
        amountColor = AppColors.lightSuccess;
        break;
      case LedgerItemType.payment:
        icon = Icons.payments;
        iconColor = AppColors.lightSuccess;
        iconBg = AppColors.goodBg;
        sign = '-';
        amountColor = AppColors.lightSuccess;
        break;
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.date);
    final settlement = item.type == LedgerItemType.invoice ? bill?.settlement : null;

    Widget? statusBadge;
    double? progress;
    if (settlement != null && bill != null) {
      if (bill.status == 'cancelled') {
        statusBadge = StatusBadge.warn('Cancelled');
        progress = 0;
      } else if (settlement.duePaise > 0) {
        statusBadge = StatusBadge.due('Paid ${formatRupees(settlement.paidPaise)} · Baaki ${formatRupees(settlement.duePaise)}');
        progress = settlement.netPaise > 0 ? (settlement.paidPaise / settlement.netPaise).clamp(0.0, 1.0) : 0;
      } else {
        statusBadge = StatusBadge.good('Paid in full');
        progress = 1;
      }
    }

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, color: iconColor, background: iconBg, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
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
                    '$sign ${formatRupees(item.amountPaise)}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: amountColor, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.runningBalance(formatRupees(item.runningBalancePaise)),
                    style: const TextStyle(fontSize: 11, color: AppColors.lightMuted),
                  ),
                ],
              ),
            ],
          ),
          if (statusBadge != null && progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.lightBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lightSuccess),
              ),
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: statusBadge),
          ],
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.note}: ${item.note}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.lightMuted),
            ),
          ],
        ],
      ),
    );
  }
}
