import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Text;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
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
import '../../core/tr_text.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BellingHeader(title: l10n.tabMore, actions: const [SyncChip()]),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: staggered([
                  // Quick tiles
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _MoreTile(
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.violet,
                        background: AppColors.violetBg,
                        label: 'Purchase',
                        onTap: () => context.push('/more/suppliers'),
                      ),
                      _MoreTile(
                        icon: Icons.request_quote_outlined,
                        color: AppColors.warn,
                        background: AppColors.warnBg,
                        label: 'Estimates',
                        onTap: () => context.push('/more/estimates'),
                      ),
                      _MoreTile(
                        icon: Icons.payments_outlined,
                        color: AppColors.lightDanger,
                        background: AppColors.dueBg,
                        label: 'Kharcha',
                        onTap: () => context.push('/more/expenses'),
                      ),
                      _MoreTile(
                        icon: Icons.notifications_active_outlined,
                        color: AppColors.lightSuccess,
                        background: AppColors.goodBg,
                        label: 'Reminders',
                        onTap: () => context.push('/more/reminders'),
                      ),
                      _MoreTile(
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.blue,
                        background: AppColors.blueBg,
                        label: 'All bills',
                        onTap: () => context.push('/more/all-bills'),
                      ),
                      _MoreTile(
                        icon: Icons.sell_outlined,
                        color: AppColors.accent,
                        background: AppColors.accentBg,
                        label: 'Item info',
                        onTap: () => context.push('/more/item-details'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Settings list
                  SoftCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        _MoreRow(
                          icon: Icons.palette_outlined,
                          color: AppColors.violet,
                          background: AppColors.violetBg,
                          title: 'Bill design & paper',
                          subtitle: 'Logo, paper, colours',
                          onTap: () => context.push('/more/invoice-design'),
                        ),
                        _MoreRow(
                          icon: Icons.cloud_sync_outlined,
                          color: AppColors.blue,
                          background: AppColors.blueBg,
                          title: 'Backup & Cloud Sync',
                          subtitle: 'Google account, devices',
                          onTap: () => context.push('/more/backup-sync'),
                        ),
                        _MoreRow(
                          icon: Icons.badge_outlined,
                          color: AppColors.lightSuccess,
                          background: AppColors.goodBg,
                          title: 'Staff & roles',
                          subtitle: 'Cashier, manager',
                          onTap: () => context.push('/more/staff'),
                        ),
                        _MoreRow(
                          icon: Icons.policy_outlined,
                          color: const Color(0xFF0F9D8A),
                          background: const Color(0xFFDDF5F1),
                          title: 'Privacy & legal',
                          subtitle: 'Data aur GST records',
                          onTap: () => context.push('/more/legal'),
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
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconTile(
                              icon: Icons.language,
                              color: AppColors.accent,
                              background: AppColors.warnBg,
                              size: 38,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.language,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;
  const _MoreTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconTile(icon: icon, color: color, background: background, size: 40),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MoreRow({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            IconTile(icon: icon, color: color, background: background, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.lightMuted),
          ],
        ),
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
    return SoftCard(
      child: Padding(
        padding: EdgeInsets.zero,
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

        return SoftCard(
          child: Padding(
            padding: EdgeInsets.zero,
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
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const IconTile(
            icon: Icons.system_update, color: AppColors.lightSuccess, background: AppColors.goodBg),
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
