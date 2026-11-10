import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../data/database.dart';

String hashPin(String pin, String salt) => sha256.convert(utf8.encode('$salt:$pin')).toString();

bool isValidPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

/// PIN is kept on this phone only (salted hash in app settings, never the PIN).
class AppLockStore {
  static const _hashKey = 'app_lock_hash';
  static const _saltKey = 'app_lock_salt';

  static Future<String?> _get(AppDatabase db, String key) async {
    final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  static Future<bool> isEnabled(AppDatabase db) async =>
      (await _get(db, _hashKey)) != null || (await _get(db, _saltKey)) != null;

  static Future<bool> verify(AppDatabase db, String pin) async {
    final h = await _get(db, _hashKey);
    final salt = await _get(db, _saltKey);
    if (h == null && salt == null) return true; // no PIN set
    if (h == null || salt == null) return false; // half-written lock: never open
    return hashPin(pin, salt) == h;
  }

  static Future<void> setPin(AppDatabase db, String pin) async {
    if (!isValidPin(pin)) throw ArgumentError('PIN 4 se 6 digits ka hona chahiye');
    final r = Random.secure();
    final salt = base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
    await db.transaction(() async {
      await db.into(db.appSettingsTable).insertOnConflictUpdate(AppSettingsTableCompanion.insert(key: _saltKey, value: salt));
      await db.into(db.appSettingsTable).insertOnConflictUpdate(
            AppSettingsTableCompanion.insert(key: _hashKey, value: hashPin(pin, salt)),
          );
    });
  }

  static Future<void> clear(AppDatabase db) async {
    await (db.delete(db.appSettingsTable)..where((t) => t.key.isIn([_hashKey, _saltKey]))).go();
  }
}
