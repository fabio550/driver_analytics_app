import 'package:drift/drift.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/tables/costs.dart';

class MaintenanceCosts extends Table {
  TextColumn get costId => text().references(Costs, #id)();
  RealColumn get odometerKm => real().nullable()();

  @override
  Set<Column> get primaryKey => {costId};
}
