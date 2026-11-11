import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/tr_text.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import 'new_bill_notifier.dart';

/// productId -> category text, for the item picker.
final itemCategoriesProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final metas = await ref.watch(businessRepositoryProvider).itemMetas();
  return {for (final m in metas.values) m.id: m.str('category')};
});

const _kOther = 'Other';

const _tileColors = <Color>[
  Color(0xFFE8590C),
  Color(0xFF2563EB),
  Color(0xFF0F766E),
  Color(0xFF7C3AED),
  Color(0xFFDB2777),
  Color(0xFFB45309),
  Color(0xFF475569),
];

Color _colorFor(String name) {
  var h = 0;
  for (final c in name.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return _tileColors[h % _tileColors.length];
}

String _mono(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return t.length == 1 ? t.toUpperCase() : '${t[0].toUpperCase()}${t[1].toLowerCase()}';
}

/// Left rail of categories + grid of items. Tap an item to add it to the bill.
class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({super.key, required this.onAdd});

  final ValueChanged<ProductWithStock> onAdd;

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  String? _cat; // null = All
  String? _sub; // null = all inside the category

  Future<void> _rename(String cat) async {
    final c = TextEditingController(text: cat);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Category ka naam badlo'),
        content: TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    final newName = c.text.trim();
    c.dispose();
    if (ok != true || newName.isEmpty || !mounted) return;
    await ref.read(businessRepositoryProvider).renameCategory(cat, newName);
    ref.invalidate(itemCategoriesProvider);
    if (mounted) setState(() => _cat = newName);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider(''));
    final cats = ref.watch(itemCategoriesProvider).valueOrNull ?? const <String, String>{};
    final lines = ref.watch(newBillProvider.select((s) => s.lines));

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Abhi koi item nahi hai. Items tab mein item add karo.', textAlign: TextAlign.center),
            ),
          );
        }

        final qtyByProduct = <String, int>{
          for (final l in lines) l.product.product.id: l.qtyMilli,
        };

        // Count items per top-level category.
        final counts = <String, int>{};
        for (final p in products) {
          final parent = splitCategory(cats[p.product.id] ?? '').parent;
          final key = parent.isEmpty ? _kOther : parent;
          counts[key] = (counts[key] ?? 0) + 1;
        }
        final names = counts.keys.where((k) => k != _kOther).toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        if (counts.containsKey(_kOther)) names.add(_kOther);
        // A category that no longer exists (renamed/emptied): fall back to All.
        final cat = (_cat != null && counts.containsKey(_cat)) ? _cat : null;

        // Sub-categories of the selected category.
        final subs = <String>{};
        if (cat != null) {
          for (final p in products) {
            final path = splitCategory(cats[p.product.id] ?? '');
            if (path.parent == cat && path.child != null) subs.add(path.child!);
          }
        }
        final subList = subs.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final sub = (_sub != null && subs.contains(_sub)) ? _sub : null;

        final shown = products.where((p) {
          if (cat == null) return true;
          final path = splitCategory(cats[p.product.id] ?? '');
          final parent = path.parent.isEmpty ? _kOther : path.parent;
          if (parent != cat) return false;
          return sub == null || path.child == sub;
        }).toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
                children: [
                  _RailTile(
                    label: 'All',
                    count: products.length,
                    mono: 'All',
                    color: AppColors.lightMuted,
                    selected: cat == null,
                    onTap: () => setState(() {
                      _cat = null;
                      _sub = null;
                    }),
                  ),
                  for (final n in names)
                    _RailTile(
                      label: n,
                      count: counts[n]!,
                      mono: _mono(n),
                      color: n == _kOther ? AppColors.lightMuted : _colorFor(n),
                      selected: cat == n,
                      onTap: () => setState(() {
                        _cat = n;
                        _sub = null;
                      }),
                      onLongPress: n == _kOther ? null : () => _rename(n),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subList.isNotEmpty)
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('Sab $cat'),
                              selected: sub == null,
                              onSelected: (_) => setState(() => _sub = null),
                            ),
                          ),
                          for (final s in subList)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(s),
                                selected: sub == s,
                                onSelected: (_) => setState(() => _sub = s),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: shown.isEmpty
                        ? const Center(child: Text('Is category mein koi item nahi'))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(4, 4, 8, 12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 112,
                            ),
                            itemCount: shown.length,
                            itemBuilder: (context, i) {
                              final p = shown[i];
                              return _ItemCard(
                                item: p,
                                qtyMilli: qtyByProduct[p.product.id] ?? 0,
                                onTap: () => widget.onAdd(p),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.label,
    required this.count,
    required this.mono,
    required this.color,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final int count;
  final String mono;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AppColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.ink : AppColors.lightBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(mono, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : AppColors.lightMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.qtyMilli, required this.onTap});

  final ProductWithStock item;
  final int qtyMilli;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inCart = qtyMilli > 0;
    final low = item.product.trackStock && item.stockMilli <= item.product.reorderLevel;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: inCart ? AppColors.saffron : AppColors.lightBorder, width: inCart ? 1.6 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.2),
              ),
              if (item.product.trackStock)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Stock ${formatMilliUnits(item.stockMilli)}',
                    style: TextStyle(fontSize: 11, color: low ? AppColors.lightWarning : AppColors.lightMuted),
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatRupees(item.product.pricePaise),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: inCart ? AppColors.saffron : AppColors.softSaffron,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      inCart ? '× ${formatMilliUnits(qtyMilli)}' : '+',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: inCart ? Colors.white : const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
