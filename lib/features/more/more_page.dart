import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/gst_states.dart';
import '../../core/providers/locale_provider.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/sync_providers.dart';
import '../../sync/sync_chip.dart';
import '../items/items_import_card.dart';
import 'app_lock_card.dart';
import '../update/update_dialog.dart';
import 'backup_restore_service.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabMore),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SyncChip(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: staggered([
          // Cloud Backup & Sync Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_sync, color: Colors.blue, size: 32),
              title: const Text(
                'Backup & Cloud Sync',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Sign in, manage multi-device sync, and view sync status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/more/backup-sync');
              },
            ),
          ),
          const SizedBox(height: 16),

          // Bill design, paper size, stationary
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.deepPurple, size: 32),
              title: const Text(
                'Bill design & paper',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Paper size, your own stationary/letterhead, logo, colours'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/more/invoice-design');
              },
            ),
          ),
          const SizedBox(height: 16),

          // Business tools
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined, color: Colors.deepOrange),
                  title: const Text('Supplier & purchase', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Maal kharido, stock badhao, supplier ko kitna dena hai'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/more/suppliers'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payments_outlined, color: Colors.teal),
                  title: const Text('Kharcha (expenses)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Rent, salary, bijli ... net munafa mein ghatega'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/more/expenses'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App lock
          const AppLockCard(),
          const SizedBox(height: 16),

          // Bulk item import
          const ItemsImportCard(),
          const SizedBox(height: 16),

          // App updates (GitHub releases)
          const _UpdateCard(),
          const SizedBox(height: 16),

          // Business Settings
          const _BusinessSettingsSection(),
          const SizedBox(height: 16),

          // Local Backup & Restore
          const _BackupRestoreSection(),
          const SizedBox(height: 16),

          // Language Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language),
                      const SizedBox(width: 8),
                      Text(
                        l10n.language,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(l10n.english),
                        ),
                        ButtonSegment<String>(
                          value: 'hi',
                          label: Text(l10n.hindi),
                        ),
                        ButtonSegment<String>(
                          value: 'gu',
                          label: Text(l10n.gujarati),
                        ),
                      ],
                      selected: {currentLocale.languageCode},
                      onSelectionChanged: (newSelection) {
                        if (newSelection.isNotEmpty) {
                          ref
                              .read(localeProvider.notifier)
                              .setLanguageCode(newSelection.first);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _BackupRestoreSection extends ConsumerStatefulWidget {
  const _BackupRestoreSection();

  @override
  ConsumerState<_BackupRestoreSection> createState() => _BackupRestoreSectionState();
}

class _BackupRestoreSectionState extends ConsumerState<_BackupRestoreSection> {
  bool _isLoading = false;

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final backupFile = await BackupRestoreService.backupNow(db);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully at:\n${backupFile.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty || result.files.first.path == null) return;

    final backupPath = result.files.first.path!;

    // Validate the file BEFORE asking, and show what it contains.
    BackupInfo info;
    try {
      info = await BackupRestoreService.inspectBackupFile(backupPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: Text(
          'This backup has ${info.invoiceCount} invoices and ${info.partyCount} parties. '
          'Restoring replaces ALL data currently on this phone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      await BackupRestoreService.restoreBackup(db, backupPath);
      // restoreBackup closed the old connection: open a fresh one for the whole app
      ref.invalidate(databaseProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully. Please restart the app if needed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.archive),
                const SizedBox(width: 8),
                Text(
                  'Local Backup & Restore',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _createBackup,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Create Backup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _restoreBackup,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Restore Backup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessSettingsSection extends ConsumerStatefulWidget {
  const _BusinessSettingsSection();

  @override
  ConsumerState<_BusinessSettingsSection> createState() => _BusinessSettingsSectionState();
}

class _BusinessSettingsSectionState extends ConsumerState<_BusinessSettingsSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _gstinController;
  late TextEditingController _addressController;
  late TextEditingController _upiIdController;
  late TextEditingController _termsController;
  String? _selectedStateCode;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _gstinController = TextEditingController();
    _addressController = TextEditingController();
    _upiIdController = TextEditingController();
    _termsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _upiIdController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = ref.read(databaseProvider);
      final businessId = ref.read(currentBusinessIdProvider);
      final deviceId = ref.read(currentDeviceIdProvider);

      await db.upsertBusinessSettings(
        businessId: businessId,
        deviceId: deviceId,
        name: _nameController.text.trim(),
        gstin: _gstinController.text.trim().isEmpty ? null : _gstinController.text.trim(),
        stateCode: _selectedStateCode,
        address: _addressController.text.trim(),
        upiId: _upiIdController.text.trim().isEmpty ? null : _upiIdController.text.trim(),
        invoiceTerms: _termsController.text.trim().isEmpty ? null : _termsController.text.trim(),
      );

      // Keep the shop details in the account too (best effort, never blocks saving).
      try {
        unawaited(ref.read(profileSyncServiceProvider).pushCurrent());
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business settings saved')),
        );
      }
    } catch (e, st) {
      debugPrint('Error saving business settings: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSavingSettings)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final businessAsync = ref.watch(currentBusinessStreamProvider);

    return businessAsync.when(
      data: (business) {
        if (!_initialized) {
          if (business != null) {
            _nameController.text = business.name;
            _gstinController.text = business.gstin ?? '';
            _addressController.text = business.address;
            _upiIdController.text = business.upiId ?? '';
            _termsController.text = business.invoiceTerms ?? '';
            _selectedStateCode = business.stateCode.isNotEmpty ? business.stateCode : '24';
          } else {
            _selectedStateCode = '24';
          }
          _initialized = true;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store),
                      const SizedBox(width: 8),
                      Text(
                        'Business Settings',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStateCode,
                    decoration: InputDecoration(
                      labelText: l10n.stateLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: kGstStates
                        .map((s) => DropdownMenuItem(
                              value: s.code,
                              child: Text('${s.name} (${s.code})'),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedStateCode = val);
                    },
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.stateRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _gstinController,
                    decoration: const InputDecoration(
                      labelText: 'GSTIN (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final trimmed = v?.trim() ?? '';
                      if (trimmed.isEmpty) return null;
                      if (trimmed.length != 15) {
                        return l10n.gstinLengthError;
                      }
                      if (_selectedStateCode != null && !trimmed.startsWith(_selectedStateCode!)) {
                        return l10n.gstinStateCodeMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _upiIdController,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID for QR (Optional)',
                      hintText: 'e.g. merchant@upi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _termsController,
                    decoration: const InputDecoration(
                      labelText: 'Terms & Conditions (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Business Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        debugPrint('Error loading business: $e\n$st');
        return Text(l10n.genericError);
      },
    );
  }
}


class _UpdateCard extends StatefulWidget {
  const _UpdateCard();

  @override
  State<_UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends State<_UpdateCard> {
  String _version = '';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    currentVersionLabel().then((v) {
      if (mounted) setState(() => _version = v);
    });
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final release = await checkForUpdate();
    if (!mounted) return;
    setState(() => _checking = false);
    if (release != null) {
      await showUpdateDialog(context, release);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App up to date hai (ya internet nahi hai).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.system_update, color: Colors.green, size: 32),
        title: const Text('App update', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Version $_version'),
        trailing: _checking
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right),
        onTap: _checking ? null : _check,
      ),
    );
  }
}
