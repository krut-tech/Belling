import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../data/repositories/party_repository.dart';
import 'money.dart';
import 'reminder_plan.dart';

/// Daily "udhar baaki" notification. The text is refreshed every time the app
/// opens or goes to the background, so it always shows recent numbers.
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  static const _enabledKey = 'reminder_enabled';
  static const _hourKey = 'reminder_hour';
  static const _notifId = 7001;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<String?> _get(AppDatabase db, String key) async {
    final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(AppDatabase db, String key, String value) async {
    await db.into(db.appSettingsTable).insertOnConflictUpdate(AppSettingsTableCompanion.insert(key: key, value: value));
  }

  Future<bool> isEnabled(AppDatabase db) async => (await _get(db, _enabledKey)) == '1';

  Future<int> hour(AppDatabase db) async => clampHour(int.tryParse(await _get(db, _hourKey) ?? '') ?? 10);

  Future<void> setEnabled(AppDatabase db, bool on) => _set(db, _enabledKey, on ? '1' : '0');

  Future<void> setHour(AppDatabase db, int h) => _set(db, _hourKey, '${clampHour(h)}');

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  /// Asks Android 13+ for the notification permission. Returns true if allowed.
  Future<bool> requestPermission() async {
    try {
      await _init();
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final ok = await android?.requestNotificationsPermission();
      return ok ?? true;
    } catch (e) {
      debugPrint('Notification permission failed: $e');
      return false;
    }
  }

  /// Re-plans the daily notification from the current dues. Never throws.
  Future<void> refresh(AppDatabase db, PartyRepository parties) async {
    try {
      await _init();
      await _plugin.cancel(_notifId);
      if (!await isEnabled(db)) return;

      final all = await parties.watchPartiesWithBalance().first;
      final owing = all.where((p) => p.balancePaise > 0).toList();
      final total = owing.fold<int>(0, (a, p) => a + p.balancePaise);
      final text = reminderText(owing.length, total, formatRupees);
      if (text == null) return;

      final h = await hour(db);
      final loc = tz.getLocation('Asia/Kolkata');
      final next = nextReminderTime(tz.TZDateTime.now(loc), h);
      final when = tz.TZDateTime(loc, next.year, next.month, next.day, h);

      await _plugin.zonedSchedule(
        _notifId,
        text.title,
        text.body,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'udhar_reminder',
            'Udhar reminder',
            channelDescription: 'Roz ka udhar baaki reminder',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Reminder scheduling failed: $e');
    }
  }
}
