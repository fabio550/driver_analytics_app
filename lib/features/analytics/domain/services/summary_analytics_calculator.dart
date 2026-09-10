import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/summary_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

class SummaryAnalyticsCalculator {
  const SummaryAnalyticsCalculator();

  SummaryAnalytics calculate({
    required List<ShiftEntity> shifts,
    required List<CostEntity> costs,
    required List<EarningEntity> earnings,
    required AnalyticsPeriod period,
    required DateTime now,
    required CostAllocationResult costAllocation,
  }) {
    // Só jornada confirmada entra. Uma jornada em andamento somaria horas
    // trabalhadas com receita ainda zerada e derrubaria o R$/h; uma
    // finalizada mas não confirmada ainda pode ser descartada pelo
    // usuário na tela de resumo.
    final periodShifts = shifts
        .where((s) => s.status == ShiftStatus.submitted)
        .where((s) => period.contains(s.startTime))
        .toList();

    final earningsByShift = <String, List<EarningEntity>>{};
    final knownShiftIds = shifts.map((s) => s.id).toSet();
    final looseEarnings = <EarningEntity>[];

    for (final earning in earnings) {
      final shiftId = earning.shiftId;
      // shiftId apontando pra jornada inexistente (excluída depois do
      // lançamento) conta como solto, senão o ganho sumiria da receita.
      if (shiftId == null || !knownShiftIds.contains(shiftId)) {
        looseEarnings.add(earning);
        continue;
      }
      earningsByShift.putIfAbsent(shiftId, () => []).add(earning);
    }

    var revenue = 0.0;
    var workedMinutes = 0;
    var distanceKm = 0.0;
    final revenueByDay = <DateTime, double>{};
    final costByDay = <DateTime, double>{};

    for (final shift in periodShifts) {
      final shiftEarnings = earningsByShift[shift.id] ?? const [];

      // §7.1: com lançamento, a soma manda; sem nenhum, cai pro valor
      // informado ao finalizar a jornada.
      final shiftRevenue = shiftEarnings.isNotEmpty
          ? shiftEarnings.fold<double>(0, (total, e) => total + e.amount)
          : (shift.earnings ?? 0);

      revenue += shiftRevenue;
      workedMinutes += shift.workedTime(now).inMinutes;
      distanceKm += shift.distanceKm;
      _addToDay(revenueByDay, shift.startTime, shiftRevenue);
    }

    for (final earning in looseEarnings) {
      if (!period.contains(earning.occurredAt)) continue;
      revenue += earning.amount;
      _addToDay(revenueByDay, earning.occurredAt, earning.amount);
    }

    // Custo do total do período vem do rateio (CostAllocationCalculator),
    // não da soma bruta — um lançamento caro perto da borda do período
    // não deveria mais derrubar o lucro líquido sozinho. O gráfico diário
    // continua com o valor bruto de cada dia (ver _addToDay abaixo):
    // suavizar por dia faria a barra mentir sobre quando o gasto saiu.
    for (final entry in costs) {
      if (!period.contains(entry.date)) continue;
      _addToDay(costByDay, entry.date, entry.amount);
    }
    final cost = costAllocation.attributedTotal;

    final netProfit = revenue - cost;
    final workedHours = workedMinutes / 60;

    // Só dia com jornada confirmada vira ponto — custo/ganho lançado num
    // dia sem jornada entra no total do período mas não ganha barra
    // própria (não fica "pendurado" num dia em que não se trabalhou).
    final days = periodShifts
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList()
      ..sort();

    return SummaryAnalytics(
      revenue: revenue,
      cost: cost,
      margin: revenue > 0 ? netProfit / revenue : null,
      netEarningsPerHour: workedHours > 0 ? netProfit / workedHours : null,
      netEarningsPerKm: distanceKm > 0 ? netProfit / distanceKm : null,
      dailyProfits: [
        for (final day in days)
          DailyProfitEntry(
            date: day,
            revenue: revenueByDay[day] ?? 0,
            cost: costByDay[day] ?? 0,
          ),
      ],
      shiftCount: periodShifts.length,
      workedTime: Duration(minutes: workedMinutes),
      distanceKm: distanceKm,
    );
  }

  void _addToDay(Map<DateTime, double> bucket, DateTime moment, double value) {
    final day = DateTime(moment.year, moment.month, moment.day);
    bucket[day] = (bucket[day] ?? 0) + value;
  }
}