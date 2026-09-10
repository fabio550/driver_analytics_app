import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_allocation_method.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';

/// Classificação de negócio — não confundir com rótulo de UI
/// (`presentation/extensions/*Label`). Fica no domínio porque é regra do
/// sistema, não texto de tela.
extension ExpenseSubcategoryAllocation on ExpenseSubcategory {
  CostAllocationMethod get allocationMethod {
    return switch (this) {
      ExpenseSubcategory.financing ||
      ExpenseSubcategory.taxes ||
      ExpenseSubcategory.insurance =>
        CostAllocationMethod.timeDriven,
      ExpenseSubcategory.parking ||
      ExpenseSubcategory.carWash ||
      ExpenseSubcategory.fine ||
      ExpenseSubcategory.toll ||
      ExpenseSubcategory.other =>
        CostAllocationMethod.direct,
    };
  }
}

extension CostEntityAllocation on CostEntity {
  /// Combustível e manutenção são km-driven por inteiro — só despesa
  /// varia por subcategoria.
  CostAllocationMethod get allocationMethod {
    return switch (this) {
      FuelCostEntity() || MaintenanceCostEntity() => CostAllocationMethod.kmDriven,
      ExpenseCostEntity(:final subcategory) => subcategory.allocationMethod,
    };
  }
}
