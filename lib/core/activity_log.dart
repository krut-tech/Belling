import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/records.dart';

/// Writes one line to the activity log (a synced record), e.g. who cancelled
/// a bill or gave a discount. Never throws: logging must not block the work.
Future<void> logActivity(RecordsRepository records, String action, String detail) async {
  try {
    String who = 'This phone';
    try {
      who = Supabase.instance.client.auth.currentUser?.email ?? who;
    } catch (_) {}
    await records.save(RecordKinds.activity, {
      'action': action,
      'detail': detail,
      'by': who,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
  } catch (e) {
    debugPrint('Activity log failed: $e');
  }
}
