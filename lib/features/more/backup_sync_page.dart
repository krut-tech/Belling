import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../core/widgets/belling_ui.dart';
import '../../sync/auth_sync_service.dart';
import '../../sync/profile_sync_service.dart';
import '../../sync/sync_chip.dart';
import '../../sync/sync_providers.dart';
import '../../core/tr_text.dart';

class BackupAndSyncPage extends ConsumerStatefulWidget {
  const BackupAndSyncPage({super.key});

  @override
  ConsumerState<BackupAndSyncPage> createState() => _BackupAndSyncPageState();
}

class _BackupAndSyncPageState extends ConsumerState<BackupAndSyncPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authSyncServiceProvider);

      if (_isSignUpMode) {
        final res = await authService.signUp(email, password);
        if (res.session == null) {
          // "Confirm email" is on: there is no session until the mail link is opened.
          setState(() => _errorMessage = 'Account created. Open the confirmation email, then come back and sign in.');
          return;
        }
      } else {
        await authService.signIn(email, password);
      }

      await _afterSignIn(authService);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _afterSignIn(AuthSyncService authService) async {
    final choice = await authService.onSignedIn();
    if (mounted && choice != null) {
      await _showExistingBusinessDialog(choice);
    }
    // Bring back (or save) the shop details kept in this account.
    final profileResult = await ref.read(profileSyncServiceProvider).syncOnSignIn();
    if (mounted && profileResult == ProfileSyncResult.restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aapki shop ki details account se aa gayi (name, GST, UPI...)')),
      );
    }
    if (mounted) {
      try {
        ref.read(pushWorkerProvider).triggerPush();
        ref.read(pullWorkerProvider).pullSoon();
      } catch (e) {
        debugPrint('Sync trigger failed: $e');
      }
    }
  }

  Future<void> _handleGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authSyncServiceProvider);
      await authService.startGoogleSignIn();
      final ok = await authService.waitForSignIn();
      if (!ok) {
        setState(() => _errorMessage = 'Google sign-in poora nahi hua. Dobara try karo.');
        return;
      }
      await _afterSignIn(authService);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showExistingBusinessDialog(ExistingBusinessChoice choice) async {
    final authService = ref.read(authSyncServiceProvider);
    final busName = choice.serverBusiness['name'] ?? 'Existing Business';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Existing Business Found'),
          content: Text(
            'You already have a business "$busName" on the server.\n\n${choice.canAdopt ? 'Would you like to switch to your existing business?' : 'Note: You cannot switch to your existing business on this device because you have issued documents locally.'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (!choice.canAdopt)
              ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(ctx);
                  nav.pop();
                  try {
                    await authService.mergeLocalIntoServer(choice.serverBusiness);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Done. Aapka sab data (bills, items, parties) account se jud gaya.')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('Merge nahi hua: $e')));
                  }
                },
                child: const Text('Data rakho aur jodo (Merge)'),
              ),
            if (!choice.canAdopt)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  final nav = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(ctx);
                  final sure = await showDialog<bool>(
                    context: ctx,
                    builder: (c2) => AlertDialog(
                      title: const Text('Is phone ka data hataye?'),
                      content: const Text(
                        'WARNING: Is phone ke saare bills, items aur parties DELETE ho jayenge. '
                        'Ye kabhi wapas nahi aayega. Agar bills rakhne hain to "Nahi" dabao aur "Merge" chuno.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text('Nahi')),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => Navigator.pop(c2, true),
                          child: const Text('Haan, hatao'),
                        ),
                      ],
                    ),
                  );
                  if (sure != true) return;
                  nav.pop();
                  try {
                    await authService.adoptServerBusiness(choice.serverBusiness);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Account ka business "$busName" use ho raha hai')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Switch nahi hua: $e')),
                    );
                  }
                },
                child: const Text('Local data hatao'),
              ),
            if (choice.canAdopt)
              ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(ctx);
                  nav.pop();
                  try {
                    await authService.adoptServerBusiness(choice.serverBusiness);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Switched to existing business "$busName"')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Could not switch business: $e')),
                    );
                  }
                },
                child: const Text('Use my existing business'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    final authService = ref.read(authSyncServiceProvider);
    try {
      await authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    } on PendingCommandsException catch (e) {
      if (!mounted) return;
      final shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pending Unsynced Changes'),
            content: Text(
              'You have ${e.pendingCount} pending change(s) that have not been pushed to the cloud yet. Signing out will pause sync.\n\nDo you want to sign out anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sign Out Anyway'),
              ),
            ],
          );
        },
      );

      if (shouldSignOut == true) {
        await authService.signOut(force: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed out')),
          );
        }
      }
    }
  }

  Widget _devicesCard() {
    final devices = ref.watch(devicesListProvider).valueOrNull ?? const [];
    final me = ref.watch(currentDeviceIdProvider);
    if (devices.isEmpty) return const SizedBox.shrink();
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Devices (${devices.length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          for (final d in devices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  IconTile(
                    icon: Icons.smartphone_rounded,
                    color: d.id == me ? AppColors.blue : AppColors.lightMuted,
                    background: d.id == me ? AppColors.blueBg : AppColors.lightBackground,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.id == me ? '${d.name} (is phone)' : d.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(
                          d.id == me
                              ? 'Abhi active'
                              : 'Last: ${d.updatedAt.toLocal().toString().substring(0, 16)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: d.id == me ? AppColors.lightSuccess : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authSyncServiceProvider);
    final isSignedIn = authService.isSignedIn;
    final userEmail = authService.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(
              title: 'Backup and Sync',
              showBack: true,
              actions: [SyncChip()],
            ),
            Expanded(
              child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggered([
            HeroCard(
              child: Row(
                children: [
                  const Icon(Icons.cloud, size: 32, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cloud Backup & Multi-Device Sync',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSignedIn
                              ? 'Signed in as $userEmail'
                              : 'Sign in to automatically sync invoices and inventory across devices.',
                          style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isSignedIn) ...[
              SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, color: AppColors.lightSuccess),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userEmail,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                try {
                                  ref.read(pushWorkerProvider).triggerPush();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Sync triggered')),
                                  );
                                } catch (e) {
        debugPrint('Sync trigger failed: $e');
      }
                              },
                              icon: const Icon(Icons.sync),
                              label: const Text('Sync Now'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dueBg, foregroundColor: AppColors.lightDanger),
                              onPressed: _handleSignOut,
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ),
              const SizedBox(height: 16),
              _devicesCard(),
            ] else ...[
              SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isSignUpMode ? 'Create an Account' : 'Sign In to Belling',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.lightDanger, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = !_isSignUpMode;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isSignUpMode ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                        ),
                      ),
                    ],
                  ),
              ),
            ],
          ]),
        ),
      ),
            ),
          ],
        ),
      ),
    );
  }
}
