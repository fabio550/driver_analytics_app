import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/tables/shift_pauses.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/tables/shifts.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Shifts,
    ShiftPauses,
  ]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'driver_analytics_db');
}
