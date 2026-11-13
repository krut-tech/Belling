import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
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
    final paid = _paid.text.trim().isEmpty ? _total : parseRupeesToPaise(_paid.text.replaceAll(RegExp(r'[,₹\s]'), ''));
    if (paid == null || paid < 0 || paid > _total) {
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
    final paidNow = _paid.text.trim().isEmpty
        ? _total
        : (parseRupeesToPaise(_paid.text.replaceAll(RegExp(r'[,₹\s]'), '')) ?? _total);
    final dueLeft = (_total - paidNow) < 0 ? 0 : (_total - paidNow);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(title: 'Naya purchase', subtitle: 'Supplier se maal kharido', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Expanded(child: Text('Items', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                            onPressed: _addLine,
                            icon: const Icon(Icons.add),
                            label: const Text('Item add', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ]),
                        if (_lines.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Item add karo')),
                        for (var i = 0; i < _lines.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_lines[i].name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text('${formatMilliUnits(_lines[i].qtyMilli)} × ${formatRupees(_lines[i].costPaise)}',
                                          style: const TextStyle(
                                              color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Text(formatRupees(_lines[i].amountPaise),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _lines.removeAt(i))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _paid,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: tr(context, 'Abhi kitna diya (₹)'),
                      helperText: 'Khali chhodo = poora ${formatRupees(_total)} diya',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SoftCard(
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatRupees(_total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ]),
                        if (_lines.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Baaki rahega',
                                style: TextStyle(color: AppColors.lightMuted, fontWeight: FontWeight.w600)),
                            Text(formatRupees(dueLeft),
                                style: const TextStyle(color: AppColors.lightDanger, fontWeight: FontWeight.w800)),
                          ]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: _saving ? 'Save ho raha hai...' : 'Purchase save karo (stock badhega)',
                    icon: _saving ? null : Icons.check,
                    expand: true,
                    onPressed: _saving || _lines.isEmpty ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
