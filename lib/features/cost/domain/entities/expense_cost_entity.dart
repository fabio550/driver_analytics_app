part of 'cost_entity.dart';

class ExpenseCostEntity extends CostEntity {
  final ExpenseSubcategory subcategory;

  const ExpenseCostEntity({
    required super.id,
    required super.amount,
    required super.date,
    super.description,
    required this.subcategory,
  });

  @override
  CostCategory get category => CostCategory.expense;
}
