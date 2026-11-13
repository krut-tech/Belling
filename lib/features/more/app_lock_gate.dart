import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_lock.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../core/tr_text.dart';

/// Bumped after the PIN is set/changed/removed so the gate re-reads it.
final appLockVersionProvider = StateProvider<int>((ref) => 0);

/// Shows a PIN screen over the app when a PIN is set: at start, and again when
/// the app comes back after being in the background for a while.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  static const _relockAfter = Duration(seconds: 30);

  bool _loaded = false;
  bool _enabled = false;
  bool _locked = false;
  DateTime? _pausedAt;
  String _entry = '';
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load(lockNow: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({required bool lockNow}) async {
    bool enabled;
    try {
      enabled = await AppLockStore.isEnabled(ref.read(databaseProvider));
    } catch (_) {
      // A temporary DB error must not open the app: try once more.
      try {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        enabled = await AppLockStore.isEnabled(ref.read(databaseProvider));
      } catch (_) {
        enabled = false;
      }
    }
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _enabled = enabled;
      if (lockNow) _locked = enabled;
      if (!enabled) _locked = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final at = _pausedAt;
      _pausedAt = null;
      if (_enabled && at != null && DateTime.now().difference(at) >= _relockAfter) {
        setState(() {
          _locked = true;
          _entry = '';
          _error = null;
        });
      }
    }
  }

  Future<void> _digit(String d) async {
    if (_checking || _entry.length >= 6) return;
    HapticFeedback.selectionClick();
    setState(() {
      _entry += d;
      _error = null;
    });
    if (_entry.length >= 4) {
      // Try after each digit from 4 on; a 6-digit PIN also works.
      _checking = true;
      final ok = await AppLockStore.verify(ref.read(databaseProvider), _entry);
      _checking = false;
      if (!mounted) return;
      if (ok) {
        setState(() {
          _locked = false;
          _entry = '';
        });
      } else if (_entry.length == 6) {
        setState(() {
          _error = 'Galat PIN';
          _entry = '';
        });
      }
    }
  }

  void _back() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appLockVersionProvider, (_, __) => _load(lockNow: false));
    if (!_loaded) return const ColoredBox(color: AppColors.lightBackground);
    if (!_locked) return widget.child;

    Widget key(String label, VoidCallback? onTap, {IconData? icon}) => Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 76,
            height: 64,
            child: onTap == null && icon == null
                ? null
                : TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.lightBorder),
                      ),
                    ),
                    child: icon != null
                        ? Icon(icon, color: AppColors.ink)
                        : Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ),
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [BoxShadow(color: Color(0x59FF6A1F), blurRadius: 24, offset: Offset(0, 10))],
                  ),
                  child: const Icon(Icons.lock_outline, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text('PIN daalo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 6; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _entry.length ? AppColors.accent : Colors.transparent,
                          border: Border.all(color: i < _entry.length ? AppColors.accent : AppColors.lightBorder, width: 1.6),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 28,
                  child: _error == null
                      ? null
                      : Center(child: Text(_error!, style: const TextStyle(color: AppColors.lightDanger, fontWeight: FontWeight.w600))),
                ),
                const SizedBox(height: 8),
                for (final r in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ])
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (final d in r) key(d, () => _digit(d))],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    key('', null),
                    key('0', () => _digit('0')),
                    key('', _back, icon: Icons.backspace_outlined),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
