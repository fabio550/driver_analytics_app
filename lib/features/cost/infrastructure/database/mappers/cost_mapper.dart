import 'package:drift/drift.dart';
import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';

class CostMapper {
  const CostMapper();

  ExpenseCostEntity fromExpenseRow(Cost row) {
    return ExpenseCostEntity(
      id: row.id,
      amount: row.amount,
      date: row.date,
      description: row.description,
      subcategory: ExpenseSubcategory.values.byName(row.subcategory),
    );
  }

  CostsCompanion toCompanion(CostEntity cost) {
    return CostsCompanion(
      id: Value(cost.id),
      category: Value(cost.category.name),
      subcategory: Value(_subcategoryName(cost)),
      amount: Value(cost.amount),
      date: Value(cost.date),
      description: Value(cost.description),
    );
  }

  String _subcategoryName(CostEntity cost) {
    return switch (cost) {
      FuelCostEntity(:final subcategory) => subcategory.name,
      MaintenanceCostEntity(:final subcategory) => subcategory.name,
      ExpenseCostEntity(:final subcategory) => subcategory.name,
    };
  }
}
