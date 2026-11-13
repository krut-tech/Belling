import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () async {
          await context.push('/more/purchase/new');
          ref.invalidate(supplierSummariesProvider);
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Naya purchase', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: 'Supplier & purchase',
              showBack: true,
              actions: [
                SoftIconButton(
                  tooltip: tr(context, 'Naya supplier'),
                  icon: Icons.person_add_alt,
                  onTap: () => _addSupplier(context, ref),
                ),
              ],
            ),
            Expanded(
              child: async.when(
                data: (list) => list.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Abhi koi supplier nahi. Upar se supplier jodo, ya seedha "Naya purchase" dabao.', textAlign: TextAlign.center),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final s = list[i];
                          final name = s.supplier.str('name');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SoftCard(
                              onTap: s.duePaise > 0 ? () => _pay(context, ref, s) : null,
                              child: Row(
                                children: [
                                  MonoTile(initialsOf(name), color: tileColorFor(name), size: 46),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                        const SizedBox(height: 2),
                                        Text('Kul kharid ${formatRupees(s.purchasedPaise)} · diya ${formatRupees(s.paidPaise)}',
                                            style: const TextStyle(
                                                color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  if (s.duePaise > 0)
                                    Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                      Text(formatRupees(s.duePaise),
                                          style: const TextStyle(color: AppColors.lightDanger, fontWeight: FontWeight.w800)),
                                      const Text('dena baaki', style: TextStyle(fontSize: 11, color: AppColors.lightMuted)),
                                    ])
                                  else
                                    StatusBadge.good('Clear'),
                                ],
                              ),
                            ),
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
    );
  }
}
