import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/tr_text.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../data/repositories/document_repository.dart';

enum _Filter { all, due, paid, cancelled, returns }

/// Every bill ever issued, with search and filters. Bills are never deleted:
/// a cancelled bill stays here (struck through) together with its credit note.
class AllBillsPage extends ConsumerStatefulWidget {
  const AllBillsPage({super.key});

  @override
  ConsumerState<AllBillsPage> createState() => _AllBillsPageState();
}

class _AllBillsPageState extends ConsumerState<AllBillsPage> {
  String _q = '';
  _Filter _filter = _Filter.all;
  DateTimeRange? _range;

  bool _matches(BillRow r) {
    switch (_filter) {
      case _Filter.all:
        break;
      case _Filter.due:
        if (r.docType != 'invoice' || r.status == 'cancelled' || (r.settlement?.duePaise ?? 0) <= 0) return false;
      case _Filter.paid:
        if (r.docType != 'invoice' || r.status == 'cancelled' || (r.settlement?.duePaise ?? 1) > 0) return false;
      case _Filter.cancelled:
        if (r.status != 'cancelled') return false;
      case _Filter.returns:
        if (r.docType != 'credit_note') return false;
    }
    if (_range != null) {
      final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59);
      if (r.issuedAt.isBefore(_range!.start) || r.issuedAt.isAfter(end)) return false;
    }
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return true;
    return r.number.toLowerCase().contains(q) || (r.displayName ?? '').toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(billsOverviewProvider);
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BellingHeader(
              title: 'All bills',
              subtitle: 'Saare purane bills - kabhi delete nahi hote',
              showBack: true,
              actions: [
                SoftIconButton(
                  tooltip: 'Date range',
                  icon: _range == null ? Icons.date_range_outlined : Icons.event_available,
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDateRange: _range,
                    );
                    if (picked != null) setState(() => _range = picked);
                  },
                ),
                if (_range != null)
                  SoftIconButton(
                    tooltip: 'Clear dates',
                    icon: Icons.close,
                    onTap: () => setState(() => _range = null),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Bill number ya customer ka naam',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  for (final f in _Filter.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                      child: ChoiceChip(
                        showCheckmark: false,
                        shape: const StadiumBorder(side: BorderSide(color: AppColors.lightBorder)),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.ink,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _filter == f ? Colors.white : AppColors.lightText,
                        ),
                        label: Text(switch (f) {
                          _Filter.all => 'All',
                          _Filter.due => 'Baaki',
                          _Filter.paid => 'Paid',
                          _Filter.cancelled => 'Cancelled',
                          _Filter.returns => 'Returns',
                        }),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (o) {
                  final rows = o.rows.where(_matches).toList();
                  if (rows.isEmpty) {
                    return const Center(child: Text('Koi bill nahi mila'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      final cancelled = r.status == 'cancelled';
                      final isCn = r.docType == 'credit_note';
                      final due = r.settlement?.duePaise ?? 0;
                      final hasName = r.displayName != null && r.displayName!.trim().isNotEmpty;
                      final numberLabel = isCn ? 'Credit note ${r.number}' : r.number;
                      return SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        onTap: () => context.push('/sell/done/${r.id}'),
                        child: Row(
                          children: [
                            IconTile(
                              icon: cancelled
                                  ? Icons.cancel_outlined
                                  : isCn
                                      ? Icons.assignment_return_outlined
                                      : Icons.receipt_long_outlined,
                              color: cancelled
                                  ? AppColors.lightDanger
                                  : isCn
                                      ? AppColors.violet
                                      : due > 0
                                          ? AppColors.lightDanger
                                          : AppColors.lightSuccess,
                              background: cancelled
                                  ? AppColors.dueBg
                                  : isCn
                                      ? AppColors.violetBg
                                      : due > 0
                                          ? AppColors.dueBg
                                          : AppColors.goodBg,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasName ? r.displayName! : numberLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      decoration: cancelled ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${hasName ? numberLabel : 'Walk-in'} • ${fmt.format(r.issuedAt)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatRupees(r.totalPaise),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                if (!cancelled && !isCn) ...[
                                  const SizedBox(height: 4),
                                  due > 0
                                      ? StatusBadge.due('Baaki ${formatRupees(due)}')
                                      : StatusBadge.good('Paid'),
                                ],
                              ],
                            ),
                          ],
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
