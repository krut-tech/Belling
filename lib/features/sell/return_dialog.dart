import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

/// Partial sale return: pick how much of each item came back. Returns true if
/// a credit note was issued.
Future<bool> showReturnDialog(BuildContext context, WidgetRef ref, Document invoice) async {
  final db = ref.read(databaseProvider);
  final lines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(invoice.id))).get();
  final already = await db.returnedQtyByProduct(invoice.id);
  if (!context.mounted) return false;

  final remaining = <String, int>{};
  final used = <String, int>{};
  for (final l in lines) {
    final prior = (already[l.productId] ?? 0) + (used[l.productId] ?? 0);
    final left = l.qtyMilli - prior;
    remaining[l.id] = left > 0 ? left : 0;
    used[l.productId] = (used[l.productId] ?? 0) + remaining[l.id]!;
  }
  if (remaining.values.every((v) => v == 0)) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Is bill ka poora maal pehle hi wapas ho chuka hai')));
    return false;
  }

  final ctrls = {for (final l in lines) l.id: TextEditingController()};
  final reason = TextEditingController(text: 'Customer return');

  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Maal wapas (return)'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(shrinkWrap: true, children: [
          const Text('Jitna maal wapas aaya wo quantity daalo. Baaki khali chhodo.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          for (final l in lines)
            if (remaining[l.id]! > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text('${l.name}\nmax ${formatMilliUnits(remaining[l.id]!)}', style: const TextStyle(fontSize: 13))),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: ctrls[l.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '0', isDense: true),
                    ),
                  ),
                ]),
              ),
          TextField(controller: reason, decoration: const InputDecoration(labelText: 'Karan')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Return karo')),
      ],
    ),
  );
  if (go != true || !context.mounted) return false;

  final qtys = <String, int>{};
  for (final l in lines) {
    final t = ctrls[l.id]!.text.trim();
    if (t.isEmpty) continue;
    final q = parseUnitsToMilli(t);
    if (q == null || q < 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.name}: quantity galat hai')));
      return false;
    }
    if (q > 0) qtys[l.id] = q;
  }
  try {
    await ref.read(documentRepositoryProvider).returnItems(
          documentId: invoice.id,
          returnQtyByLineId: qtys,
          reason: reason.text.trim().isEmpty ? 'Customer return' : reason.text.trim(),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return ho gaya. Credit note ban gaya, stock wapas add hua.')));
    }
    return true;
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    return false;
  }
}
