import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';

class RekeyResult {
  final String newBusinessId;
  final String newDeviceId;

  RekeyResult({
    required this.newBusinessId,
    required this.newDeviceId,
  });
}

class RekeyService {
  final AppDatabase db;

  RekeyService(this.db);

  /// Returns true if business UUID has already been migrated.
  Future<bool> isMigrated() async {
    final setting = await (db.select(db.appSettingsTable)..where((t) => t.key.equals('business_uuid_migrated'))).getSingleOrNull();
    return setting?.value == 'true';
  }

  /// Rekeys 'local-business' and 'local-device' (or existing seed IDs)
  /// to fresh UUIDs across all tables in ONE single transaction.
  Future<RekeyResult> rekeyIfNeeded() async {
    if (await isMigrated()) {
      final bus = await (db.select(db.businesses)..limit(1)).getSingleOrNull();
      final dev = await (db.select(db.devices)..limit(1)).getSingleOrNull();
      if (bus == null || dev == null) {
        throw StateError('Migrated business or device row missing');
      }
      return RekeyResult(newBusinessId: bus.id, newDeviceId: dev.id);
    }

    final currentBus = await (db.select(db.businesses)..limit(1)).getSingleOrNull();
    final currentDev = await (db.select(db.devices)..limit(1)).getSingleOrNull();

    final oldBusinessId = currentBus?.id ?? 'local-business';
    final oldDeviceId = currentDev?.id ?? 'local-device';

    final newBusinessId = const Uuid().v4();
    final newDeviceId = const Uuid().v4();
    final now = DateTime.now();
    final nowEpoch = now.millisecondsSinceEpoch ~/ 1000;

    await db.transaction(() async {
      // 1. PRAGMA foreign_keys is a no-op inside a transaction, so defer the
      // foreign key checks to COMMIT instead, and drop the immutability triggers
      await db.customStatement('PRAGMA defer_foreign_keys = ON;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_issued_doc_update;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_issued_doc_delete;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_doc_lines_update;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_doc_lines_delete;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_payments_update;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_payments_delete;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_stock_movements_update;');
      await db.customStatement('DROP TRIGGER IF EXISTS prevent_stock_movements_delete;');

      // 2. Update Businesses table
      await db.customStatement(
        'UPDATE businesses SET id = ?, business_id = ?, updated_at = ? WHERE id = ? OR business_id = ?;',
        [newBusinessId, newBusinessId, nowEpoch, oldBusinessId, oldBusinessId],
      );

      // 3. Update Devices table
      await db.customStatement(
        'UPDATE devices SET id = ?, business_id = ?, updated_at = ? WHERE id = ? OR business_id = ?;',
        [newDeviceId, newBusinessId, nowEpoch, oldDeviceId, oldBusinessId],
      );

      // 4. Update Parties table
      await db.customStatement(
        'UPDATE parties SET business_id = ?, updated_at = ? WHERE business_id = ?;',
        [newBusinessId, nowEpoch, oldBusinessId],
      );

      // 5. Update Products table
      await db.customStatement(
        'UPDATE products SET business_id = ?, updated_at = ? WHERE business_id = ?;',
        [newBusinessId, nowEpoch, oldBusinessId],
      );

      // 6. Update DocumentSeries table
      await db.customStatement(
        'UPDATE document_series SET business_id = ?, device_id = ? WHERE business_id = ? OR device_id = ?;',
        [newBusinessId, newDeviceId, oldBusinessId, oldDeviceId],
      );

      // 7. Update Documents table & snapshot_json
      await db.customStatement(
        'UPDATE documents SET business_id = ?, device_id = ? WHERE business_id = ? OR device_id = ?;',
        [newBusinessId, newDeviceId, oldBusinessId, oldDeviceId],
      );

      final docs = await db.select(db.documents).get();
      for (final doc in docs) {
        if (doc.snapshotJson.contains(oldBusinessId) || doc.snapshotJson.contains(oldDeviceId)) {
          final newSnapshot = doc.snapshotJson
              .replaceAll(oldBusinessId, newBusinessId)
              .replaceAll(oldDeviceId, newDeviceId);
          await (db.update(db.documents)..where((t) => t.id.equals(doc.id))).write(
            DocumentsCompanion(snapshotJson: Value(newSnapshot)),
          );
        }
      }

      // 8. Update DocumentLines table
      await db.customStatement(
        'UPDATE document_lines SET business_id = ? WHERE business_id = ?;',
        [newBusinessId, oldBusinessId],
      );

      // 9. Update Payments table
      await db.customStatement(
        'UPDATE payments SET business_id = ? WHERE business_id = ?;',
        [newBusinessId, oldBusinessId],
      );

      // 10. Update StockMovements table
      await db.customStatement(
        'UPDATE stock_movements SET business_id = ? WHERE business_id = ?;',
        [newBusinessId, oldBusinessId],
      );

      // 11. Update OutboxCommands table & payload_json
      await db.customStatement(
        'UPDATE outbox_commands SET business_id = ?, device_id = ? WHERE business_id = ? OR device_id = ?;',
        [newBusinessId, newDeviceId, oldBusinessId, oldDeviceId],
      );

      final outboxRows = await db.select(db.outboxCommands).get();
      for (final cmd in outboxRows) {
        if (cmd.payloadJson.contains(oldBusinessId) || cmd.payloadJson.contains(oldDeviceId)) {
          final newPayload = cmd.payloadJson
              .replaceAll(oldBusinessId, newBusinessId)
              .replaceAll(oldDeviceId, newDeviceId);
          await (db.update(db.outboxCommands)..where((t) => t.id.equals(cmd.id))).write(
            OutboxCommandsCompanion(payloadJson: Value(newPayload)),
          );
        }
      }

      // 12. Update DraftCarts table
      await db.customStatement(
        'UPDATE draft_carts SET business_id = ? WHERE business_id = ?;',
        [newBusinessId, oldBusinessId],
      );

      // 13. Re-create all 8 immutability triggers
      await db.createTriggers();

      // 14. Mark business_uuid_migrated in app_settings
      await db.into(db.appSettingsTable).insertOnConflictUpdate(
            AppSettingsTableCompanion.insert(
              key: 'business_uuid_migrated',
              value: 'true',
            ),
          );

      // 15. Enqueue outbox commands for new Business & Device
      final updatedBus = await (db.select(db.businesses)..where((t) => t.id.equals(newBusinessId))).getSingleOrNull();
      final updatedDev = await (db.select(db.devices)..where((t) => t.id.equals(newDeviceId))).getSingleOrNull();
      if (updatedBus == null || updatedDev == null) {
        throw StateError('Rekeyed business or device row missing');
      }

      await db.enqueueOutboxCommand(
        businessId: newBusinessId,
        deviceId: newDeviceId,
        commandType: 'upsert_business',
        payload: businessToPayload(updatedBus),
      );

      await db.enqueueOutboxCommand(
        businessId: newBusinessId,
        deviceId: newDeviceId,
        commandType: 'upsert_device',
        payload: deviceToPayload(updatedDev),
      );
    });

    return RekeyResult(newBusinessId: newBusinessId, newDeviceId: newDeviceId);
  }
}
