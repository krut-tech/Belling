import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';
import 'stock_adjust_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'item_form_dialog.dart';

class ItemsPage extends ConsumerStatefulWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
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
    final productsAsync = ref.watch(productsStreamProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.items),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchItems,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        tooltip: 'Clear',
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Items list or empty state
          Expanded(
            child: productsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final p = item.product;

                    final subtitleParts = <String>[];
                    if (p.barcode != null && p.barcode!.isNotEmpty) {
                      subtitleParts.add('${l10n.barcode}: ${p.barcode}');
                    }
                    if (p.hsn.isNotEmpty) {
                      subtitleParts.add('HSN: ${p.hsn}');
                    }

                    return FadeSlideIn(index: index, child: ListTile(
                      minVerticalPadding: 12, // Ensure touch height >= 48px
                      trailing: p.trackStock
                          ? IconButton(
                              tooltip: 'Stock add karo',
                              icon: const Icon(Icons.add_box_outlined),
                              onPressed: () => showStockAdjustDialog(context, ref, item),
                            )
                          : null,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            formatRupees(p.pricePaise),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                subtitleParts.isEmpty ? 'GST: ${formatGstRateBp(p.gstRateBp)}%' : subtitleParts.join(' | '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (p.trackStock) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${l10n.stock}: ${formatMilliUnits(item.stockMilli)}',
                                    style: TextStyle(
                                      color: item.isLowStock ? Colors.red : Colors.grey.shade700,
                                      fontWeight: item.isLowStock ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (item.isLowStock) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.red),
                                      ),
                                      child: Text(
                                        l10n.lowStock,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      onTap: () => ItemFormDialog.show(context, item: item),
                    ));
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ItemFormDialog.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noItemsFound,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noItemsSub,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
