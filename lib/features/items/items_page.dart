import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'stock_adjust_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/app_localizations.dart';
import 'item_form_dialog.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

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

    final loaded = productsAsync.valueOrNull;
    String? subtitle;
    if (loaded != null && loaded.isNotEmpty) {
      final low = loaded.where((e) => e.isLowStock).length;
      subtitle = '${loaded.length} ${l10n.items}${low > 0 ? ' • $low ${l10n.lowStock}' : ''}';
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(title: l10n.items, subtitle: subtitle),
            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchItems,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => FadeSlideIn(
                      index: index,
                      child: _itemCard(context, l10n, items[index]),
                    ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => ItemFormDialog.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }

  Widget _itemCard(BuildContext context, AppLocalizations l10n, ProductWithStock item) {
    final p = item.product;

    final subtitleParts = <String>[];
    if (p.barcode != null && p.barcode!.isNotEmpty) {
      subtitleParts.add('${l10n.barcode}: ${p.barcode}');
    }
    if (p.hsn.isNotEmpty) {
      subtitleParts.add('HSN: ${p.hsn}');
    }

    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => ItemFormDialog.show(context, item: item),
      child: Row(
        children: [
          MonoTile(initialsOf(p.name, max: 2), color: tileColorFor(p.name)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleParts.isEmpty ? 'GST: ${formatGstRateBp(p.gstRateBp)}%' : subtitleParts.join(' | '),
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
                formatRupees(p.pricePaise),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              if (p.trackStock) ...[
                const SizedBox(height: 4),
                item.isLowStock
                    ? StatusBadge.due('${l10n.stock} ${formatMilliUnits(item.stockMilli)}')
                    : StatusBadge.good('${l10n.stock} ${formatMilliUnits(item.stockMilli)}'),
              ],
            ],
          ),
          if (p.trackStock)
            IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              tooltip: tr(context, 'Stock add karo'),
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () => showStockAdjustDialog(context, ref, item),
            ),
        ],
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
