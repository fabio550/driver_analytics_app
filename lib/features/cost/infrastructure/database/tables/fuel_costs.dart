class FuelCosts extends Table {
  TextColumn get costId => text().references(Costs, #id)();
  RealColumn get odometerKm => real()();
  RealColumn get quantity => real()();
  BoolColumn get isFullTank => boolean().withDefault(const Constant(false))();
  BoolColumn get previousFillUpMissing => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {costId};
}
