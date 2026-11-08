import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';

enum ProfileSyncResult {
  /// Nothing to do (offline, not signed in, or nothing worth saving yet).
  none,

  /// The account's saved details were applied to this phone.
  restored,

  /// This phone's details were saved to the account.
  uploaded,
}

/// True while the business profile is still the untouched first-run seed.
bool isDefaultBusinessProfile({required String name, String? gstin, String? upiId}) {
  final n = name.trim().toLowerCase();
  final seedName = n.isEmpty || n == 'my business';
  return seedName && (gstin ?? '').trim().isEmpty && (upiId ?? '').trim().isEmpty;
}

/// Keeps the important shop details (name, GSTIN, state, address, UPI id,
/// invoice terms) in the user's account, so signing in on a new phone (or after
/// a reinstall) brings them back. It is independent of the document sync, so
/// it works even when this phone's business id differs from the cloud one.
class ProfileSyncService {
  ProfileSyncService({required this.db, SupabaseClient? client}) : client = client ?? _tryClient();

  final AppDatabase db;
  final SupabaseClient? client;

  static SupabaseClient? _tryClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => client?.auth.currentUser?.id;

  Future<Business?> _localBusiness() async {
    final rows = await db.select(db.businesses).get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Call right after sign-in. Restores the account's details when this phone
  /// still has the default profile; otherwise saves this phone's details.
  /// Never throws.
  Future<ProfileSyncResult> syncOnSignIn() async {
    try {
      final c = client;
      final uid = _userId;
      if (c == null || uid == null) return ProfileSyncResult.none;
      final local = await _localBusiness();
      if (local == null) return ProfileSyncResult.none;

      final row = await c.from('business_profiles').select().eq('user_id', uid).maybeSingle();
      final localIsDefault =
          isDefaultBusinessProfile(name: local.name, gstin: local.gstin, upiId: local.upiId);

      if (row != null && localIsDefault) {
        final dev = await (db.select(db.devices)..limit(1)).getSingleOrNull();
        if (dev == null) return ProfileSyncResult.none;
        await db.upsertBusinessSettings(
          businessId: local.id,
          deviceId: dev.id,
          name: (row['business_name'] as String?)?.trim().isNotEmpty == true
              ? (row['business_name'] as String).trim()
              : local.name,
          gstin: _nullIfEmpty(row['gstin'] as String?),
          stateCode: _nullIfEmpty(row['state_code'] as String?) ?? local.stateCode,
          address: (row['address'] as String?) ?? local.address,
          upiId: _nullIfEmpty(row['upi_id'] as String?),
          invoiceTerms: _nullIfEmpty(row['invoice_terms'] as String?),
        );
        return ProfileSyncResult.restored;
      }

      if (!localIsDefault) {
        await _upsert(c, uid, local);
        return ProfileSyncResult.uploaded;
      }
      return ProfileSyncResult.none;
    } catch (e) {
      debugPrint('Profile sync on sign-in failed: $e');
      return ProfileSyncResult.none;
    }
  }

  /// Call after the user saves business settings. Best effort, never throws.
  Future<void> pushCurrent() async {
    try {
      final c = client;
      final uid = _userId;
      if (c == null || uid == null) return;
      final local = await _localBusiness();
      if (local == null) return;
      await _upsert(c, uid, local);
    } catch (e) {
      debugPrint('Profile push failed: $e');
    }
  }

  Future<void> _upsert(SupabaseClient c, String uid, Business b) {
    return c.from('business_profiles').upsert({
      'user_id': uid,
      'business_name': b.name,
      'gstin': _nullIfEmpty(b.gstin),
      'state_code': b.stateCode,
      'address': b.address,
      'upi_id': _nullIfEmpty(b.upiId),
      'invoice_terms': _nullIfEmpty(b.invoiceTerms),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  static String? _nullIfEmpty(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
