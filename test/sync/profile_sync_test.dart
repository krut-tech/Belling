import 'package:belling/sync/profile_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isDefaultBusinessProfile', () {
    test('untouched seed is default', () {
      expect(isDefaultBusinessProfile(name: 'My Business'), isTrue);
      expect(isDefaultBusinessProfile(name: ' my business ', gstin: '', upiId: ' '), isTrue);
      expect(isDefaultBusinessProfile(name: ''), isTrue);
    });
    test('any real detail makes it non-default', () {
      expect(isDefaultBusinessProfile(name: 'disha stationary'), isFalse);
      expect(isDefaultBusinessProfile(name: 'My Business', gstin: '24ABCDE1234F1Z5'), isFalse);
      expect(isDefaultBusinessProfile(name: 'My Business', upiId: 'shop@upi'), isFalse);
    });
  });
}
