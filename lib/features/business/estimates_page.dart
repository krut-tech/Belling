import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/records.dart';
import '../sell/new_bill_notifier.dart';

final estimatesProvider = FutureProvider.autoDispose<List<AppRecord>>(
  (ref) => ref.watch(recordsRepositoryProvider).list(RecordKinds.estimate),
);

/// Saved estimates / quotations. "Bill banao" loads one into a new bill.
class EstimatesPage extends ConsumerWidget {
  const EstimatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(estimatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Estimates / quotation')),
      body: async.when(
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Koi estimate nahi. Naye bill mein items daalo aur upar wala estimate icon dabao.', textAlign: TextAlign.center),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final e = list[i];
                  final lines = (e.data['lines'] as List?) ?? const [];
                  final who = e.str('party_name');
                  return Card(
                    child: ListTile(
                      title: Text(who.isEmpty ? 'Walk-in customer' : who, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${e.createdAt.toString().substring(0, 10)} · ${lines.length} item'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(formatRupees(e.integer('total_paise')), style: const TextStyle(fontWeight: FontWeight.w800)),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'bill') {
                              await ref.read(newBillProvider.notifier).loadEstimate(e);
                              if (context.mounted) context.go('/sell/new');
                            } else {
                              await ref.read(recordsRepositoryProvider).remove(e.id);
                              ref.invalidate(estimatesProvider);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'bill', child: Text('Bill banao')),
                            PopupMenuItem(value: 'del', child: Text('Delete')),
                          ],
                        ),
                      ]),
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
