class MaintenanceCosts extends Table {
  TextColumn get costId => text().references(Costs, #id)();
  RealColumn get odometerKm => real().nullable()();

  @override
  Set<Column> get primaryKey => {costId};
}
