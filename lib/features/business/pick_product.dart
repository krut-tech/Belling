import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';

/// Search-and-pick dialog for an item.
Future<ProductWithStock?> pickProduct(BuildContext context) {
  return showDialog<ProductWithStock>(context: context, builder: (_) => const _PickProductDialog());
}

class _PickProductDialog extends ConsumerStatefulWidget {
  const _PickProductDialog();

  @override
  ConsumerState<_PickProductDialog> createState() => _PickProductDialogState();
}

class _PickProductDialogState extends ConsumerState<_PickProductDialog> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productsStreamProvider(_q));
    return AlertDialog(
      title: const Text('Item chuno'),
      content: SizedBox(
        width: double.maxFinite,
        height: 380,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Naam ya barcode'),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: async.when(
                data: (list) => list.isEmpty
                    ? const Center(child: Text('Koi item nahi mila'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final p = list[i];
                          return ListTile(
                            dense: true,
                            title: Text(p.product.name),
                            subtitle: Text('Stock ${formatMilliUnits(p.stockMilli)} · ${formatRupees(p.product.pricePaise)}'),
                            onTap: () => Navigator.pop(context, p),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
    );
  }
}
