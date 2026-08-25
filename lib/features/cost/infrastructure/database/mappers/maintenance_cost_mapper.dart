import 'package:drift/drift.dart';
import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';

class MaintenanceCostMapper {
  const MaintenanceCostMapper();

  MaintenanceCostEntity fromRows(Cost costRow, MaintenanceCost maintenanceRow) {
    return MaintenanceCostEntity(
      id: costRow.id,
      amount: costRow.amount,
      date: costRow.date,
      description: costRow.description,
      subcategory: MaintenanceSubcategory.values.byName(costRow.subcategory),
      odometerKm: maintenanceRow.odometerKm,
    );
  }

  MaintenanceCostsCompanion toCompanion(MaintenanceCostEntity cost) {
    return MaintenanceCostsCompanion(
      costId: Value(cost.id),
      odometerKm: Value(cost.odometerKm),
    );
  }
}
