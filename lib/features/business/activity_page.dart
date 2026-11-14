import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/tr_text.dart';
import '../../core/widgets/belling_ui.dart';
import '../../core/widgets/motion.dart';
import '../../data/providers.dart';
import '../../data/records.dart';

final _activityProvider = FutureProvider.autoDispose<List<AppRecord>>((ref) async {
  final records = ref.watch(recordsRepositoryProvider);
  return records.list(RecordKinds.activity);
});

/// Who cancelled a bill, gave a discount, returned goods or deleted an item.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  static (IconData, Color, Color) _look(String action) {
    switch (action) {
      case 'Bill cancelled':
        return (Icons.cancel_outlined, AppColors.lightDanger, AppColors.dueBg);
      case 'Goods returned':
        return (Icons.assignment_return_outlined, AppColors.violet, AppColors.violetBg);
      case 'Item deleted':
        return (Icons.delete_outline, AppColors.lightWarning, AppColors.warnBg);
      default:
        return (Icons.percent_rounded, AppColors.accent, AppColors.accentBg);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_activityProvider);
    final fmt = DateFormat('dd MMM, hh:mm a');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(title: 'Activity log', subtitle: 'Cancels, discounts, returns, deletes', showBack: true),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (rows) {
                  if (rows.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No activity yet. Bill cancels, discounts, returns and item deletes will show here.',
                            textAlign: TextAlign.center, style: TextStyle(color: AppColors.lightMuted)),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = rows[i];
                      final look = _look(r.str('action'));
                      return FadeSlideIn(
                        index: i < 8 ? i : 0,
                        child: SoftCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              IconTile(icon: look.$1, color: look.$2, background: look.$3, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.str('action'), style: const TextStyle(fontWeight: FontWeight.w800)),
                                    if (r.str('detail').isNotEmpty)
                                      Text(r.str('detail'), style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text('${r.str('by')} · ${fmt.format(r.createdAt)}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.lightMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
