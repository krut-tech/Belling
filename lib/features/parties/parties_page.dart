import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'party_form_dialog.dart';

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
      appBar: AppBar(
        title: Text(l10n.tabParties),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PartyFormDialog.show(context),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addParty),
      ),
      body: Column(
        children: [
          // Total Receivable Summary Header
          partiesAsync.when(
            data: (parties) {
              final totalReceivablePaise = parties.fold<int>(
                0,
                (sum, p) => p.balancePaise > 0 ? sum + p.balancePaise : sum,
              );

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalReceivable,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      formatRupees(totalReceivablePaise),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchParties,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
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

                return ListView.separated(
                  itemCount: parties.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final item = parties[index];
                    final p = item.party;
                    final balancePaise = item.balancePaise;

                    return ListTile(
                      minVerticalPadding: 16, // Ensure >= 48px touch target
                      leading: CircleAvatar(
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${l10n.phone}: ${p.phone}${p.gstin != null && p.gstin!.isNotEmpty ? " | ${l10n.gstin}: ${p.gstin}" : ""}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBalanceBadge(context, l10n, balancePaise),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: l10n.editParty,
                            onPressed: () => PartyFormDialog.show(context, party: p),
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push('/parties/${p.id}');
                      },
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
    );
  }

  Widget _buildBalanceBadge(BuildContext context, AppLocalizations l10n, int balancePaise) {
    if (balancePaise > 0) {
      return Text(
        l10n.youGet(formatRupees(balancePaise)),
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else if (balancePaise < 0) {
      return Text(
        l10n.youGive(formatRupees(balancePaise.abs())),
        style: TextStyle(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else {
      return Text(
        l10n.settled,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
  }
}
