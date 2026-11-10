import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/records.dart';
import '../../data/repositories/business_repository.dart';
import 'pick_product.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

/// Record a purchase bill: stock goes up, cost price updates, supplier due is tracked.
class NewPurchasePage extends ConsumerStatefulWidget {
  const NewPurchasePage({super.key});

  @override
  ConsumerState<NewPurchasePage> createState() => _NewPurchasePageState();
}

class _NewPurchasePageState extends ConsumerState<NewPurchasePage> {
  final _lines = <PurchaseLine>[];
  final _billNo = TextEditingController();
  final _paid = TextEditingController();
  List<AppRecord> _suppliers = [];
  String? _supplierId;
  bool _saving = false;

  int get _total => _lines.fold<int>(0, (a, l) => a + l.amountPaise);

  @override
  void initState() {
    super.initState();
    ref.read(businessRepositoryProvider).suppliers().then((s) {
      if (mounted) setState(() => _suppliers = s);
    });
  }

  Future<void> _addLine() async {
    final p = await pickProduct(context);
    if (p == null || !mounted) return;
    final qty = TextEditingController(text: '1');
    final cost = TextEditingController(text: formatPaiseToRupeesInput(p.product.costPaise));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.product.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: qty, autofocus: true, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Quantity')),
          TextField(controller: cost, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: tr(context, 'Kharid rate per unit (₹)'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true) return;
    final q = parseUnitsToMilli(qty.text);
    final c = parseRupeesToPaise(cost.text);
    if (q == null || q <= 0 || c == null || c < 0) {
      _toast('Quantity ya rate galat hai');
      return;
    }
    setState(() => _lines.add(PurchaseLine(productId: p.product.id, name: p.product.name, qtyMilli: q, costPaise: c)));
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _save() async {
    final paid = _paid.text.trim().isEmpty ? _total : parseRupeesToPaise(_paid.text);
    if (paid == null) {
      _toast('Paid amount galat hai');
      return;
    }
    setState(() => _saving = true);
    try {
      final name = _suppliers.where((s) => s.id == _supplierId).map((s) => s.str('name')).firstOrNull ?? '';
      await ref.read(businessRepositoryProvider).savePurchase(
            supplierId: _supplierId,
            supplierName: name,
            billNo: _billNo.text,
            lines: _lines,
            paidPaise: paid,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _toast('$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Naya purchase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String?>(
            initialValue: _supplierId,
            decoration: const InputDecoration(labelText: 'Supplier'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Koi nahi / cash purchase')),
              for (final s in _suppliers) DropdownMenuItem<String?>(value: s.id, child: Text(s.str('name'))),
            ],
            onChanged: (v) => setState(() => _supplierId = v),
          ),
          const SizedBox(height: 10),
          TextField(controller: _billNo, decoration: const InputDecoration(labelText: 'Supplier bill number (optional)')),
          const SizedBox(height: 16),
          Row(children: [
            const Expanded(child: Text('Items', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            FilledButton.tonalIcon(onPressed: _addLine, icon: const Icon(Icons.add), label: const Text('Item add')),
          ]),
          const SizedBox(height: 8),
          if (_lines.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Item add karo')),
          for (var i = 0; i < _lines.length; i++)
            Card(
              child: ListTile(
                title: Text(_lines[i].name),
                subtitle: Text('${formatMilliUnits(_lines[i].qtyMilli)} × ${formatRupees(_lines[i].costPaise)}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatRupees(_lines[i].amountPaise), style: const TextStyle(fontWeight: FontWeight.w800)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _lines.removeAt(i))),
                ]),
              ),
            ),
          const Divider(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(formatRupees(_total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
          SizedBox(height: 10),
          TextField(
            controller: _paid,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: tr(context, 'Abhi kitna diya (₹)'), helperText: 'Khali chhodo = poora ${formatRupees(_total)} diya'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving || _lines.isEmpty ? null : _save,
            child: Padding(padding: const EdgeInsets.all(14), child: Text(_saving ? 'Save ho raha hai...' : 'Purchase save karo (stock badhega)')),
          ),
        ],
      ),
    );
  }
}
