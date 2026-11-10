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
    return res;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final client = _requireClient();
    final res = await client.auth.signInWithPassword(email: email, password: password);
    return res;
  }

  /// Deep link registered in AndroidManifest and in Supabase > Auth > URL
  /// Configuration > Redirect URLs.
  static const String oauthRedirect = 'io.supabase.belling://login-callback/';

  /// Opens the Google sign-in page in the browser. The session arrives later
  /// through the deep link; wait for it with [waitForSignIn].
  Future<void> startGoogleSignIn() async {
    final client = _requireClient();
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: oauthRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<bool> waitForSignIn({Duration timeout = const Duration(minutes: 3)}) async {
    final client = _requireClient();
    if (client.auth.currentSession != null) return true;
    try {
      await client.auth.onAuthStateChange
          .firstWhere((s) => s.event == AuthChangeEvent.signedIn && s.session != null)
          .timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
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
    // Rejected commands are also unsynced data: signing out must warn about them.
    final rows = await (db.select(db.outboxCommands)
          ..where((t) => t.status.equals('pending') | t.status.equals('rejected')))
        .get();
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
    // Sign-up with "Confirm email" on gives a user but no session yet: nothing
    // can be created on the server until the user signs in.
    if (client.auth.currentSession == null) return null;

    final rekeyResult = await rekeyService.rekeyIfNeeded();
    final localBus = await (db.select(db.businesses)..where((t) => t.id.equals(rekeyResult.newBusinessId))).getSingle();

    // Check if user already owns a business on server
    try {
      final existingBusinesses = await client.from('businesses').select().limit(1);
      if (existingBusinesses.isNotEmpty) {
        final serverBus = Map<String, dynamic>.from(existingBusinesses.first as Map);
        final serverBusId = serverBus['id'] as String;

        if (serverBusId != localBus.id) {
          // Adopting wipes local data, so refuse if anything local would be lost:
          // issued documents, or any command that has not reached the server.
          final issuedDocs = await (db.select(db.documents)..where((t) => t.status.equals('issued'))).get();
          final unsynced = await (db.select(db.outboxCommands)
                ..where((t) => t.status.equals('pending') | t.status.equals('rejected')))
              .get();
          final hasLocalProducts = (await (db.select(db.products)..limit(1)).get()).isNotEmpty;
          final hasLocalParties = (await (db.select(db.parties)..limit(1)).get()).isNotEmpty;
          final canAdopt = issuedDocs.isEmpty &&
              unsynced.isEmpty &&
              !hasLocalProducts &&
              !hasLocalParties;
          if (!canAdopt && await _serverHasNoDocuments(client, serverBusId)) {
            // The account's business is empty: keep this phone's data and
            // simply attach it to that business (nothing is deleted).
            await mergeLocalIntoServer(serverBus);
            return null;
          }
          return ExistingBusinessChoice(serverBusiness: serverBus, canAdopt: canAdopt);
        }
      }
    } on PostgrestException catch (e) {
      throw StateError('Could not check your business on the server: ${e.message}');
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
    } on PostgrestException catch (e) {
      // 23505 = this business already exists on the server (signing in again
      // on the same phone). Anything else must be shown, not hidden.
      if (e.code != '23505') {
        throw StateError('Could not create your business on the server: ${e.message}');
      }
    }

    await registerDeviceAndAssignPrefix(localBus.id, rekeyResult.newDeviceId);
    return null;
  }

  Future<bool> _serverHasNoDocuments(SupabaseClient client, String businessId) async {
    try {
      final rows = await client.from('documents').select('id').eq('business_id', businessId).limit(1);
      return (rows as List).isEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Keeps all local data and attaches it to the account's existing business.
  Future<void> mergeLocalIntoServer(Map<String, dynamic> serverBusiness) async {
    final serverBusId = serverBusiness['id'] as String;
    await rekeyService.mergeIntoBusiness(serverBusId);
    final dev = await (db.select(db.devices)..limit(1)).getSingleOrNull();
    if (dev == null) throw StateError('Device not found');
    await registerDeviceAndAssignPrefix(serverBusId, dev.id);
  }

  /// Fixes "Business does not exist on server" / "row-level security" errors:
  /// when the phone's business id differs from the account's business, merge.
  /// Returns true if something was fixed.
  Future<bool> fixBusinessMismatch() async {
    final client = supabaseClient;
    if (client == null || client.auth.currentSession == null) {
      throw StateError('Pehle sign in karo (More > Backup & Sync)');
    }
    final local = await (db.select(db.businesses)..limit(1)).getSingleOrNull();
    if (local == null) return false;
    final rows = await client.from('businesses').select().limit(1);
    if (rows.isEmpty) {
      // The account has no business yet: create it from this phone's data.
      await client.rpc('create_business', params: {
        'p_id': local.id,
        'p_name': local.name,
        'p_state_code': local.stateCode,
        'p_gstin': local.gstin,
        'p_address': local.address,
      });
      final dev = await (db.select(db.devices)..limit(1)).getSingleOrNull();
      if (dev != null) await registerDeviceAndAssignPrefix(local.id, dev.id);
      await (db.update(db.outboxCommands)..where((t) => t.status.equals('rejected'))).write(
        const OutboxCommandsCompanion(status: Value('pending'), lastError: Value(null)),
      );
      return true;
    }
    final serverBus = Map<String, dynamic>.from(rows.first as Map);
    if (serverBus['id'] == local.id) {
      await (db.update(db.outboxCommands)..where((t) => t.status.equals('rejected'))).write(
        const OutboxCommandsCompanion(status: Value('pending'), lastError: Value(null)),
      );
      return true;
    }
    await mergeLocalIntoServer(serverBus);
    return true;
  }

  /// Adopts server business when user chooses "Use my existing business".
  /// Clears local seed data and sets local business ID to server business ID.
  Future<void> adoptServerBusiness(Map<String, dynamic> serverBusiness) async {
    final serverBusId = serverBusiness['id'] as String;

    await db.transaction(() async {
      // PRAGMA foreign_keys cannot be changed inside a transaction: defer the
      // checks to COMMIT. The immutability triggers must be dropped to clear
      // local data and are recreated before the commit.
      await db.customStatement('PRAGMA defer_foreign_keys = ON;');
      await db.dropTriggers();

      // Clear local seed data (children first)
      await db.delete(db.documentLines).go();
      await db.delete(db.payments).go();
      await db.delete(db.stockMovements).go();
      await db.delete(db.documents).go();
      await db.delete(db.documentSeries).go();
      await db.delete(db.draftCarts).go();
      await db.delete(db.outboxCommands).go();
      await db.delete(db.products).go();
      await db.delete(db.parties).go();

      // Replace business record
      await db.delete(db.businesses).go();
      await db.into(db.businesses).insert(
            BusinessesCompanion.insert(
              id: serverBusId,
              businessId: serverBusId,
              name: serverBusiness['name'] as String? ?? 'My Business',
              gstin: Value(serverBusiness['gstin'] as String?),
              stateCode: serverBusiness['state_code'] as String? ?? '24',
              address: serverBusiness['address'] as String? ?? '',
              upiId: Value(serverBusiness['upi_id'] as String?),
              invoiceTerms: Value(serverBusiness['invoice_terms'] as String?),
              createdAt: DateTime.now(),
            ),
          );

      // Keep this phone's device row, but attach it to the server business.
      await db.update(db.devices).write(DevicesCompanion(businessId: Value(serverBusId)));

      await db.createTriggers();
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
    String? ownRegisteredPrefix;

    if (client != null) {
      try {
        final rows = await client.from('devices').select('id, series_prefix').eq('business_id', businessId);
        for (final r in rows as List) {
          if (r['id'] == deviceId) {
            ownRegisteredPrefix = r['series_prefix'] as String?;
          } else {
            takenPrefixes.add(r['series_prefix'] as String);
          }
        }
      } catch (e) {
        // Do not guess a prefix without knowing which ones other devices use:
        // two devices with the same prefix would issue duplicate numbers.
        throw StateError('Could not read device list from the server: $e');
      }
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

    // Never renumber a device that already has a prefix: invoices were issued with it.
    if (ownRegisteredPrefix != null) {
      nextPrefix = ownRegisteredPrefix;
    } else if (localDev != null && !takenPrefixes.contains(localDev.seriesPrefix)) {
      nextPrefix = localDev.seriesPrefix;
    }

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
