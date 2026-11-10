// Pure helpers for the extra business features (no database, easy to test).

/// Splits [totalDiscountPaise] across lines in proportion to each line's
/// amount; the rounding remainder goes to the last non-empty line. A line is
/// never discounted by more than its own amount. Sum of result == discount
/// (capped at the sum of amounts).
List<int> distributeDiscount(List<int> lineAmountsPaise, int totalDiscountPaise) {
  final total = lineAmountsPaise.fold<int>(0, (a, b) => a + b);
  if (total <= 0 || totalDiscountPaise <= 0) return List.filled(lineAmountsPaise.length, 0);
  final discount = totalDiscountPaise > total ? total : totalDiscountPaise;
  final out = List<int>.filled(lineAmountsPaise.length, 0);
  var given = 0;
  var lastIdx = -1;
  for (var i = 0; i < lineAmountsPaise.length; i++) {
    final a = lineAmountsPaise[i];
    if (a <= 0) continue;
    lastIdx = i;
    var d = (discount * a / total).floor();
    if (d > a) d = a;
    out[i] = d;
    given += d;
  }
  var rest = discount - given;
  // Give the remainder to the last line first, then spill backwards if it is capped.
  for (var i = lastIdx; i >= 0 && rest > 0; i--) {
    final room = lineAmountsPaise[i] - out[i];
    final add = rest < room ? rest : room;
    out[i] += add;
    rest -= add;
  }
  return out;
}

/// Weighted-average cost after buying [buyQtyMilli] at [buyCostPaise] on top of
/// [stockMilli] at [oldCostPaise]. Falls back to the new cost when there is no
/// positive stock.
int weightedAverageCost({
  required int stockMilli,
  required int oldCostPaise,
  required int buyQtyMilli,
  required int buyCostPaise,
}) {
  if (buyQtyMilli <= 0) return oldCostPaise;
  if (stockMilli <= 0 || oldCostPaise <= 0) return buyCostPaise;
  final value = stockMilli * oldCostPaise + buyQtyMilli * buyCostPaise;
  final qty = stockMilli + buyQtyMilli;
  return (value / qty).round();
}

/// What we still owe a supplier: purchases minus payments made.
int supplierPayable({required int purchasedPaise, required int paidPaise}) {
  final v = purchasedPaise - paidPaise;
  return v > 0 ? v : 0;
}
