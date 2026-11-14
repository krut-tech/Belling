import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/reminder_service.dart';
import '../../core/smart_alerts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../parties/dues_reminder_sheet.dart';
import '../../core/tr_text.dart';

/// Everyone who owes money, biggest first, one tap to send the PDF reminder.
class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(partiesWithBalanceStreamProvider(''));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: 'Udhar reminders',
              subtitle: async.maybeWhen(
                data: (all) {
                  final owing = all.where((p) => p.balancePaise > 0).toList();
                  if (owing.isEmpty) return null;
                  final total = owing.fold<int>(0, (a, p) => a + p.balancePaise);
                  return '${owing.length} log ka udhar baaki - ${formatRupees(total)}';
                },
                orElse: () => null,
              ),
              showBack: true,
            ),
            Expanded(
              child: async.when(
                data: (all) {
                  final owing = all.where((p) => p.balancePaise > 0).toList()..sort((a, b) => b.balancePaise.compareTo(a.balancePaise));
                  if (owing.isEmpty) {
                    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: const [
                      _AutoReminderCard(),
                      _SmartAlertsCard(),
                      Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Kisi ka udhar baaki nahi. 🎉'))),
                    ]);
                  }
                  final total = owing.fold<int>(0, (a, p) => a + p.balancePaise);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      const _AutoReminderCard(),
                      const _SmartAlertsCard(),
                      HeroCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${owing.length} log ka udhar baaki',
                                      style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(formatRupees(total),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SoftCard(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Column(
                          children: [
                            for (final p in owing)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    MonoTile(initialsOf(p.party.name), color: tileColorFor(p.party.name)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.party.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text(formatRupees(p.balancePaise),
                                              style: const TextStyle(
                                                  color: AppColors.lightDanger, fontWeight: FontWeight.w800, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(backgroundColor: AppColors.whatsappGreen),
                                      onPressed: () => showDuesReminderSheet(context, partyId: p.party.id),
                                      icon: const Icon(Icons.send, size: 16),
                                      label: const Text('Reminder'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
    if (!mounted) return;
    setState(() {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          SwitchListTile(
            secondary: const IconTile(
              icon: Icons.notifications_active_outlined,
              color: AppColors.lightSuccess,
              background: AppColors.goodBg,
            ),
            activeTrackColor: AppColors.accent,
            title: const Text('Roz ka auto reminder', style: TextStyle(fontWeight: FontWeight.w800)),
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
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Notification ka number app khulne aur band hone par update hota hai. Customer ko message khud nahi jata, aap notification tap karke reminder bhejte ho.',
              style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Toggles for low stock, old dues and backup notifications.
class _SmartAlertsCard extends ConsumerStatefulWidget {
  const _SmartAlertsCard();

  @override
  ConsumerState<_SmartAlertsCard> createState() => _SmartAlertsCardState();
}

class _SmartAlertsCardState extends ConsumerState<_SmartAlertsCard> {
  final _on = <String, bool>{};
  bool _loaded = false;

  static const _keys = [SmartAlerts.lowStockKey, SmartAlerts.oldDuesKey, SmartAlerts.backupKey];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    for (final k in _keys) {
      _on[k] = await SmartAlerts.instance.isOn(db, k);
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _toggle(String key, bool v) async {
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
    await SmartAlerts.instance.setOn(db, key, v);
    setState(() => _on[key] = v);
    await SmartAlerts.instance.refresh(db, ref.read(productRepositoryProvider), ref.read(documentRepositoryProvider));
  }

  Widget _tile(String key, IconData icon, Color color, Color bg, String title, String sub) {
    return SwitchListTile(
      secondary: IconTile(icon: icon, color: color, background: bg),
      activeTrackColor: AppColors.accent,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(sub),
      value: _on[key] ?? false,
      onChanged: (v) => _toggle(key, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          _tile(SmartAlerts.lowStockKey, Icons.inventory_2_outlined, AppColors.lightWarning, AppColors.warnBg,
              'Low stock alert', 'Item ka stock reorder level se neeche jaye to batao'),
          _tile(SmartAlerts.oldDuesKey, Icons.hourglass_bottom_rounded, AppColors.lightDanger, AppColors.dueBg,
              'Purana udhar alert', '30 din se zyada baaki bills ka reminder'),
          _tile(SmartAlerts.backupKey, Icons.cloud_upload_outlined, AppColors.blue, AppColors.blueBg,
              'Backup reminder', '7 din se backup na liya ho to yaad dilao'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Ye notifications app khulne aur band hone par update hote hain, aur upar wale "Kab bhejna hai" time par aate hain.',
              style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
            ),
          ),
        ]),
      ),
    );
  }
}
