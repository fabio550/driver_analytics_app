import 'package:driver_analytics_app/features/analytics/application/state/analytics_period_notifier.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/cost_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/revenue_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/summary_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/cost_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/operation_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/revenue_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/summary_analytics_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsPeriodNotifierProvider =
    NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(
  AnalyticsPeriodNotifier.new,
);

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
  );
});