import 'package:drift/drift.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/tables/earnings.dart';

class RideEarnings extends Table {
  TextColumn get earningId => text().references(Earnings, #id)();
  TextColumn get app => text()();
  TextColumn get serviceType => text()();
  RealColumn get fare => real()();
  RealColumn get surge => real().withDefault(const Constant(0))();
  RealColumn get tip => real().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer()();
  RealColumn get distanceKm => real()();
  TextColumn get status => text()();
  TextColumn get pickupCep => text().nullable()();
  TextColumn get destinationCep => text().nullable()();
  TextColumn get pickupDistrictId => text().nullable()();
  TextColumn get destinationDistrictId => text().nullable()();

  @override
  Set<Column> get primaryKey => {earningId};
}