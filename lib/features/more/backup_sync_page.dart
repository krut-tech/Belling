import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/auth_sync_service.dart';
import '../../sync/sync_chip.dart';
import '../../sync/sync_providers.dart';

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
      ExistingBusinessChoice? choice;

      if (_isSignUpMode) {
        await authService.signUp(email, password);
      } else {
        await authService.signIn(email, password);
      }

      choice = await authService.onSignedIn();

      if (mounted && choice != null) {
        await _showExistingBusinessDialog(choice);
      }

      if (mounted) {
        try {
          ref.read(pushWorkerProvider).triggerPush();
        } catch (_) {}
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            if (choice.canAdopt)
              ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(ctx);
                  nav.pop();
                  await authService.adoptServerBusiness(choice.serverBusiness);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Switched to existing business "$busName"')),
                  );
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

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authSyncServiceProvider);
    final isSignedIn = authService.isSignedIn;
    final userEmail = authService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup and Sync'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SyncChip(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.cloud, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cloud Backup & Multi-Device Sync',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSignedIn
                                ? 'Signed in as $userEmail'
                                : 'Sign in to automatically sync invoices and inventory across devices.',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isSignedIn) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, color: Colors.green),
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
                                } catch (_) {}
                              },
                              icon: const Icon(Icons.sync),
                              label: const Text('Sync Now'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900),
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
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
