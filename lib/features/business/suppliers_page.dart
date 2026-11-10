import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/business_repository.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

final supplierSummariesProvider = FutureProvider.autoDispose<List<SupplierSummary>>(
  (ref) => ref.watch(businessRepositoryProvider).supplierSummaries(),
);

/// Suppliers with how much we owe each, plus a button for a new purchase.
class SuppliersPage extends ConsumerWidget {
  const SuppliersPage({super.key});

  Future<void> _addSupplier(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final gstin = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Naya supplier'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: InputDecoration(labelText: tr(context, 'Naam'))),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)')),
            TextField(controller: gstin, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'GSTIN (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(businessRepositoryProvider).saveSupplier(name: name.text, phone: phone.text, gstin: gstin.text);
      ref.invalidate(supplierSummariesProvider);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, SupplierSummary s) async {
    final c = TextEditingController(text: formatPaiseToRupeesInput(s.duePaise));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${s.supplier.str('name')} ko payment'),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Payment karo')),
        ],
      ),
    );
    if (ok != true) return;
    final paise = parseRupeesToPaise(c.text);
    if (paise == null || paise <= 0) return;
    await ref.read(businessRepositoryProvider).paySupplier(supplierId: s.supplier.id, amountPaise: paise);
    ref.invalidate(supplierSummariesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(supplierSummariesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Supplier & purchase'),
        actions: [IconButton(tooltip: tr(context, 'Naya supplier'), icon: Icon(Icons.person_add_alt), onPressed: () => _addSupplier(context, ref))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/more/purchase/new');
          ref.invalidate(supplierSummariesProvider);
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Naya purchase'),
      ),
      body: async.when(
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Abhi koi supplier nahi. Upar se supplier jodo, ya seedha "Naya purchase" dabao.', textAlign: TextAlign.center),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final s = list[i];
                  return Card(
                    child: ListTile(
                      title: Text(s.supplier.str('name'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Kul kharid ${formatRupees(s.purchasedPaise)} · diya ${formatRupees(s.paidPaise)}'),
                      trailing: s.duePaise > 0
                          ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(formatRupees(s.duePaise), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                              const Text('dena baaki', style: TextStyle(fontSize: 11)),
                            ])
                          : const Text('Clear', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                      onTap: s.duePaise > 0 ? () => _pay(context, ref, s) : null,
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
