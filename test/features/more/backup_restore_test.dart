import 'dart:io';

import 'package:belling/data/database.dart';
import 'package:belling/data/providers.dart';
import 'package:belling/data/repositories/party_repository.dart';
import 'package:belling/data/repositories/product_repository.dart';
import 'package:belling/features/more/backup_restore_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 7: Backup & Restore Tests', () {
    late Directory tempDir;
    late File mainDbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('belling_test_');
      mainDbFile = File('${tempDir.path}/app_db.sqlite');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('1. Backup inspect and restore round trip', () async {
      // 1. Create source database file
      final sourceDb = AppDatabase(NativeDatabase(mainDbFile));

      final productRepo = ProductRepository(sourceDb, kLocalBusinessId);
      final partyRepo = PartyRepository(sourceDb, kLocalBusinessId);

      await sourceDb.into(sourceDb.businesses).insertOnConflictUpdate(
            BusinessesCompanion.insert(
              id: kLocalBusinessId,
              businessId: kLocalBusinessId,
              name: 'Original Store',
              stateCode: '27',
              address: 'Original Address',
              createdAt: DateTime.now(),
            ),
          );

      await partyRepo.save(
        name: 'Original Customer',
        phone: '9999988888',
        stateCode: '27',
      );

      await productRepo.save(
        name: 'Original Item',
        hsn: '1111',
        gstRateBp: 1800,
        pricePaise: 5000,
        costPaise: 2500,
      );

      // Checkpoint WAL
      await sourceDb.customStatement('PRAGMA wal_checkpoint(FULL);');
      await sourceDb.close();

      // 2. Create backup file
      final backupPath = '${tempDir.path}/test_backup.ubbackup';
      await mainDbFile.copy(backupPath);

      // 3. Inspect backup file
      final info = await BackupRestoreService.inspectBackupFile(backupPath);
      expect(info.partyCount, equals(1));
      expect(info.invoiceCount, equals(0));

      // 4. Overwrite main database file with new/different data
      final modDb = AppDatabase(NativeDatabase(mainDbFile));
      final modPartyRepo = PartyRepository(modDb, kLocalBusinessId);
      await modPartyRepo.save(name: 'New Customer 2', phone: '1111122222', stateCode: '27');
      await modDb.customStatement('PRAGMA wal_checkpoint(FULL);');
      await modDb.close();

      // 5. Restore backup
      final activeDb = AppDatabase(NativeDatabase(mainDbFile));
      await BackupRestoreService.restoreBackup(activeDb, backupPath, targetDbPath: mainDbFile.path);

      // 6. Verify restored data
      final restoredDb = AppDatabase(NativeDatabase(mainDbFile));
      final parties = await restoredDb.select(restoredDb.parties).get();
      expect(parties.length, equals(1));
      expect(parties.first.name, equals('Original Customer'));

      await restoredDb.close();
    });

    test('2. Corrupt or invalid backup file rejected', () async {
      final corruptPath = '${tempDir.path}/corrupt.ubbackup';
      final corruptFile = File(corruptPath);
      await corruptFile.writeAsString('This is not a sqlite database!');

      expect(
        () => BackupRestoreService.inspectBackupFile(corruptPath),
        throwsA(isA<Exception>()),
      );
    });
  });
}
