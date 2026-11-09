import 'package:belling/core/app_lock.dart';
import 'package:belling/core/csv_parse.dart';
import 'package:belling/core/items_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseCsv handles quotes, commas and CRLF', () {
    final r = parseCsv('a,b\r\n"x, y",2\r\n');
    expect(r[0], ['a', 'b']);
    expect(r[1], ['x, y', '2']);
  });

  test('template parses with no problems', () {
    final p = parseItemsCsv(kItemsCsvTemplate);
    expect(p.problems, isEmpty);
    expect(p.items.length, 2);
  });

  test('values converted to paise / milli', () {
    final p = parseItemsCsv('name,hsn,gst_percent,price,stock\nRice,1006,5,420.50,10\n');
    expect(p.items.single.pricePaise, 42050);
    expect(p.items.single.gstRateBp, 500);
    expect(p.items.single.openingStockMilli, 10000);
  });

  test('missing name column reports a problem', () {
    final p = parseItemsCsv('foo,bar\n1,2\n');
    expect(p.items, isEmpty);
    expect(p.problems, isNotEmpty);
  });

  test('pin validation and hashing', () {
    expect(isValidPin('1234'), isTrue);
    expect(isValidPin('123'), isFalse);
    expect(isValidPin('12a4'), isFalse);
    expect(hashPin('1234', 's'), hashPin('1234', 's'));
    expect(hashPin('1234', 's'), isNot(hashPin('1234', 't')));
  });
}
