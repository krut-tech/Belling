import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../data/repositories/document_repository.dart';
import '../data/repositories/product_repository.dart';
import 'money.dart';
import 'reminder_service.dart';

/// Three extra one-time notifications, re-planned whenever the app opens or
/// goes to the background: low stock, old unpaid bills, and "take a backup".
class SmartAlerts {
  SmartAlerts._();
  static final instance = SmartAlerts._();

  static const lowStockKey = 'alert_low_stock';
  static const oldDuesKey = 'alert_old_dues';
  static const backupKey = 'alert_backup';
  static const lastBackupKey = 'last_backup_at';

  static const _lowStockId = 7002;
  static const _oldDuesId = 7003;
  static const _backupId = 7004;

  /// A bill is "old" after this many days unpaid.
  static const oldDueDays = 30;

  /// Remind to back up when the last backup is older than this.
  static const backupEveryDays = 7;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<String?> _get(AppDatabase db, String key) async {
    final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<bool> isOn(AppDatabase db, String key) async => (await _get(db, key)) == '1';

  Future<void> setOn(AppDatabase db, String key, bool on) async {
    await db.into(db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(key: key, value: on ? '1' : '0'),
        );
  }

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  NotificationDetails _details(String channel, String name) => NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          name,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

  Future<void> _schedule(int id, String title, String body, tz.TZDateTime when, String channel, String name) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(channel, name),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Next [hour]:00 that is still in the future (today if possible).
  static tz.TZDateTime nextAt(tz.TZDateTime now, int hour, {int daysFromNow = 0}) {
    var t = tz.TZDateTime(now.location, now.year, now.month, now.day + daysFromNow, hour);
    if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  /// "Atta, Chini +3 aur" style list of up to [max] names.
  static String namesList(List<String> names, {int max = 2}) {
    if (names.length <= max) return names.join(', ');
    return '${names.take(max).join(', ')} +${names.length - max} aur';
  }

  /// Re-plans all three notifications. Never throws.
  Future<void> refresh(AppDatabase db, ProductRepository products, DocumentRepository documents) async {
    try {
      await _init();
      final hour = await ReminderService.instance.hour(db);
      final loc = tz.getLocation('Asia/Kolkata');
      final now = tz.TZDateTime.now(loc);

      // 1. Low stock
      await _plugin.cancel(_lowStockId);
      if (await isOn(db, lowStockKey)) {
        final all = await products.watchProducts().first;
        final low = all.where((p) => p.isLowStock).map((p) => p.product.name).toList();
        if (low.isNotEmpty) {
          await _schedule(
            _lowStockId,
            '${low.length} item ka stock kam hai',
            '${namesList(low)} - jaldi maal mangwao.',
            nextAt(now, hour),
            'low_stock',
            'Low stock',
          );
        }
      }

      // 2. Old unpaid bills
      await _plugin.cancel(_oldDuesId);
      if (await isOn(db, oldDuesKey)) {
        final overview = await documents.watchBillsOverview().first;
        final cutoff = DateTime.now().subtract(const Duration(days: oldDueDays));
        final parties = <String>{};
        var total = 0;
        for (final r in overview.rows) {
          final due = r.settlement?.duePaise ?? 0;
          if (r.docType == 'invoice' && r.status == 'issued' && due > 0 && r.issuedAt.isBefore(cutoff)) {
            parties.add(r.partyId ?? r.id);
            total += due;
          }
        }
        if (parties.isNotEmpty) {
          await _schedule(
            _oldDuesId,
            '${parties.length} logon ka $oldDueDays+ din purana udhar',
            'Kul ${formatRupees(total)} baaki hai. Tap karke reminder bhejo.',
            nextAt(now, hour, daysFromNow: 1),
            'old_dues',
            'Purana udhar',
          );
        }
      }

      // 3. Backup
      await _plugin.cancel(_backupId);
      if (await isOn(db, backupKey)) {
        final last = int.tryParse(await _get(db, lastBackupKey) ?? '');
        final due = last == null
            ? now.add(const Duration(days: 2))
            : tz.TZDateTime.fromMillisecondsSinceEpoch(loc, last).add(const Duration(days: backupEveryDays));
        final day = due.isAfter(now) ? due : now.add(const Duration(days: 1));
        await _schedule(
          _backupId,
          'Backup lene ka time',
          last == null
              ? 'Aapne abhi tak backup nahi liya. More > Backup se ek backup le lo.'
              : '$backupEveryDays din se backup nahi liya. Data safe rakhne ke liye abhi le lo.',
          tz.TZDateTime(loc, day.year, day.month, day.day, hour),
          'backup_reminder',
          'Backup reminder',
        );
      }
    } catch (e) {
      debugPrint('Smart alerts scheduling failed: $e');
    }
  }
}
