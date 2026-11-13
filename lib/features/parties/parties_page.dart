import 'dues_reminder_sheet.dart';
import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'party_form_dialog.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

class PartiesPage extends ConsumerStatefulWidget {
  const PartiesPage({super.key});

  @override
  ConsumerState<PartiesPage> createState() => _PartiesPageState();
}

class _PartiesPageState extends ConsumerState<PartiesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final partiesAsync = ref.watch(partiesWithBalanceStreamProvider(_searchQuery));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PartyFormDialog.show(context),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addParty),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: l10n.tabParties,
              subtitle: partiesAsync.maybeWhen(
                data: (parties) => '${parties.length} parties',
                orElse: () => null,
              ),
            ),
            // Receivable / payable summary
            partiesAsync.when(
              data: (parties) {
                final totalReceivablePaise = parties.fold<int>(
                  0,
                  (sum, p) => p.balancePaise > 0 ? sum + p.balancePaise : sum,
                );
                final totalPayablePaise = parties.fold<int>(
                  0,
                  (sum, p) => p.balancePaise < 0 ? sum - p.balancePaise : sum,
                );
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          l10n.totalReceivable,
                          formatRupees(totalReceivablePaise),
                          Icons.trending_up,
                          AppColors.lightDanger,
                          AppColors.dueBg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          'Dena hai',
                          formatRupees(totalPayablePaise),
                          Icons.account_balance_wallet_outlined,
                          AppColors.blue,
                          AppColors.blueBg,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchParties,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          tooltip: tr(context, 'Clear'),
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    _searchQuery = v;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),

            // Parties List
            Expanded(
              child: partiesAsync.when(
                data: (parties) {
                  if (parties.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noPartiesFound,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noPartiesSub,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                    itemCount: parties.length,
                    itemBuilder: (ctx, index) {
                      final item = parties[index];
                      final p = item.party;
                      final balancePaise = item.balancePaise;
                      final hasGstin = p.gstin != null && p.gstin!.isNotEmpty;

                      return FadeSlideIn(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SoftCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            onTap: () {
                              context.push('/parties/${p.id}');
                            },
                            child: Row(
                              children: [
                                MonoTile(initialsOf(p.name), color: tileColorFor(p.name), size: 46),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${l10n.phone}: ${p.phone}${hasGstin ? " | ${l10n.gstin}: ${p.gstin}" : ""}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.lightMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildBalanceBadge(context, l10n, balancePaise),
                                if (balancePaise > 0)
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                    icon: const Icon(Icons.notifications_active_outlined),
                                    tooltip: tr(context, 'Bakaya reminder bhejo'),
                                    onPressed: () => showDuesReminderSheet(context, partyId: p.id),
                                  ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: l10n.editParty,
                                  onPressed: () => PartyFormDialog.show(context, party: p),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color, Color bg) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, color: color, background: bg, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.lightMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
        ],
      ),
    );
  }

  Widget _buildBalanceBadge(BuildContext context, AppLocalizations l10n, int balancePaise) {
    final Color color;
    final String text;
    final StatusBadge badge;
    if (balancePaise > 0) {
      color = AppColors.lightDanger;
      text = l10n.youGet(formatRupees(balancePaise));
      badge = StatusBadge.due('Baaki');
    } else if (balancePaise < 0) {
      color = AppColors.lightSuccess;
      text = l10n.youGive(formatRupees(balancePaise.abs()));
      badge = StatusBadge.good('Advance');
    } else {
      color = AppColors.lightMuted;
      text = l10n.settled;
      badge = StatusBadge.good('Clear');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 4),
        badge,
      ],
    );
  }
}
