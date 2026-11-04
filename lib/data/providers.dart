import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'repositories/document_repository.dart';
import 'repositories/party_repository.dart';
import 'repositories/product_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

const kLocalBusinessId = 'local-business';
const kLocalDeviceId = 'local-device';

/// Stream of active business row in local DB
final activeBusinessProvider = StreamProvider<Business?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.businesses)..limit(1)).watchSingleOrNull();
});

/// Stream of active device row in local DB
final activeDeviceProvider = StreamProvider<Device?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.devices)..limit(1)).watchSingleOrNull();
});

final currentBusinessIdProvider = Provider<String>((ref) {
  final bus = ref.watch(activeBusinessProvider).valueOrNull;
  return bus?.id ?? kLocalBusinessId;
});

final currentDeviceIdProvider = Provider<String>((ref) {
  final dev = ref.watch(activeDeviceProvider).valueOrNull;
  return dev?.id ?? kLocalDeviceId;
});

/// Provider that seeds default business and device on first launch
final initializeAppProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  await db.ensureBootstrapData();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  final deviceId = ref.watch(currentDeviceIdProvider);
  return ProductRepository(db, businessId, deviceId);
});

/// Provider for watching the products stream with search filter
final productsStreamProvider = StreamProvider.family<List<ProductWithStock>, String>((ref, search) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProducts(search: search);
});

final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  final deviceId = ref.watch(currentDeviceIdProvider);
  return PartyRepository(db, businessId, deviceId);
});

final partiesStreamProvider = StreamProvider.family<List<Party>, String>((ref, search) {
  final repo = ref.watch(partyRepositoryProvider);
  return repo.watchParties(search: search);
});

final partiesWithBalanceStreamProvider = StreamProvider.family<List<PartyWithBalance>, String>((ref, search) {
  final repo = ref.watch(partyRepositoryProvider);
  return repo.watchPartiesWithBalance(search: search);
});

final partyLedgerStreamProvider = StreamProvider.family<List<LedgerItem>, String>((ref, partyId) {
  final repo = ref.watch(partyRepositoryProvider);
  return repo.watchPartyLedger(partyId);
});

final partyBalanceStreamProvider = StreamProvider.family<int, String>((ref, partyId) {
  final repo = ref.watch(partyRepositoryProvider);
  return repo.watchPartyBalancePaise(partyId);
});

final partyStreamProvider = StreamProvider.family<Party?, String>((ref, partyId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.parties)..where((tbl) => tbl.id.equals(partyId))).watchSingleOrNull();
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  final deviceId = ref.watch(currentDeviceIdProvider);
  return DocumentRepository(db, businessId, deviceId);
});

final todayDocumentsStreamProvider = StreamProvider<List<DocumentWithParty>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchTodayDocuments();
});

final currentBusinessStreamProvider = StreamProvider<Business?>((ref) {
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return (db.select(db.businesses)..where((tbl) => tbl.id.equals(businessId))).watchSingleOrNull();
});
