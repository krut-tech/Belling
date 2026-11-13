import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_lock.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import 'app_lock_gate.dart';
import '../../core/tr_text.dart';

/// More > App lock: set, change or remove the PIN.
class AppLockCard extends ConsumerStatefulWidget {
  const AppLockCard({super.key});

  @override
  ConsumerState<AppLockCard> createState() => _AppLockCardState();
}

class _AppLockCardState extends ConsumerState<AppLockCard> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final e = await AppLockStore.isEnabled(ref.read(databaseProvider));
    if (mounted) setState(() => _enabled = e);
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<String?> _askPin(String title, {String? hint}) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(hintText: hint ?? '4 se 6 digits', counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _setNew() async {
    final a = await _askPin('Naya PIN');
    if (a == null) return;
    if (!isValidPin(a)) {
      _toast('PIN 4 se 6 digits ka hona chahiye');
      return;
    }
    final b = await _askPin('PIN dobara daalo');
    if (b == null) return;
    if (a != b) {
      _toast('Dono PIN alag hain');
      return;
    }
    await AppLockStore.setPin(ref.read(databaseProvider), a);
    ref.read(appLockVersionProvider.notifier).state++;
    await _refresh();
    _toast('PIN set ho gaya. App background se wapas aane par PIN maangega.');
  }

  Future<bool> _verifyOld() async {
    final cur = await _askPin('Abhi ka PIN');
    if (cur == null) return false;
    final ok = await AppLockStore.verify(ref.read(databaseProvider), cur);
    if (!ok) _toast('Galat PIN');
    return ok;
  }

  Future<void> _change() async {
    if (!await _verifyOld()) return;
    await _setNew();
  }

  Future<void> _remove() async {
    if (!await _verifyOld()) return;
    await AppLockStore.clear(ref.read(databaseProvider));
    ref.read(appLockVersionProvider.notifier).state++;
    await _refresh();
    _toast('App lock hata diya');
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('App lock (PIN)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              _enabled ? StatusBadge.good('ON') : const StatusBadge('OFF', color: AppColors.lightMuted, background: AppColors.lightBackground),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Dukaan ka phone kisi ke haath mein jaye to bills aur udhar ka data safe rahe. PIN sirf is phone mein rehta hai.',
            style: TextStyle(fontSize: 13, color: AppColors.lightMuted),
          ),
          const SizedBox(height: 12),
          if (!_enabled)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _setNew,
                icon: const Icon(Icons.pin_outlined),
                label: const Text('PIN lagao'),
              ),
            )
          else
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _change, child: const Text('PIN badlo'))),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _remove,
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.lightDanger),
                    child: const Text('Hatao'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
