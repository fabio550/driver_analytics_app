class Costs extends Table {
  TextColumn get id => text()();

  TextColumn get category => text()();
  TextColumn get subcategory => text()();

  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
