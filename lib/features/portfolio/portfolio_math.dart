/// حسابات المحفظة (دوال نقية قابلة للاختبار) / pure portfolio math
class Position {
  final String symbol;
  final int qty;
  final double avg, price;
  const Position(this.symbol, this.qty, this.avg, this.price);
  double get value => qty * price;
  double get cost => qty * avg;
  double get pnl => value - cost;
  double get pnlPct => cost == 0 ? 0 : pnl / cost * 100;
}

class Portfolio {
  final double cash;
  final List<Position> positions;
  const Portfolio(this.cash, this.positions);
  double get marketValue => positions.fold(0.0, (a, p) => a + p.value);
  double get cost => positions.fold(0.0, (a, p) => a + p.cost);
  double get unrealized => marketValue - cost;
  double get unrealizedPct => cost == 0 ? 0 : unrealized / cost * 100;
  double get equity => cash + marketValue;
}

Portfolio computePortfolio({
  required double cash,
  required List<Map<String, dynamic>> holdings,
  required Map<String, double> prices,
}) {
  final pos = <Position>[];
  for (final h in holdings) {
    final sym = h['symbol'] as String;
    final avg = (h['avg_price'] as num).toDouble();
    pos.add(Position(sym, (h['qty'] as num).toInt(), avg, prices[sym] ?? avg));
  }
  pos.sort((a, b) => b.value.compareTo(a.value));
  return Portfolio(cash, pos);
}

int maxBuyQty(double cash, double price) => price <= 0 ? 0 : (cash / price).floor();

/// يرجع رسالة خطأ أو null / returns error message or null
String? validateTrade({
  required bool buy,
  required int qty,
  required double price,
  required double cash,
  required int held,
}) {
  if (qty <= 0) return 'أدخل كمية صحيحة';
  if (buy && qty * price > cash) return 'الرصيد غير كافٍ';
  if (!buy && qty > held) return 'الكمية أكبر مما تملك';
  return null;
}
