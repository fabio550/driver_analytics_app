import 'package:driver_analytics_app/features/analytics/domain/entities/cost_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';

class CostAnalyticsCalculator {
  const CostAnalyticsCalculator();

  CostAnalytics calculate({
    required List<CostEntity> costs,
    required AnalyticsPeriod period,
    required double distanceKm,
  }) {
    final periodCosts = costs.where((c) => period.contains(c.date)).toList();
    if (periodCosts.isEmpty) return CostAnalytics.empty;

    final byCategoryAmount = <CostCategory, double>{};
    for (final cost in periodCosts) {
      byCategoryAmount[cost.category] = (byCategoryAmount[cost.category] ?? 0) + cost.amount;
    }
    final byCategory = [
      for (final entry in byCategoryAmount.entries)
        CostCategoryEntry(category: entry.key, amount: entry.value),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final totalCost = periodCosts.fold<double>(0, (t, c) => t + c.amount);

    final fuelCosts = periodCosts.whereType<FuelCostEntity>().toList();
    final fuelEfficiency = _fuelEfficiency(fuelCosts, distanceKm);

    final topEntries = [...periodCosts]..sort((a, b) => b.amount.compareTo(a.amount));

    return CostAnalytics(
      byCategory: byCategory,
      fuelEfficiency: fuelEfficiency,
      topEntries: topEntries.take(5).toList(),
      totalCost: totalCost,
    );
  }

  FuelEfficiencyStats _fuelEfficiency(List<FuelCostEntity> fuelCosts, double distanceKm) {
    if (fuelCosts.isEmpty) return FuelEfficiencyStats.empty;

    final totalFuelAmount = fuelCosts.fold<double>(0, (t, c) => t + c.amount);
    final costPerKm = distanceKm > 0 ? totalFuelAmount / distanceKm : null;

    // Litros/preço médio só olham combustível líquido — misturar com kWh
    // (recarga elétrica) não faz sentido numa mesma média.
    final liquidFuel = fuelCosts
        .where((c) => c.subcategory != FuelSubcategory.energy)
        .toList();

    final totalLiters = liquidFuel.fold<double>(0, (t, c) => t + c.quantity);
    final totalLiquidAmount = liquidFuel.fold<double>(0, (t, c) => t + c.amount);
    final costPerLiter = totalLiters > 0 ? totalLiquidAmount / totalLiters : null;

    return FuelEfficiencyStats(
      kmPerLiter: _kmPerLiter(liquidFuel),
      costPerKm: costPerKm,
      costPerLiter: costPerLiter,
    );
  }

  /// Consumo real só é confiável entre dois tanques cheios: km rodado é a
  /// diferença de odômetro entre o primeiro e o último tanque cheio do
  /// período, litros consumidos é tudo que foi posto entre eles (o litro
  /// do primeiro tanque cheio já estava no carro, não conta). Precisa de
  /// pelo menos 2 tanques cheios no período — com só 1, não há intervalo
  /// fechado pra medir.
  double? _kmPerLiter(List<FuelCostEntity> liquidFuel) {
    final sorted = [...liquidFuel]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
    final fullTanks = sorted.where((c) => c.isFullTank).toList();
    if (fullTanks.length < 2) return null;

    final startKm = fullTanks.first.odometerKm;
    final endKm = fullTanks.last.odometerKm;
    final distance = endKm - startKm;
    if (distance <= 0) return null;

    final litersUsed = sorted
        .where((c) => c.odometerKm > startKm && c.odometerKm <= endKm)
        .fold<double>(0, (t, c) => t + c.quantity);
    if (litersUsed <= 0) return null;

    return distance / litersUsed;
  }
}
