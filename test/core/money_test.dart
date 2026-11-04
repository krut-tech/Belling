import 'package:belling/core/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupees', () {
    test('formats 0 paise correctly', () {
      expect(formatRupees(0), equals('₹ 0.00'));
    });

    test('formats sub-rupee paise (99 paise) correctly', () {
      expect(formatRupees(99), equals('₹ 0.99'));
      expect(formatRupees(1), equals('₹ 0.01'));
      expect(formatRupees(10), equals('₹ 0.10'));
    });

    test('formats 100 paise (1 rupee) correctly', () {
      expect(formatRupees(100), equals('₹ 1.00'));
    });

    test('formats 100000 paise (1,000 rupees) correctly', () {
      expect(formatRupees(100000), equals('₹ 1,000.00'));
    });

    test('formats 123456700 paise (12,34,567 rupees) with Indian grouping', () {
      expect(formatRupees(123456700), equals('₹ 12,34,567.00'));
    });

    test('formats negative values correctly', () {
      expect(formatRupees(-50000), equals('-₹ 500.00'));
      expect(formatRupees(-123456700), equals('-₹ 12,34,567.00'));
      expect(formatRupees(-99), equals('-₹ 0.99'));
    });

    test('formats large numbers (1 crore rupees) correctly', () {
      expect(formatRupees(1000000000), equals('₹ 1,00,00,000.00'));
    });
  });

  group('parseRupeesToPaise', () {
    test('parses "12.5" to 1250 paise', () {
      expect(parseRupeesToPaise('12.5'), equals(1250));
    });

    test('parses "12.50" to 1250 paise', () {
      expect(parseRupeesToPaise('12.50'), equals(1250));
    });

    test('parses "12" to 1200 paise', () {
      expect(parseRupeesToPaise('12'), equals(1200));
    });

    test('parses "0.05" to 5 paise', () {
      expect(parseRupeesToPaise('0.05'), equals(5));
    });

    test('parses ".5" to 50 paise', () {
      expect(parseRupeesToPaise('.5'), equals(50));
    });

    test('returns null for invalid inputs', () {
      expect(parseRupeesToPaise('abc'), isNull);
      expect(parseRupeesToPaise('12.345'), isNull); // > 2 decimal places
      expect(parseRupeesToPaise('12.5.0'), isNull); // > 1 dot
      expect(parseRupeesToPaise(''), isNull);
      expect(parseRupeesToPaise('   '), isNull);
    });
  });

  group('parseUnitsToMilli & formatMilliUnits', () {
    test('parses unit strings correctly', () {
      expect(parseUnitsToMilli('5'), equals(5000));
      expect(parseUnitsToMilli('0.5'), equals(500));
      expect(parseUnitsToMilli('1.25'), equals(1250));
      expect(parseUnitsToMilli('1.001'), equals(1001));
      expect(parseUnitsToMilli('invalid'), isNull);
    });

    test('formats milli units correctly', () {
      expect(formatMilliUnits(5000), equals('5'));
      expect(formatMilliUnits(500), equals('0.5'));
      expect(formatMilliUnits(1250), equals('1.25'));
      expect(formatMilliUnits(0), equals('0'));
    });
  });

  group('formatPaiseToRupeesInput & formatGstRateBp', () {
    test('formats paise for input without currency symbol', () {
      expect(formatPaiseToRupeesInput(1250), equals('12.50'));
      expect(formatPaiseToRupeesInput(1200), equals('12.00'));
      expect(formatPaiseToRupeesInput(1200, forceDecimals: false), equals('12'));
      expect(formatPaiseToRupeesInput(0), equals('0.00'));
    });

    test('formats GST basis points to percentage string', () {
      expect(formatGstRateBp(1800), equals('18'));
      expect(formatGstRateBp(500), equals('5'));
      expect(formatGstRateBp(250), equals('2.5'));
      expect(formatGstRateBp(1200), equals('12'));
      expect(formatGstRateBp(1850), equals('18.5'));
    });
  });
}
