import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';

part 'expense_cost_entity.dart';
part 'fuel_cost_entity.dart';
part 'maintenance_cost_entity.dart';

sealed class CostEntity {
  final String id;
  final double amount;
  final DateTime date;
  final String? description;

  const CostEntity({
    required this.id,
    required this.amount,
    required this.date,
    this.description,
  });

  CostCategory get category;
}
