import 'package:belling/core/categories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('split and join', () {
    final p = splitCategory('Books>Copies');
    expect(p.parent, 'Books');
    expect(p.child, 'Copies');
    expect(joinCategory('Books', 'Copies'), 'Books > Copies');
    expect(splitCategory('  ').parent, '');
    expect(splitCategory('Pens').child, isNull);
    expect(normalizeCategory(' Books >  '), 'Books');
  });
}
