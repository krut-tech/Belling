/// Pure Dart shared GST calculation module.
///
/// Uses integer arithmetic exclusively (paise, milli-units, basis points).
/// No double math anywhere to avoid rounding and floating-point errors.
library;

/// Performs integer division with half-up rounding.
/// E.g. 5 / 10 -> 1 (0.5 rounds up to 1)
/// E.g. 4 / 10 -> 0 (0.4 rounds down to 0)
int divideRoundHalfUp(int numerator, int denominator) {
  if (numerator >= 0) {
    return (numerator + (denominator ~/ 2)) ~/ denominator;
  } else {
    return (numerator - (denominator ~/ 2)) ~/ denominator;
  }
}

class TaxLineInput {
  final int qtyMilli;
  final int ratePaise;
  final int discountPaise;
  final int gstRateBp;
  final bool priceIncludesTax;

  const TaxLineInput({
    required this.qtyMilli,
    required this.ratePaise,
    this.discountPaise = 0,
    required this.gstRateBp,
    this.priceIncludesTax = false,
  });
}

class TaxLineResult {
  final int qtyMilli;
  final int ratePaise;
  final int discountPaise;
  final int gstRateBp;
  final bool priceIncludesTax;
  final int taxablePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  final int lineTotalPaise;

  const TaxLineResult({
    required this.qtyMilli,
    required this.ratePaise,
    required this.discountPaise,
    required this.gstRateBp,
    required this.priceIncludesTax,
    required this.taxablePaise,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.lineTotalPaise,
  });
}

class TaxCalculationResult {
  final List<TaxLineResult> lines;
  final bool isInterState;
  final int taxablePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  final int totalBeforeRoundOffPaise;
  final int roundOffPaise;
  final int totalPaise;

  const TaxCalculationResult({
    required this.lines,
    required this.isInterState,
    required this.taxablePaise,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.totalBeforeRoundOffPaise,
    required this.roundOffPaise,
    required this.totalPaise,
  });
}

/// Calculates GST line-by-line and invoice totals using integer arithmetic only.
TaxCalculationResult calculateTax({
  required List<TaxLineInput> lines,
  required bool isInterState,
}) {
  final lineResults = <TaxLineResult>[];
  var totalTaxable = 0;
  var totalCgst = 0;
  var totalSgst = 0;
  var totalIgst = 0;

  for (final line in lines) {
    // 1. Gross amount in paise = (qtyMilli * ratePaise / 1000) rounded half up
    final grossPaise = divideRoundHalfUp(line.qtyMilli * line.ratePaise, 1000);
    final amountAfterDiscount = grossPaise - line.discountPaise;

    int taxablePaise;
    if (line.priceIncludesTax) {
      // If price includes tax: taxable = amount * 10000 / (10000 + gst_rate_bp)
      taxablePaise = divideRoundHalfUp(
        amountAfterDiscount * 10000,
        10000 + line.gstRateBp,
      );
    } else {
      taxablePaise = amountAfterDiscount;
    }

    // 2. Tax = round_half_up(taxable * gst_rate_bp / 10000)
    final taxPaise = divideRoundHalfUp(taxablePaise * line.gstRateBp, 10000);

    int cgstPaise = 0;
    int sgstPaise = 0;
    int igstPaise = 0;

    if (isInterState) {
      igstPaise = taxPaise;
    } else {
      cgstPaise = taxPaise ~/ 2;
      sgstPaise = taxPaise - cgstPaise;
    }

    final lineTotalPaise = taxablePaise + cgstPaise + sgstPaise + igstPaise;

    lineResults.add(
      TaxLineResult(
        qtyMilli: line.qtyMilli,
        ratePaise: line.ratePaise,
        discountPaise: line.discountPaise,
        gstRateBp: line.gstRateBp,
        priceIncludesTax: line.priceIncludesTax,
        taxablePaise: taxablePaise,
        cgstPaise: cgstPaise,
        sgstPaise: sgstPaise,
        igstPaise: igstPaise,
        lineTotalPaise: lineTotalPaise,
      ),
    );

    totalTaxable += taxablePaise;
    totalCgst += cgstPaise;
    totalSgst += sgstPaise;
    totalIgst += igstPaise;
  }

  final totalBeforeRoundOff = totalTaxable + totalCgst + totalSgst + totalIgst;
  // Nearest rupee in paise
  final nearestRupeePaise = divideRoundHalfUp(totalBeforeRoundOff, 100) * 100;
  final roundOffPaise = nearestRupeePaise - totalBeforeRoundOff;
  final totalPaise = totalBeforeRoundOff + roundOffPaise;

  return TaxCalculationResult(
    lines: lineResults,
    isInterState: isInterState,
    taxablePaise: totalTaxable,
    cgstPaise: totalCgst,
    sgstPaise: totalSgst,
    igstPaise: totalIgst,
    totalBeforeRoundOffPaise: totalBeforeRoundOff,
    roundOffPaise: roundOffPaise,
    totalPaise: totalPaise,
  );
}
