import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';

extension CostCategoryLabel on CostCategory {
  String get label {
    return switch (this) {
      CostCategory.fuel => 'Combustível',
      CostCategory.maintenance => 'Manutenção',
      CostCategory.expense => 'Despesa',
    };
  }
}

extension CostEntityLabel on CostEntity {
  /// Título de exibição de um lançamento — a subcategoria concreta, não a
  /// categoria (ex.: "Troca de óleo", não "Manutenção").
  String get label {
    return switch (this) {
      FuelCostEntity(:final subcategory) => subcategory.label,
      MaintenanceCostEntity(:final subcategory) => subcategory.label,
      ExpenseCostEntity(:final subcategory) => subcategory.label,
    };
  }
}
