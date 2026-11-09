import 'package:belling/core/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminderText is null when nobody owes', () {
    expect(reminderText(0, 0, (p) => '$p'), isNull);
    expect(reminderText(2, 0, (p) => '$p'), isNull);
  });

  test('reminderText mentions count and amount', () {
    final t = reminderText(3, 150000, (p) => 'Rs $p')!;
    expect(t.body, contains('3 logon'));
    expect(t.body, contains('Rs 150000'));
  });

  test('nextReminderTime is today if the hour is still ahead, else tomorrow', () {
    final morning = DateTime(2026, 11, 9, 8, 30);
    expect(nextReminderTime(morning, 10), DateTime(2026, 11, 9, 10));
    final noon = DateTime(2026, 11, 9, 12);
    expect(nextReminderTime(noon, 10), DateTime(2026, 11, 10, 10));
    final exact = DateTime(2026, 11, 9, 10);
    expect(nextReminderTime(exact, 10), DateTime(2026, 11, 10, 10));
  });

  test('clampHour keeps reminders in daytime', () {
    expect(clampHour(2), 6);
    expect(clampHour(23), 21);
    expect(clampHour(10), 10);
  });
}
