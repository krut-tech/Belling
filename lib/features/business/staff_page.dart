import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

const _roleLabels = {
  'owner': 'Owner (sab kuch)',
  'manager': 'Manager (bill, items, reports)',
  'cashier': 'Cashier (sirf bill)',
  'accountant': 'Accountant (sirf dekhna)',
};

class _Member {
  _Member(this.userId, this.email, this.role);
  final String userId;
  final String email;
  final String role;
}

/// Staff access: owner adds people by e-mail and gives them a role. Needs
/// sign-in (Backup & Sync) because roles live on the server.
class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage> {
  List<_Member>? _members;
  String? _error;
  bool _loading = true;

  SupabaseClient? get _client {
    try {
      final c = Supabase.instance.client;
      return c.auth.currentSession == null ? null : c;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _clean(Object e) {
    final m = e.toString();
    if (m.contains('user not found')) return 'Ye email Belling mein sign-in nahi hui. Unhe pehle ek baar apne email se login karne bolo.';
    if (m.contains('only the owner')) return 'Ye kaam sirf owner kar sakta hai.';
    if (m.contains('not allowed')) return 'Aapko staff list dekhne ki permission nahi hai.';
    return m;
  }

  Future<void> _load() async {
    final c = _client;
    if (c == null) {
      setState(() {
        _loading = false;
        _error = 'Pehle More > Backup & Sync mein sign in karo.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await c.rpc('list_staff', params: {'p_business': ref.read(currentBusinessIdProvider)});
      final list = (rows as List)
          .map((r) => _Member(r['user_id'] as String, (r['email'] as String?) ?? '?', r['role'] as String))
          .toList();
      if (mounted) setState(() => _members = list);
    } catch (e) {
      if (mounted) setState(() => _error = _clean(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final email = TextEditingController();
    var role = 'cashier';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Staff add karo'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: email, autofocus: true, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: tr(context, 'Unka email'))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: [
                for (final r in const ['manager', 'cashier', 'accountant']) DropdownMenuItem(value: r, child: Text(_roleLabels[r]!)),
              ],
              onChanged: (v) => setS(() => role = v ?? role),
            ),
            const SizedBox(height: 8),
            const Text('Unhe pehle ek baar Belling mein isi email se login karna hoga.', style: TextStyle(fontSize: 12)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
          ],
        ),
      ),
    );
    if (ok != true || email.text.trim().isEmpty) return;
    try {
      await _client!.rpc('add_staff_by_email', params: {
        'p_business': ref.read(currentBusinessIdProvider),
        'p_email': email.text.trim(),
        'p_role': role,
      });
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_clean(e))));
    }
  }

  Future<void> _remove(_Member m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Staff hatao?'),
        content: Text('${m.email} ka access band ho jayega.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hatao')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _client!.rpc('remove_staff', params: {'p_business': ref.read(currentBusinessIdProvider), 'p_user': m.userId});
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_clean(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _client == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              onPressed: _add,
              icon: const Icon(Icons.person_add),
              label: const Text('Staff add', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: Column(
          children: [
            BellingHeader(
              title: 'Staff & roles',
              subtitle: 'Kaun kya dekh sakta hai',
              showBack: true,
              actions: [
                SoftIconButton(
                  icon: Icons.history_rounded,
                  tooltip: 'Activity log',
                  onTap: () => context.push('/more/activity'),
                ),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          children: [
                            for (final m in _members ?? const <_Member>[])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SoftCard(
                                  child: Row(
                                    children: [
                                      MonoTile(initialsOf(m.email), color: tileColorFor(m.email), size: 46),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.email,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text(_roleLabels[m.role] ?? m.role,
                                                style: const TextStyle(
                                                    color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      if (m.role == 'owner')
                                        StatusBadge.good('Owner')
                                      else
                                        IconButton(icon: const Icon(Icons.close), onPressed: () => _remove(m)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
