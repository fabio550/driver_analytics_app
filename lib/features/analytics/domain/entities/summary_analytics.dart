import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';

class SummaryAnalytics {
  final double revenue;
  final double cost;
  final double? margin;
  final double? netEarningsPerHour;
  final double? netEarningsPerKm;
  final List<DailyProfitEntry> dailyProfits;

  /// Base do cálculo — o rodapé do bloco declara isso pro usuário saber
  /// de cima de quanta jornada a conta foi feita.
  final int shiftCount;
  final Duration workedTime;
  final double distanceKm;

  const SummaryAnalytics({
    required this.revenue,
    required this.cost,
    required this.margin,
    required this.netEarningsPerHour,
    required this.netEarningsPerKm,
    required this.dailyProfits,
    required this.shiftCount,
    required this.workedTime,
    required this.distanceKm,
  });

  static const empty = SummaryAnalytics(
    revenue: 0,
    cost: 0,
    margin: null,
    netEarningsPerHour: null,
    netEarningsPerKm: null,
    dailyProfits: [],
    shiftCount: 0,
    workedTime: Duration.zero,
    distanceKm: 0,
  );

  double get netProfit => revenue - cost;

  bool get isEmpty => shiftCount == 0 && revenue == 0 && cost == 0;
}