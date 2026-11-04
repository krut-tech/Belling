/// Formats money stored in integer paise using Indian digit grouping format.
///
/// Money is always stored as integer paise to prevent floating-point inaccuracies.
/// Example: 123456700 paise -> "₹ 12,34,567.00"
/// Example: 99 paise -> "₹ 0.99"
/// Example: 0 paise -> "₹ 0.00"
/// Example: -50000 paise -> "-₹ 500.00"
String formatRupees(int paise) {
  final isNegative = paise < 0;
  final absPaise = paise.abs();

  final rupees = absPaise ~/ 100;
  final remainingPaise = absPaise % 100;

  final rupeesFormatted = _formatIndianGrouping(rupees);
  final paiseFormatted = remainingPaise.toString().padLeft(2, '0');

  final prefix = isNegative ? '-₹ ' : '₹ ';
  return '$prefix$rupeesFormatted.$paiseFormatted';
}

/// Formats integer rupees according to Indian digit grouping:
/// Rightmost 3 digits grouped together, then subsequent digits grouped in pairs.
String _formatIndianGrouping(int number) {
  final str = number.toString();
  if (str.length <= 3) {
    return str;
  }

  final lastThree = str.substring(str.length - 3);
  final remaining = str.substring(0, str.length - 3);

  final buffer = StringBuffer();
  var count = 0;
  for (var i = remaining.length - 1; i >= 0; i--) {
    if (count > 0 && count % 2 == 0) {
      buffer.write(',');
    }
    buffer.write(remaining[i]);
    count++;
  }

  final formattedRemaining = buffer.toString().split('').reversed.join('');
  return '$formattedRemaining,$lastThree';
}

/// Parses a string in Rupees (e.g. "12.5", "12.50", "12", "0.05")
/// into integer paise using ONLY integer string parsing (no floating-point double).
///
/// Returns null if the input is empty or invalid.
int? parseRupeesToPaise(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  var s = trimmed;
  var isNegative = false;
  if (s.startsWith('-')) {
    isNegative = true;
    s = s.substring(1).trim();
  }

  final dotCount = '.'.allMatches(s).length;
  if (dotCount > 1) return null;

  final parts = s.split('.');
  final rupeesStr = parts[0];
  final paiseStr = parts.length > 1 ? parts[1] : '';

  if (rupeesStr.isNotEmpty && !RegExp(r'^\d+$').hasMatch(rupeesStr)) {
    return null;
  }
  if (paiseStr.isNotEmpty && !RegExp(r'^\d+$').hasMatch(paiseStr)) {
    return null;
  }

  final rupees = rupeesStr.isEmpty ? 0 : int.tryParse(rupeesStr);
  if (rupees == null) return null;

  int paise;
  if (paiseStr.isEmpty) {
    paise = 0;
  } else if (paiseStr.length == 1) {
    paise = (int.tryParse(paiseStr) ?? 0) * 10;
  } else if (paiseStr.length == 2) {
    paise = int.tryParse(paiseStr) ?? 0;
  } else {
    // More than 2 decimal places is invalid for currency paise
    return null;
  }

  final totalPaise = rupees * 100 + paise;
  return isNegative ? -totalPaise : totalPaise;
}

/// Parses quantity in units to thousandths (milli-units).
/// 1 unit = 1000 milli-units. E.g. "5" -> 5000, "0.5" -> 500, "1.25" -> 1250.
/// Uses ONLY integer parsing (no double).
int? parseUnitsToMilli(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  var s = trimmed;
  var isNegative = false;
  if (s.startsWith('-')) {
    isNegative = true;
    s = s.substring(1).trim();
  }

  final dotCount = '.'.allMatches(s).length;
  if (dotCount > 1) return null;

  final parts = s.split('.');
  final wholeStr = parts[0];
  final fracStr = parts.length > 1 ? parts[1] : '';

  if (wholeStr.isNotEmpty && !RegExp(r'^\d+$').hasMatch(wholeStr)) {
    return null;
  }
  if (fracStr.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fracStr)) {
    return null;
  }

  final whole = wholeStr.isEmpty ? 0 : int.tryParse(wholeStr);
  if (whole == null) return null;

  int milli;
  if (fracStr.isEmpty) {
    milli = 0;
  } else if (fracStr.length == 1) {
    milli = (int.tryParse(fracStr) ?? 0) * 100;
  } else if (fracStr.length == 2) {
    milli = (int.tryParse(fracStr) ?? 0) * 10;
  } else if (fracStr.length == 3) {
    milli = int.tryParse(fracStr) ?? 0;
  } else {
    return null;
  }

  final totalMilli = whole * 1000 + milli;
  return isNegative ? -totalMilli : totalMilli;
}

/// Formats thousandths (milli-units) to a human-readable string.
String formatMilliUnits(int milli) {
  final isNegative = milli < 0;
  final absMilli = milli.abs();
  final whole = absMilli ~/ 1000;
  final frac = absMilli % 1000;

  if (frac == 0) {
    return isNegative ? '-$whole' : '$whole';
  }

  var fracStr = frac.toString().padLeft(3, '0');
  while (fracStr.endsWith('0')) {
    fracStr = fracStr.substring(0, fracStr.length - 1);
  }

  final result = '$whole.$fracStr';
  return isNegative ? '-$result' : result;
}

/// Formats integer paise into a standard decimal string (e.g. 1250 -> "12.50").
/// Useful for prefilling input fields without using double division.
String formatPaiseToRupeesInput(int paise, {bool forceDecimals = true}) {
  final isNegative = paise < 0;
  final absPaise = paise.abs();
  final rupees = absPaise ~/ 100;
  final remainingPaise = absPaise % 100;
  final prefix = isNegative ? '-' : '';

  if (!forceDecimals && remainingPaise == 0) {
    return '$prefix$rupees';
  }

  final paiseFormatted = remainingPaise.toString().padLeft(2, '0');
  return '$prefix$rupees.$paiseFormatted';
}

/// Formats GST rate stored in basis points (1/100th of 1%) to a percentage string.
/// E.g. 1800 -> "18", 250 -> "2.5", 500 -> "5", 1200 -> "12", 1850 -> "18.5"
String formatGstRateBp(int bp) {
  final whole = bp ~/ 100;
  final remainder = bp % 100;
  if (remainder == 0) {
    return '$whole';
  } else if (remainder % 10 == 0) {
    return '$whole.${remainder ~/ 10}';
  } else {
    return '$whole.${remainder.toString().padLeft(2, '0')}';
  }
}

