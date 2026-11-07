import 'package:belling/features/items/barcode_scanner_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isPlausibleBarcode', () {
    test('accepts a valid EAN-13 (the perfume barcode)', () {
      expect(isPlausibleBarcode('8901277016348'), isTrue);
    });

    test('rejects an EAN-13 with a wrong check digit (misread)', () {
      expect(isPlausibleBarcode('8901277016349'), isFalse);
      expect(isPlausibleBarcode('8901277016340'), isFalse);
    });

    test('accepts valid UPC-A and EAN-8', () {
      expect(isPlausibleBarcode('036000291452'), isTrue);
      expect(isPlausibleBarcode('96385074'), isTrue);
    });

    test('rejects invalid UPC-A', () {
      expect(isPlausibleBarcode('036000291453'), isFalse);
    });

    test('non-numeric and odd-length codes are not checked', () {
      expect(isPlausibleBarcode('ABC-123'), isTrue);
      expect(isPlausibleBarcode('12345'), isTrue);
      expect(isPlausibleBarcode('   '), isFalse);
    });
  });
}
