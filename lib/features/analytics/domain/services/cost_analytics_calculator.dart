import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/cost_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/fuel_consumption_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';

class CostAnalyticsCalculator {
  const CostAnalyticsCalculator();

  CostAnalytics calculate({
    required List<CostEntity> costs,
    required AnalyticsPeriod period,
    required double distanceKm,
    required CostAllocationResult allocation,
  }) {
    final periodCosts = costs.where((c) => period.contains(c.date)).toList();
    if (periodCosts.isEmpty) {
      return CostAnalytics(
        byCategory: const [],
        fuelEfficiency: FuelEfficiencyStats.empty,
        topEntries: const [],
        actualSpend: 0,
        allocation: allocation,
      );
    }

    final byCategoryAmount = <CostCategory, double>{};
    for (final cost in periodCosts) {
      byCategoryAmount[cost.category] = (byCategoryAmount[cost.category] ?? 0) + cost.amount;
    }
    final byCategory = [
      for (final entry in byCategoryAmount.entries)
        CostCategoryEntry(category: entry.key, amount: entry.value),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final actualSpend = periodCosts.fold<double>(0, (t, c) => t + c.amount);

    final fuelCosts = periodCosts.whereType<FuelCostEntity>().toList();
    final fuelEfficiency = _fuelEfficiency(fuelCosts, distanceKm);

    final topEntries = [...periodCosts]..sort((a, b) => b.amount.compareTo(a.amount));

    return CostAnalytics(
      byCategory: byCategory,
      fuelEfficiency: fuelEfficiency,
      topEntries: topEntries.take(5).toList(),
      actualSpend: actualSpend,
      allocation: allocation,
    );
  }

  FuelEfficiencyStats _fuelEfficiency(List<FuelCostEntity> fuelCosts, double distanceKm) {
    if (fuelCosts.isEmpty) return FuelEfficiencyStats.empty;

    final totalFuelAmount = fuelCosts.fold<double>(0, (t, c) => t + c.amount);
    final costPerKm = distanceKm > 0 ? totalFuelAmount / distanceKm : null;

    final consumption = const FuelConsumptionCalculator().calculate(fuelCosts);

    return FuelEfficiencyStats(
      kmPerLiter: consumption.kmPerLiter,
      costPerKm: costPerKm,
      costPerLiter: consumption.costPerLiter,
    );
  }
}
