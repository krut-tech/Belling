import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/records.dart';

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
      appBar: AppBar(title: const Text('Kharcha (expenses)')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: const Text('Kharcha')),
      body: async.when(
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Abhi koi kharcha nahi'));
          final now = DateTime.now();
          final month = list.where((e) {
            final d = DateTime.tryParse(e.str('date'));
            return d != null && d.year == now.year && d.month == now.month;
          }).fold<int>(0, (a, e) => a + e.integer('amount_paise'));
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Is mahine ka kharcha'),
                  trailing: Text(formatRupees(month), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
              ),
              for (final e in list)
                Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) async {
                    await ref.read(recordsRepositoryProvider).remove(e.id);
                    ref.invalidate(expensesProvider);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(e.str('category')),
                      subtitle: Text([
                        (DateTime.tryParse(e.str('date')) ?? e.createdAt).toString().substring(0, 10),
                        if (e.str('note').isNotEmpty) e.str('note'),
                      ].join(' · ')),
                      trailing: Text(formatRupees(e.integer('amount_paise')), style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
