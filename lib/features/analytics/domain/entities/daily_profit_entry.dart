class DailyProfitEntry {
  final DateTime date;
  final double revenue;
  final double cost;

  const DailyProfitEntry({
    required this.date,
    required this.revenue,
    required this.cost,
  });

  double get netProfit => revenue - cost;
}