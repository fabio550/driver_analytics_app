import 'package:driver_analytics_app/features/analytics/application/state/analytics_period_notifier.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/cost_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/revenue_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/summary_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/cost_allocation_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/cost_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/operation_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/revenue_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/summary_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsPeriodNotifierProvider =
    NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(
  AnalyticsPeriodNotifier.new,
);

final costAllocationCalculatorProvider = Provider<CostAllocationCalculator>((ref) {
  return const CostAllocationCalculator();
});

// Único ponto de cálculo do rateio — Resumo e Custos consomem o mesmo
// resultado em vez de cada um recalcular a própria taxa (mesmo problema
// que a regra §7.1 de receita já tem hoje, espalhada em 3 calculators;
// aqui não repete).
final costAllocationProvider = Provider<CostAllocationResult>((ref) {
  final calculator = ref.watch(costAllocationCalculatorProvider);

  return calculator.calculate(
    costs: ref.watch(costNotifierProvider).costs,
    shifts: ref.watch(shiftNotifierProvider).shifts,
    period: ref.watch(analyticsPeriodNotifierProvider),
  );
});

final summaryAnalyticsCalculatorProvider =
    Provider<SummaryAnalyticsCalculator>((ref) {
  return const SummaryAnalyticsCalculator();
});

final summaryAnalyticsProvider = Provider<SummaryAnalytics>((ref) {
  final calculator = ref.watch(summaryAnalyticsCalculatorProvider);

  return calculator.calculate(
    shifts: ref.watch(shiftNotifierProvider).shifts,
    costs: ref.watch(costNotifierProvider).costs,
    earnings: ref.watch(earningNotifierProvider).earnings,
    period: ref.watch(analyticsPeriodNotifierProvider),
    now: DateTime.now(),
    costAllocation: ref.watch(costAllocationProvider),
  );
});

final operationAnalyticsCalculatorProvider =
    Provider<OperationAnalyticsCalculator>((ref) {
  return const OperationAnalyticsCalculator();
});

final operationAnalyticsProvider = Provider<OperationAnalytics>((ref) {
  final calculator = ref.watch(operationAnalyticsCalculatorProvider);

  return calculator.calculate(
    shifts: ref.watch(shiftNotifierProvider).shifts,
    earnings: ref.watch(earningNotifierProvider).earnings,
    period: ref.watch(analyticsPeriodNotifierProvider),
    now: DateTime.now(),
  );
});

final revenueAnalyticsCalculatorProvider =
    Provider<RevenueAnalyticsCalculator>((ref) {
  return const RevenueAnalyticsCalculator();
});

final revenueAnalyticsProvider = Provider<RevenueAnalytics>((ref) {
  final calculator = ref.watch(revenueAnalyticsCalculatorProvider);

  return calculator.calculate(
    shifts: ref.watch(shiftNotifierProvider).shifts,
    earnings: ref.watch(earningNotifierProvider).earnings,
    period: ref.watch(analyticsPeriodNotifierProvider),
  );
});

final costAnalyticsCalculatorProvider = Provider<CostAnalyticsCalculator>((ref) {
  return const CostAnalyticsCalculator();
});

final costAnalyticsProvider = Provider<CostAnalytics>((ref) {
  final calculator = ref.watch(costAnalyticsCalculatorProvider);

  return calculator.calculate(
    costs: ref.watch(costNotifierProvider).costs,
    period: ref.watch(analyticsPeriodNotifierProvider),
    distanceKm: ref.watch(summaryAnalyticsProvider).distanceKm,
    allocation: ref.watch(costAllocationProvider),
  );
});
/// Resumo da semana corrente, independente do recorte escolhido na aba
/// de Análises. O card do Início mostra sempre "esta semana"; se ele
/// consumisse [summaryAnalyticsProvider], trocar o período lá dentro
/// mudaria o número da Home pelas costas.
final currentWeekSummaryProvider = Provider<SummaryAnalytics>((ref) {
  final now = DateTime.now();
  final period = AnalyticsPeriod.week(now);

  final shifts = ref.watch(shiftNotifierProvider).shifts;
  final costs = ref.watch(costNotifierProvider).costs;
  final earnings = ref.watch(earningNotifierProvider).earnings;

  final allocation = ref.watch(costAllocationCalculatorProvider).calculate(
        costs: costs,
        shifts: shifts,
        period: period,
      );

  return ref.watch(summaryAnalyticsCalculatorProvider).calculate(
        shifts: shifts,
        costs: costs,
        earnings: earnings,
        period: period,
        now: now,
        costAllocation: allocation,
      );
});

/// Última jornada confirmada, pro rodapé do botão de iniciar no Início.
final lastSubmittedShiftProvider = Provider<ShiftEntity?>((ref) {
  final shifts = ref
      .watch(shiftNotifierProvider)
      .shifts
      .where((shift) => shift.status == ShiftStatus.submitted)
      .toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  return shifts.isEmpty ? null : shifts.first;
});

/// Média diária do recorte que contém o período atual: o mês quando se
/// olha uma semana, o ano quando se olha um mês.
///
/// É a régua do rodapé do gráfico. "Média de R$ 147,43 por dia" sozinho
/// não diz nada; ao lado da média do ano, diz se o período foi acima ou
/// abaixo do normal. Nulo quando não há recorte mais largo (intervalo
/// personalizado) ou quando ele não tem nenhum dia com jornada.
final enclosingScopeDailyAverageProvider = Provider<double?>((ref) {
  final enclosing = ref.watch(analyticsPeriodNotifierProvider).enclosing;
  if (enclosing == null) return null;

  final shifts = ref.watch(shiftNotifierProvider).shifts;
  final costs = ref.watch(costNotifierProvider).costs;
  final earnings = ref.watch(earningNotifierProvider).earnings;

  final allocation = ref.watch(costAllocationCalculatorProvider).calculate(
        costs: costs,
        shifts: shifts,
        period: enclosing,
      );

  final days = ref.watch(summaryAnalyticsCalculatorProvider).calculate(
        shifts: shifts,
        costs: costs,
        earnings: earnings,
        period: enclosing,
        now: DateTime.now(),
        costAllocation: allocation,
      ).dailyProfits;

  if (days.isEmpty) return null;

  return days.fold<double>(0, (total, day) => total + day.netProfit) / days.length;
});
