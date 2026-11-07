import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import '../data/providers.dart';
import 'auth_sync_service.dart';
import 'pull_service.dart';
import 'push_worker.dart';
import 'supabase_sync_remote.dart';
import 'sync_remote.dart';

final syncRemoteProvider = Provider<SyncRemote>((ref) {
  try {
    return SupabaseSyncRemote(Supabase.instance.client);
  } catch (_) {
    throw StateError('Supabase is not initialized');
  }
});

final authSyncServiceProvider = Provider<AuthSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthSyncService(db: db);
});

final pushWorkerProvider = Provider<PushWorker>((ref) {
  final db = ref.watch(databaseProvider);
  final remote = ref.watch(syncRemoteProvider);
  final worker = PushWorker(db: db, remote: remote);
  worker.start();
  ref.onDispose(() => worker.stop());
  return worker;
});

final pullWorkerProvider = Provider<PullWorker>((ref) {
  final db = ref.watch(databaseProvider);
  final remote = ref.watch(syncRemoteProvider);
  if (remote is! PullRemote) {
    throw StateError('Remote does not support pulling');
  }
  final client = Supabase.instance.client;
  final worker = PullWorker(
    service: PullService(db, remote as PullRemote),
    triggers: [
      // pull right after sign-in / token refresh
      client.auth.onAuthStateChange.map((_) {}),
      Connectivity().onConnectivityChanged.where((r) => r.any((c) => c != ConnectivityResult.none)).map((_) {}),
    ],
  );
  worker.start();
  ref.onDispose(worker.stop);
  return worker;
});

/// Starts the push worker as soon as the app is running, so queued commands
/// are sent without the user opening the sync screen. Never throws: sync is
/// optional and must not stop the app (e.g. Supabase could not initialise).
final syncBootstrapProvider = Provider<void>((ref) {
  try {
    ref.watch(pushWorkerProvider);
  } catch (e) {
    debugPrint('Background push not started: $e');
  }
  try {
    ref.watch(pullWorkerProvider);
  } catch (e) {
    debugPrint('Background pull not started: $e');
  }
});

final outboxCommandsStreamProvider = StreamProvider<List<OutboxCommand>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.outboxCommands).watch();
});

enum SyncStatusType {
  signInToSync,
  offline,
  synced,
  pending,
  error,
}

class SyncStatusState {
  final SyncStatusType type;
  final int pendingCount;
  final List<OutboxCommand> rejectedCommands;

  const SyncStatusState({
    required this.type,
    this.pendingCount = 0,
    this.rejectedCommands = const [],
  });
}

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Emits on every sign-in / sign-out / token refresh so the UI that depends on
/// "am I signed in" (sync chip, backup page) rebuilds instead of staying stale.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  try {
    return Supabase.instance.client.auth.onAuthStateChange;
  } catch (_) {
    return const Stream<AuthState>.empty();
  }
});

final syncStatusProvider = Provider<SyncStatusState>((ref) {
  ref.watch(authStateChangesProvider);
  final authService = ref.watch(authSyncServiceProvider);
  if (!authService.isSignedIn) {
    return const SyncStatusState(type: SyncStatusType.signInToSync);
  }

  final connectivity = ref.watch(connectivityStreamProvider).valueOrNull;
  final isOffline = connectivity != null && connectivity.every((r) => r == ConnectivityResult.none);
  if (isOffline) {
    return const SyncStatusState(type: SyncStatusType.offline);
  }

  final outbox = ref.watch(outboxCommandsStreamProvider).valueOrNull ?? [];
  final rejected = outbox.where((c) => c.status == 'rejected').toList();
  if (rejected.isNotEmpty) {
    return SyncStatusState(type: SyncStatusType.error, rejectedCommands: rejected);
  }

  final pendingCount = outbox.where((c) => c.status == 'pending').length;
  if (pendingCount > 0) {
    return SyncStatusState(type: SyncStatusType.pending, pendingCount: pendingCount);
  }

  return const SyncStatusState(type: SyncStatusType.synced);
});
