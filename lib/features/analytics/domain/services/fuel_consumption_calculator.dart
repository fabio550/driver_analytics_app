import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';

class FuelConsumptionStats {
  final double? kmPerLiter;
  final double? costPerLiter;

  const FuelConsumptionStats({this.kmPerLiter, this.costPerLiter});

  static const empty = FuelConsumptionStats();
}

/// Extraído de `CostAnalyticsCalculator` pra poder ser chamado duas vezes
/// com janelas diferentes: uma pro card "Combustível" (período — ver
/// `CostAnalyticsCalculator._fuelEfficiency`, comportamento intocado) e
/// outra pro rateio de custo atribuído (`CostAllocationCalculator`, janela
/// mês passado + expansível). Mesmo algoritmo, dados diferentes.
class FuelConsumptionCalculator {
  const FuelConsumptionCalculator();

  FuelConsumptionStats calculate(List<FuelCostEntity> fuelCosts) {
    if (fuelCosts.isEmpty) return FuelConsumptionStats.empty;

    // Litros/preço médio só olham combustível líquido — misturar com kWh
    // (recarga elétrica) não faz sentido numa mesma média.
    final liquidFuel =
        fuelCosts.where((c) => c.subcategory != FuelSubcategory.energy).toList();

    final totalLiters = liquidFuel.fold<double>(0, (t, c) => t + c.quantity);
    final totalLiquidAmount = liquidFuel.fold<double>(0, (t, c) => t + c.amount);
    final costPerLiter = totalLiters > 0 ? totalLiquidAmount / totalLiters : null;

    return FuelConsumptionStats(
      kmPerLiter: _kmPerLiter(liquidFuel),
      costPerLiter: costPerLiter,
    );
  }

  /// Consumo real só é confiável entre dois tanques cheios: km rodado é a
  /// diferença de odômetro entre o primeiro e o último tanque cheio da
  /// lista recebida, litros consumidos é tudo que foi posto entre eles (o
  /// litro do primeiro tanque cheio já estava no carro, não conta).
  /// Precisa de pelo menos 2 tanques cheios — com só 1, não há intervalo
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
