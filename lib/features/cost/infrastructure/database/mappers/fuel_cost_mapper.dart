import 'package:drift/drift.dart';
import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';

class FuelCostMapper {
  const FuelCostMapper();

  FuelCostEntity fromRows(Cost costRow, FuelCost fuelRow) {
    return FuelCostEntity(
      id: costRow.id,
      amount: costRow.amount,
      date: costRow.date,
      description: costRow.description,
      subcategory: FuelSubcategory.values.byName(costRow.subcategory),
      odometerKm: fuelRow.odometerKm,
      quantity: fuelRow.quantity,
      isFullTank: fuelRow.isFullTank,
      previousFillUpMissing: fuelRow.previousFillUpMissing,
    );
  }

  FuelCostsCompanion toCompanion(FuelCostEntity cost) {
    return FuelCostsCompanion(
      costId: Value(cost.id),
      odometerKm: Value(cost.odometerKm),
      quantity: Value(cost.quantity),
      isFullTank: Value(cost.isFullTank),
      previousFillUpMissing: Value(cost.previousFillUpMissing),
    );
  }
}
