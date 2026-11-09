import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../parties/dues_reminder_sheet.dart';

/// Everyone who owes money, biggest first, one tap to send the PDF reminder.
class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(partiesWithBalanceStreamProvider(''));
    return Scaffold(
      appBar: AppBar(title: const Text('Udhar reminders')),
      body: async.when(
        data: (all) {
          final owing = all.where((p) => p.balancePaise > 0).toList()..sort((a, b) => b.balancePaise.compareTo(a.balancePaise));
          if (owing.isEmpty) return const Center(child: Text('Kisi ka udhar baaki nahi. 🎉'));
          final total = owing.fold<int>(0, (a, p) => a + p.balancePaise);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: ListTile(
                  title: Text('${owing.length} log ka udhar baaki'),
                  trailing: Text(formatRupees(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red)),
                ),
              ),
              for (final p in owing)
                Card(
                  child: ListTile(
                    title: Text(p.party.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(formatRupees(p.balancePaise)),
                    trailing: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                      onPressed: () => showDuesReminderSheet(context, partyId: p.party.id),
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Reminder'),
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
