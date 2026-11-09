import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/records.dart';
import '../../data/repositories/product_repository.dart';

final _itemMetasProvider = FutureProvider.autoDispose<Map<String, AppRecord>>(
  (ref) => ref.watch(businessRepositoryProvider).itemMetas(),
);

/// Category, unit and MRP for each item.
class ItemDetailsPage extends ConsumerStatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  ConsumerState<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends ConsumerState<ItemDetailsPage> {
  String _q = '';
  String? _category;

  Future<void> _edit(ProductWithStock p, AppRecord? meta) async {
    final cat = TextEditingController(text: meta?.str('category') ?? '');
    final unit = TextEditingController(text: meta?.str('unit') ?? '');
    final mrp = TextEditingController(
      text: (meta?.integer('mrp_paise') ?? 0) > 0 ? formatPaiseToRupeesInput(meta!.integer('mrp_paise')) : '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.product.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: cat, decoration: const InputDecoration(labelText: 'Category (jaise Kirana, Dairy)')),
          TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit (kg, pcs, litre ...)')),
          TextField(controller: mrp, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'MRP (₹)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final mrpPaise = mrp.text.trim().isEmpty ? 0 : (parseRupeesToPaise(mrp.text) ?? 0);
    await ref.read(businessRepositoryProvider).saveItemMeta(p.product.id, category: cat.text, unit: unit.text, mrpPaise: mrpPaise);
    ref.invalidate(_itemMetasProvider);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsStreamProvider(_q));
    final metas = ref.watch(_itemMetasProvider).valueOrNull ?? const <String, AppRecord>{};
    final categories = {for (final m in metas.values) if (m.str('category').isNotEmpty) m.str('category')}.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Item details (category, unit, MRP)')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Item dhundo'),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        if (categories.isNotEmpty)
          SizedBox(
            height: 46,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: const Text('Sab'), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
              ),
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
                ),
            ]),
          ),
        Expanded(
          child: products.when(
            data: (list) {
              final shown = list.where((p) => _category == null || metas[p.product.id]?.str('category') == _category).toList();
              if (shown.isEmpty) return const Center(child: Text('Koi item nahi'));
              return ListView.builder(
                itemCount: shown.length,
                itemBuilder: (_, i) {
                  final p = shown[i];
                  final m = metas[p.product.id];
                  final extra = [
                    if (m != null && m.str('category').isNotEmpty) m.str('category'),
                    if (m != null && m.str('unit').isNotEmpty) m.str('unit'),
                    if (m != null && m.integer('mrp_paise') > 0) 'MRP ${formatRupees(m.integer('mrp_paise'))}',
                  ];
                  return ListTile(
                    title: Text(p.product.name),
                    subtitle: Text(extra.isEmpty ? 'Details set nahi' : extra.join(' · ')),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _edit(p, m),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ]),
    );
  }
}
