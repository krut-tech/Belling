import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../data/records.dart';
import '../sell/new_bill_notifier.dart';
import '../../core/tr_text.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(
              title: 'Estimates / quotation',
              subtitle: 'Bina bill kiye rate bhejo',
              showBack: true,
            ),
            Expanded(
              child: async.when(
                data: (list) => list.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Koi estimate nahi. Naye bill mein items daalo aur upar wala estimate icon dabao.', textAlign: TextAlign.center),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final e = list[i];
                          final lines = (e.data['lines'] as List?) ?? const [];
                          final who = e.str('party_name');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: SoftCard(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const IconTile(
                                        icon: Icons.description_outlined,
                                        color: AppColors.blue,
                                        background: AppColors.blueBg,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(who.isEmpty ? 'Walk-in customer' : who,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text('${e.createdAt.toString().substring(0, 10)} · ${lines.length} item',
                                                style: const TextStyle(
                                                    color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      Text(formatRupees(e.integer('total_paise')),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  GradientButton(
                                    label: 'Bill banao',
                                    height: 46,
                                    expand: true,
                                    onPressed: () async {
                                      await ref.read(newBillProvider.notifier).loadEstimate(e);
                                      if (context.mounted) context.go('/sell/new');
                                    },
                                  ),
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
