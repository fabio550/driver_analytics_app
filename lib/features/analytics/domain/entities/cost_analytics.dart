import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';

class CostCategoryEntry {
  final CostCategory category;
  final double amount;

  const CostCategoryEntry({required this.category, required this.amount});
}

/// R$/km e R$/litro são média simples (custo total / total no período).
/// km/L é o único que precisa de janela tanque-cheio a tanque-cheio — ver
/// a calculadora — por isso é o único que pode ficar nulo mesmo havendo
/// abastecimento no período (falta um segundo tanque cheio pra fechar a
/// conta).
class FuelEfficiencyStats {
  final double? kmPerLiter;
  final double? costPerKm;
  final double? costPerLiter;

  const FuelEfficiencyStats({this.kmPerLiter, this.costPerKm, this.costPerLiter});

  static const empty = FuelEfficiencyStats();
}

class CostAnalytics {
  final List<CostCategoryEntry> byCategory;
  final FuelEfficiencyStats fuelEfficiency;
  final List<CostEntity> topEntries;
  final double totalCost;

  const CostAnalytics({
    required this.byCategory,
    required this.fuelEfficiency,
    required this.topEntries,
    required this.totalCost,
  });

  static const empty = CostAnalytics(
    byCategory: [],
    fuelEfficiency: FuelEfficiencyStats.empty,
    topEntries: [],
    totalCost: 0,
  );

  bool get isEmpty => totalCost == 0;
}
