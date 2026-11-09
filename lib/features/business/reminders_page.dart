import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/reminder_service.dart';
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
          if (owing.isEmpty) {
            return ListView(padding: const EdgeInsets.all(12), children: const [
              _AutoReminderCard(),
              Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Kisi ka udhar baaki nahi. 🎉'))),
            ]);
          }
          final total = owing.fold<int>(0, (a, p) => a + p.balancePaise);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const _AutoReminderCard(),
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

/// Switch + time for the daily notification.
class _AutoReminderCard extends ConsumerStatefulWidget {
  const _AutoReminderCard();

  @override
  ConsumerState<_AutoReminderCard> createState() => _AutoReminderCardState();
}

class _AutoReminderCardState extends ConsumerState<_AutoReminderCard> {
  bool _on = false;
  int _hour = 10;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final on = await ReminderService.instance.isEnabled(db);
    final h = await ReminderService.instance.hour(db);
    if (mounted) setState(() {
      _on = on;
      _hour = h;
      _loaded = true;
    });
  }

  Future<void> _apply() async {
    await ReminderService.instance.refresh(ref.read(databaseProvider), ref.read(partyRepositoryProvider));
  }

  Future<void> _toggle(bool v) async {
    final db = ref.read(databaseProvider);
    if (v) {
      final ok = await ReminderService.instance.requestPermission();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification ki permission chahiye. Phone Settings > Apps > Belling > Notifications on karo.')));
        }
        return;
      }
    }
    await ReminderService.instance.setEnabled(db, v);
    setState(() => _on = v);
    await _apply();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _hour, minute: 0));
    if (t == null) return;
    final db = ref.read(databaseProvider);
    await ReminderService.instance.setHour(db, t.hour);
    setState(() => _hour = clampHourForUi(t.hour));
    await _apply();
  }

  int clampHourForUi(int h) => h < 6 ? 6 : (h > 21 ? 21 : h);

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return Card(
      child: Column(children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Roz ka auto reminder', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Roz ek notification: kitne logon ka udhar baaki hai'),
          value: _on,
          onChanged: _toggle,
        ),
        if (_on)
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Kab bhejna hai'),
            trailing: Text('${_hour.toString().padLeft(2, '0')}:00', style: const TextStyle(fontWeight: FontWeight.w800)),
            onTap: _pickTime,
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Notification ka number app khulne aur band hone par update hota hai. Customer ko message khud nahi jata, aap notification tap karke reminder bhejte ho.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ]),
    );
  }
}
