import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../core/tr_text.dart';
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
      appBar: AppBar(
        title: const Text('All bills'),
        actions: [
          IconButton(
            tooltip: 'Date range',
            icon: Icon(_range == null ? Icons.date_range_outlined : Icons.event_available),
            onPressed: () async {
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
            IconButton(
              tooltip: 'Clear dates',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _range = null),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Bill number ya customer ka naam',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in _Filter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: ChoiceChip(
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
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    final cancelled = r.status == 'cancelled';
                    final isCn = r.docType == 'credit_note';
                    final due = r.settlement?.duePaise ?? 0;
                    final hasName = r.displayName != null && r.displayName!.trim().isNotEmpty;
                    final numberLabel = isCn ? 'Credit note ${r.number}' : r.number;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cancelled
                            ? Colors.red.shade100
                            : isCn
                                ? Colors.purple.shade50
                                : Colors.orange.shade50,
                        child: Icon(
                          cancelled
                              ? Icons.cancel
                              : isCn
                                  ? Icons.assignment_return
                                  : Icons.receipt_long,
                          color: cancelled
                              ? Colors.red
                              : isCn
                                  ? Colors.purple
                                  : Colors.orange.shade800,
                        ),
                      ),
                      title: Text(
                        hasName ? r.displayName! : numberLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: cancelled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text('${hasName ? numberLabel : 'Walk-in'} • ${fmt.format(r.issuedAt)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatRupees(r.totalPaise),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (!cancelled && !isCn)
                            Text(
                              due > 0 ? 'Baaki ${formatRupees(due)}' : 'Paid',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: due > 0 ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => context.push('/sell/done/${r.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
