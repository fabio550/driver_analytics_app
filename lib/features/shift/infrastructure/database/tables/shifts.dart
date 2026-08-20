import 'package:drift/drift.dart';

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  RealColumn get initialKm => real()();
  RealColumn get finalKm => real().nullable()();
  RealColumn get earnings => real().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
