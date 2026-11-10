// Pure helpers for the daily udhar reminder notification.

class ReminderText {
  const ReminderText(this.title, this.body);
  final String title;
  final String body;
}

/// Notification text for [count] customers owing [totalPaise]; null when nobody owes.
ReminderText? reminderText(int count, int totalPaise, String Function(int) formatMoney) {
  if (count <= 0 || totalPaise <= 0) return null;
  return ReminderText(
    'Udhar reminder',
    '$count logon ka ${formatMoney(totalPaise)} udhar baaki hai. Tap karke reminder bhejo.',
  );
}

/// Next time the clock reads [hour]:00 strictly after [now].
DateTime nextReminderTime(DateTime now, int hour) {
  var t = DateTime(now.year, now.month, now.day, hour);
  if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
  return DateTime(t.year, t.month, t.day, hour);
}

int clampHour(int h) => h < 6 ? 6 : (h > 21 ? 21 : h);
