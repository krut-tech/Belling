import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/tr_text.dart';

/// "Stock add karo" dialog: add purchased stock or remove damaged / lost stock.
Future<void> showStockAdjustDialog(BuildContext context, WidgetRef ref, ProductWithStock item) {
  return showDialog<void>(
    context: context,
    builder: (_) => _StockAdjustDialog(item: item),
  );
}

class _StockAdjustDialog extends ConsumerStatefulWidget {
  const _StockAdjustDialog({required this.item});
  final ProductWithStock item;

  @override
  ConsumerState<_StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends ConsumerState<_StockAdjustDialog> {
  final _qty = TextEditingController();
  bool _add = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final milli = parseUnitsToMilli(_qty.text.trim());
    if (milli == null || milli <= 0) {
      setState(() => _error = 'Sahi quantity daalo (0 se zyada)');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(productRepositoryProvider).adjustStock(
            productId: widget.item.product.id,
            qtyMilli: _add ? milli : -milli,
            reason: _add ? 'purchase' : 'adjustment',
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.item.product;
    final current = formatMilliUnits(widget.item.stockMilli);
    return AlertDialog(
      title: Text(p.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abhi stock: $current', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Stock badhao'), icon: Icon(Icons.add)),
                ButtonSegment(value: false, label: Text('Kam karo'), icon: Icon(Icons.remove)),
              ],
              selected: {_add},
              onSelectionChanged: (v) => setState(() => _add = v.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _add ? 'Kitna maal aaya?' : 'Kitna kam karna hai? (kharab / kho gaya)',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
