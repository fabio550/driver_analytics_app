import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/tables/costs.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/tables/fuel_costs.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/tables/maintenance_costs.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/tables/earnings.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/tables/ride_earnings.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/tables/shift_pauses.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/tables/shifts.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Shifts,
    ShiftPauses,
    Costs,
    FuelCosts,
    MaintenanceCosts,
    Earnings,
    RideEarnings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(costs);
            await m.createTable(fuelCosts);
            await m.createTable(maintenanceCosts);
          }
          if (from < 3) {
            await m.createTable(earnings);
            await m.createTable(rideEarnings);
          }
          if (from < 4) {
            await m.addColumn(rideEarnings, rideEarnings.dedupHash);
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_ride_earnings_dedup_hash '
              'ON ride_earnings (dedup_hash)',
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'driver_analytics_db');
}