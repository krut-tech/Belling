import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../data/records.dart';
import '../../core/tr_text.dart';

final expensesProvider = FutureProvider.autoDispose<List<AppRecord>>(
  (ref) => ref.watch(businessRepositoryProvider).expenses(),
);

const kExpenseCategories = ['Rent', 'Salary', 'Bijli', 'Transport', 'Chai-nashta', 'Repair', 'Other'];

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    var category = kExpenseCategories.first;
    final amount = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Kharcha add karo'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [for (final c in kExpenseCategories) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setS(() => category = v ?? category),
              ),
              TextField(controller: amount, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (₹)')),
              TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (optional)')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final paise = parseRupeesToPaise(amount.text);
    if (paise == null || paise <= 0) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount galat hai')));
      return;
    }
    await ref.read(businessRepositoryProvider).saveExpense(category: category, amountPaise: paise, note: note.text);
    ref.invalidate(expensesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(expensesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Kharcha', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(title: 'Kharcha (expenses)', showBack: true),
            Expanded(
              child: async.when(
                data: (list) {
                  if (list.isEmpty) return const Center(child: Text('Abhi koi kharcha nahi'));
                  final now = DateTime.now();
                  final monthRows = list.where((e) {
                    final d = DateTime.tryParse(e.str('date'));
                    return d != null && d.year == now.year && d.month == now.month;
                  }).toList();
                  final month = monthRows.fold<int>(0, (a, e) => a + e.integer('amount_paise'));
                  final byCat = <String, int>{};
                  for (final e in monthRows) {
                    byCat[e.str('category')] = (byCat[e.str('category')] ?? 0) + e.integer('amount_paise');
                  }
                  final cats = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                  final maxCat = cats.isEmpty ? 1 : (cats.first.value <= 0 ? 1 : cats.first.value);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      HeroCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Is mahine ka kharcha',
                                style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(
                              formatRupees(month),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cats.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SoftCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kahan gaya', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              for (final c in cats)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(c.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          Text(formatRupees(c.value), style: const TextStyle(fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: LinearProgressIndicator(
                                          value: (c.value / maxCat).clamp(0.0, 1.0),
                                          minHeight: 8,
                                          backgroundColor: AppColors.lightBackground,
                                          valueColor: AlwaysStoppedAnimation(tileColorFor(c.key)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          children: [
                            for (final e in list)
                              Dismissible(
                                key: ValueKey(e.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                    color: AppColors.lightDanger,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) async {
                                  await ref.read(recordsRepositoryProvider).remove(e.id);
                                  ref.invalidate(expensesProvider);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      const IconTile(
                                        icon: Icons.account_balance_wallet_outlined,
                                        color: AppColors.lightDanger,
                                        background: AppColors.dueBg,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(e.str('category'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text(
                                              [
                                                (DateTime.tryParse(e.str('date')) ?? e.createdAt).toString().substring(0, 10),
                                                if (e.str('note').isNotEmpty) e.str('note'),
                                              ].join(' · '),
                                              style: const TextStyle(
                                                  color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text('- ${formatRupees(e.integer('amount_paise'))}',
                                          style: const TextStyle(
                                              color: AppColors.lightDanger, fontWeight: FontWeight.w800, fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
