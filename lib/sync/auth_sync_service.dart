import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import 'rekey_service.dart';

class ExistingBusinessChoice {
  final Map<String, dynamic> serverBusiness;
  final bool canAdopt;

  ExistingBusinessChoice({
    required this.serverBusiness,
    required this.canAdopt,
  });
}

class PendingCommandsException implements Exception {
  final int pendingCount;
  PendingCommandsException(this.pendingCount);

  @override
  String toString() => 'You have $pendingCount pending command(s) that have not been synced.';
}

class AuthSyncService {
  final AppDatabase db;
  final SupabaseClient? supabaseClient;
  final RekeyService rekeyService;

  AuthSyncService({
    required this.db,
    SupabaseClient? supabaseClient,
    RekeyService? rekeyService,
  })  : supabaseClient = supabaseClient ?? _tryGetSupabase(),
        rekeyService = rekeyService ?? RekeyService(db);

  static SupabaseClient? _tryGetSupabase() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => supabaseClient?.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<AuthResponse> signUp(String email, String password) async {
    final client = _requireClient();
    final res = await client.auth.signUp(email: email, password: password);
    if (res.user != null) {
      await onSignedIn();
    }
    return res;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final client = _requireClient();
    final res = await client.auth.signInWithPassword(email: email, password: password);
    if (res.user != null) {
      await onSignedIn();
    }
    return res;
  }

  Future<void> signOut({bool force = false}) async {
    final client = _requireClient();
    if (!force) {
      final pendingCount = await _getPendingCount();
      if (pendingCount > 0) {
        throw PendingCommandsException(pendingCount);
      }
    }
    await client.auth.signOut();
  }

  Future<int> _getPendingCount() async {
    final rows = await (db.select(db.outboxCommands)..where((t) => t.status.equals('pending'))).get();
    return rows.length;
  }

  SupabaseClient _requireClient() {
    final client = supabaseClient;
    if (client == null) {
      throw StateError('Supabase is not initialized (offline)');
    }
    return client;
  }

  /// Called after successful sign-in or sign-up.
  /// 1. Rekey local IDs if needed.
  /// 2. Check server for existing business or call RPC `create_business`.
  /// 3. Determine and assign unique device series prefix.
  Future<ExistingBusinessChoice?> onSignedIn() async {
    final client = supabaseClient;
    if (client == null) return null;

    final rekeyResult = await rekeyService.rekeyIfNeeded();
    final localBus = await (db.select(db.businesses)..where((t) => t.id.equals(rekeyResult.newBusinessId))).getSingle();

    // Check if user already owns a business on server
    try {
      final existingBusinesses = await client.from('businesses').select().limit(1);
      if (existingBusinesses.isNotEmpty) {
        final serverBus = Map<String, dynamic>.from(existingBusinesses.first as Map);
        final serverBusId = serverBus['id'] as String;

        if (serverBusId != localBus.id) {
          final issuedDocs = await (db.select(db.documents)..where((t) => t.status.equals('issued'))).get();
          final canAdopt = issuedDocs.isEmpty;
          return ExistingBusinessChoice(serverBusiness: serverBus, canAdopt: canAdopt);
        }
      }
    } catch (_) {
      // Ignore query failure (e.g. table empty or RPC handles creation)
    }

    // Call RPC create_business
    try {
      await client.rpc('create_business', params: {
        'p_id': localBus.id,
        'p_name': localBus.name,
        'p_state_code': localBus.stateCode,
        'p_gstin': localBus.gstin,
        'p_address': localBus.address,
      });
    } catch (_) {
      // RPC call warning/handled on server
    }

    await registerDeviceAndAssignPrefix(localBus.id, rekeyResult.newDeviceId);
    return null;
  }

  /// Adopts server business when user chooses "Use my existing business".
  /// Clears local seed data and sets local business ID to server business ID.
  Future<void> adoptServerBusiness(Map<String, dynamic> serverBusiness) async {
    final serverBusId = serverBusiness['id'] as String;

    await db.transaction(() async {
      await db.customStatement('PRAGMA foreign_keys = OFF;');

      // Clear local seed data
      await db.delete(db.products).go();
      await db.delete(db.parties).go();
      await db.delete(db.draftCarts).go();
      await db.delete(db.outboxCommands).go();
      await db.delete(db.documents).go();
      await db.delete(db.documentLines).go();
      await db.delete(db.payments).go();
      await db.delete(db.stockMovements).go();
      await db.delete(db.documentSeries).go();

      // Replace business record
      await db.delete(db.businesses).go();
      await db.into(db.businesses).insert(
            BusinessesCompanion.insert(
              id: serverBusId,
              businessId: serverBusId,
              name: serverBusiness['name'] as String? ?? 'My Business',
              gstin: Value(serverBusiness['gstin'] as String?),
              stateCode: serverBusiness['state_code'] as String? ?? '27',
              address: serverBusiness['address'] as String? ?? '',
              upiId: Value(serverBusiness['upi_id'] as String?),
              invoiceTerms: Value(serverBusiness['invoice_terms'] as String?),
              createdAt: DateTime.now(),
            ),
          );

      await db.customStatement('PRAGMA foreign_keys = ON;');
    });

    final currentDev = await (db.select(db.devices)..limit(1)).getSingleOrNull();
    if (currentDev == null) {
      throw StateError('Device not found');
    }
    await registerDeviceAndAssignPrefix(serverBusId, currentDev.id);
  }

  /// Picks the next free device series prefix letter A, B, C... for the business and registers device.
  Future<void> registerDeviceAndAssignPrefix(String businessId, String deviceId) async {
    final client = supabaseClient;
    Set<String> takenPrefixes = {};

    if (client != null) {
      try {
        final rows = await client.from('devices').select('series_prefix').eq('business_id', businessId);
        takenPrefixes = (rows as List).map((r) => r['series_prefix'] as String).toSet();
      } catch (_) {}
    }

    String nextPrefix = 'A';
    for (var code = 65; code <= 90; code++) {
      final letter = String.fromCharCode(code);
      if (!takenPrefixes.contains(letter)) {
        nextPrefix = letter;
        break;
      }
    }

    final localDev = await (db.select(db.devices)..where((t) => t.id.equals(deviceId))).getSingleOrNull();
    final now = DateTime.now();

    if (localDev != null) {
      await (db.update(db.devices)..where((t) => t.id.equals(deviceId))).write(
        DevicesCompanion(
          businessId: Value(businessId),
          seriesPrefix: Value(nextPrefix),
          updatedAt: Value(now),
        ),
      );
    }

    final updatedDev = await (db.select(db.devices)..where((t) => t.id.equals(deviceId))).getSingleOrNull();
    if (updatedDev == null) {
      throw StateError('Device not found');
    }
    await db.enqueueOutboxCommand(
      businessId: businessId,
      deviceId: deviceId,
      commandType: 'upsert_device',
      payload: deviceToPayload(updatedDev),
    );
  }
}
