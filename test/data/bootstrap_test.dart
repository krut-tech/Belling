import 'package:belling/data/database.dart';
import 'package:belling/sync/rekey_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('bootstrap seeds exactly one business and one device', () async {
    await db.ensureBootstrapData();
    await db.ensureBootstrapData(); // idempotent

    final businesses = await db.select(db.businesses).get();
    final devices = await db.select(db.devices).get();

    expect(businesses.length, 1);
    expect(devices.length, 1);
    expect(devices.first.businessId, businesses.first.id);
  });

  test('bootstrap does not create a second business after the ids were rekeyed', () async {
    await db.ensureBootstrapData();
    final rekeyed = await RekeyService(db).rekeyIfNeeded();

    // what happens on the next app start
    await db.ensureBootstrapData();

    final businesses = await db.select(db.businesses).get();
    final devices = await db.select(db.devices).get();

    expect(businesses.length, 1);
    expect(businesses.first.id, rekeyed.newBusinessId);
    expect(devices.length, 1);
    expect(devices.first.id, rekeyed.newDeviceId);
  });
}
