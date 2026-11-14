import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/tr_text.dart';
import '../../core/widgets/belling_ui.dart';
import '../../core/widgets/motion.dart';
import 'insights_data.dart';
import 'reports_repository.dart';

final _tabProvider = StateProvider.autoDispose<int>((ref) => 0);

const _tabs = ['Item profit', 'Best customers', 'Slow stock', 'Month compare'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabProvider);
    final async = ref.watch(insightsProvider);
    final preset = ref.watch(insightsPresetProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(title: 'Insights', subtitle: 'Profit, customers, slow stock', showBack: true),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text(_tabs[i]),
                  selected: tab == i,
                  onSelected: (_) => ref.read(_tabProvider.notifier).state = i,
                ),
              ),
            ),
            if (tab == 0 || tab == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final e in const {
                      DateRangePreset.thisMonth: 'This month',
                      DateRangePreset.lastMonth: 'Last month',
                      DateRangePreset.thisFinancialYear: 'This year',
                    }.entries)
                      ChoiceChip(
                        label: Text(e.value),
                        selected: preset == e.key,
                        onSelected: (_) => ref.read(insightsPresetProvider.notifier).state = e.key,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (d) => switch (tab) {
                  0 => _itemProfit(d),
                  1 => _customers(d),
                  2 => _slow(d),
                  _ => _monthCompare(d),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.lightMuted)),
        ),
      );

  Widget _list(List<Widget> rows) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => FadeSlideIn(index: i < 8 ? i : 0, child: rows[i]),
      );

  Widget _rank(int i) => Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: i < 3 ? AppColors.accentBg : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      );

  Widget _itemProfit(InsightsData d) {
    if (d.items.isEmpty) return _empty('No sales in this period');
    final missing = d.items.any((r) => r.noCost);
    return _list([
      if (missing)
        StatusBadge.warn('Some items have no cost price, so their profit looks higher than it is'),
      for (var i = 0; i < d.items.length; i++)
        SoftCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _rank(i),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.items[i].name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${formatMilliUnits(d.items[i].qtyMilli)} sold · Sales ${formatRupees(d.items[i].revenuePaise)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatRupees(d.items[i].profitPaise),
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: d.items[i].profitPaise >= 0 ? AppColors.lightSuccess : AppColors.lightDanger)),
                  Text('${d.items[i].margin.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                ],
              ),
            ],
          ),
        ),
    ]);
  }

  Widget _customers(InsightsData d) {
    if (d.customers.isEmpty) return _empty('No sales to named customers in this period');
    return _list([
      for (var i = 0; i < d.customers.length && i < 20; i++)
        SoftCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _rank(i),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.customers[i].name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${d.customers[i].bills} bills', style: const TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                  ],
                ),
              ),
              Text(formatRupees(d.customers[i].totalPaise), style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
    ]);
  }

  Widget _slow(InsightsData d) {
    if (d.slow.isEmpty) return _empty('No slow stock. Everything in stock sold in the last $kSlowDays days.');
    final tied = d.slow.fold<int>(0, (a, r) => a + r.valuePaise);
    return _list([
      HeroCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Money stuck in slow stock',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(formatRupees(tied),
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('${d.slow.length} items not sold for $kSlowDays+ days (at cost price)',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      for (final r in d.slow)
        SoftCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Stock ${formatMilliUnits(r.stockMilli)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatRupees(r.valuePaise), style: const TextStyle(fontWeight: FontWeight.w800)),
                  StatusBadge.warn(r.daysSince == null ? 'Never sold' : '${r.daysSince} days ago'),
                ],
              ),
            ],
          ),
        ),
    ]);
  }

  Widget _monthCompare(InsightsData d) {
    final maxV = d.months.fold<int>(1, (a, m) => m.totalPaise > a ? m.totalPaise : a);
    final pct = d.changePct;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        HeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This month', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(formatRupees(d.thisMonth),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Last month ${formatRupees(d.lastMonth)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 8),
                  if (pct != null) pct >= 0 ? StatusBadge.good('+$pct%') : StatusBadge.due('$pct%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last 6 months sales', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < d.months.length; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(_short(d.months[i].totalPaise),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: d.months[i].totalPaise <= 0 ? 0.02 : d.months[i].totalPaise / maxV),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Container(
                                height: 120 * v,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  gradient: i == d.months.length - 1 ? AppColors.accentGradient : null,
                                  color: i == d.months.length - 1 ? null : AppColors.softSaffron,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(_months[d.months[i].month.month - 1],
                                style: const TextStyle(fontSize: 11, color: AppColors.lightMuted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _short(int paise) {
    final r = paise / 100;
    if (r >= 10000000) return '${(r / 10000000).toStringAsFixed(1)}Cr';
    if (r >= 100000) return '${(r / 100000).toStringAsFixed(1)}L';
    if (r >= 1000) return '${(r / 1000).toStringAsFixed(1)}k';
    return r.toStringAsFixed(0);
  }
}
