import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/providers.dart';
import 'sync_providers.dart';

class SyncChip extends ConsumerWidget {
  const SyncChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);

    Color chipColor;
    IconData icon;
    String label;

    switch (status.type) {
      case SyncStatusType.signInToSync:
        chipColor = Colors.blue;
        icon = Icons.cloud_off;
        label = 'Sign in to sync';
        break;
      case SyncStatusType.offline:
        chipColor = Colors.grey;
        icon = Icons.wifi_off;
        label = 'Offline';
        break;
      case SyncStatusType.synced:
        chipColor = Colors.green;
        icon = Icons.cloud_done;
        label = 'Synced';
        break;
      case SyncStatusType.pending:
        chipColor = Colors.orange;
        icon = Icons.cloud_upload;
        label = '${status.pendingCount} pending';
        break;
      case SyncStatusType.error:
        chipColor = Colors.red;
        icon = Icons.error_outline;
        label = 'Error';
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (status.type == SyncStatusType.error) {
          _showRejectedCommandsDialog(context, ref, status.rejectedCommands);
        } else if (status.type == SyncStatusType.signInToSync) {
          context.push('/more/backup-sync');
        } else {
          try {
            ref.read(pushWorkerProvider).triggerPush();
          } catch (_) {}
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: chipColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: chipColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: chipColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectedCommandsDialog(BuildContext context, WidgetRef ref, List rejectedCommands) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rejected Sync Commands'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: rejectedCommands.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final cmd = rejectedCommands[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    '${cmd.commandType} (${cmd.id.substring(0, 8)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    cmd.lastError ?? 'Unknown constraint violation',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Put the rejected commands back in the queue (e.g. after a
                // server-side fix) and push again.
                final db = ref.read(databaseProvider);
                final ids = rejectedCommands.map<String>((c) => c.id as String).toList();
                await (db.update(db.outboxCommands)..where((t) => t.id.isIn(ids) & t.status.equals('rejected')))
                    .write(const OutboxCommandsCompanion(status: Value('pending'), lastError: Value(null)));
                try {
                  ref.read(pushWorkerProvider).triggerPush();
                } catch (_) {}
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
