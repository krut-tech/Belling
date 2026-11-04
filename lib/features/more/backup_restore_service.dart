import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../data/database.dart';

class BackupInfo {
  final int invoiceCount;
  final int partyCount;

  const BackupInfo({
    required this.invoiceCount,
    required this.partyCount,
  });
}

class BackupRestoreService {
  static Future<File> getDatabaseFile({String? overridePath}) async {
    if (overridePath != null) return File(overridePath);
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final docFile = File('${docDir.path}/app_db.sqlite');
      if (await docFile.exists()) return docFile;

      final supportDir = await getApplicationSupportDirectory();
      final supportFile = File('${supportDir.path}/app_db.sqlite');
      if (await supportFile.exists()) return supportFile;

      return docFile;
    } catch (_) {
      return File('app_db.sqlite');
    }
  }

  static Future<File> backupNow(AppDatabase db) async {
    // 1. Flush WAL to main database file
    await db.customStatement('PRAGMA wal_checkpoint(FULL);');

    // 2. Locate sqlite file
    final dbFile = await getDatabaseFile();
    if (!await dbFile.exists()) {
      throw StateError('Database file not found on disk');
    }

    // 3. Copy to .ubbackup file in temp directory
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${tempDir.path}/belling_backup_$timestamp.ubbackup';
    final backupFile = await dbFile.copy(backupPath);

    // 4. Share via share sheet
    await Share.shareXFiles([XFile(backupFile.path)], text: 'Universal Billing Backup');
    return backupFile;
  }

  static Future<BackupInfo> inspectBackupFile(String backupFilePath) async {
    final file = File(backupFilePath);
    if (!await file.exists()) {
      throw Exception('Backup file does not exist');
    }

    Database? tempDb;
    try {
      tempDb = sqlite3.open(backupFilePath);

      // 1. PRAGMA integrity_check
      final integrityRes = tempDb.select('PRAGMA integrity_check;');
      if (integrityRes.isEmpty || integrityRes.first.values.first != 'ok') {
        throw Exception('PRAGMA integrity_check failed');
      }

      // 2. PRAGMA user_version check
      final versionRes = tempDb.select('PRAGMA user_version;');
      if (versionRes.isEmpty) {
        throw Exception('PRAGMA user_version missing');
      }
      final userVersion = versionRes.first.values.first as int;
      if (userVersion <= 0 || userVersion > 10) {
        throw Exception('Invalid user_version schema: $userVersion');
      }

      // 3. Check required tables exist & count records
      final invRes = tempDb.select("SELECT COUNT(*) FROM documents WHERE doc_type = 'invoice';");
      final invoiceCount = invRes.first.values.first as int;

      final partyRes = tempDb.select('SELECT COUNT(*) FROM parties;');
      final partyCount = partyRes.first.values.first as int;

      return BackupInfo(invoiceCount: invoiceCount, partyCount: partyCount);
    } catch (e) {
      throw Exception('Corrupt or invalid backup file: $e');
    } finally {
      tempDb?.dispose();
    }
  }

  static Future<void> restoreBackup(AppDatabase db, String backupFilePath, {String? targetDbPath}) async {
    // 1. Inspect first
    await inspectBackupFile(backupFilePath);

    // 2. Checkpoint WAL
    try {
      await db.customStatement('PRAGMA wal_checkpoint(FULL);');
    } catch (_) {}

    // 3. Close database connection
    await db.close();

    final dbFile = await getDatabaseFile(overridePath: targetDbPath);
    final bakFile = File('${dbFile.path}.bak');

    // 4. Backup current database to .bak
    if (await dbFile.exists()) {
      await dbFile.copy(bakFile.path);
    }

    // Clean up sidecars
    final walFile = File('${dbFile.path}-wal');
    final shmFile = File('${dbFile.path}-shm');
    if (await walFile.exists()) await walFile.delete();
    if (await shmFile.exists()) await shmFile.delete();

    // 5. Replace with new backup file
    try {
      await File(backupFilePath).copy(dbFile.path);

      // Verify restored file can open and query
      final testDb = sqlite3.open(dbFile.path);
      testDb.select('SELECT COUNT(*) FROM businesses;');
      testDb.dispose();

      // Restore succeeded, delete .bak
      if (await bakFile.exists()) {
        await bakFile.delete();
      }
    } catch (e) {
      // Revert from .bak if restore failed
      if (await bakFile.exists()) {
        await bakFile.copy(dbFile.path);
      }
      rethrow;
    }
  }
}
