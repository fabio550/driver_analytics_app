import 'package:drift/drift.dart';

/// Tabela base — toda entrada (corrida, promoção, ajuste) tem uma linha
/// aqui. `amount` só é preenchido pra promoção/ajuste: pra corrida ele
/// fica nulo de propósito, porque o valor é derivado de
/// fare+surge+tip na RideEarnings (nunca guardar o que dá pra derivar).
class Earnings extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get kind => text()();
  RealColumn get amount => real().nullable()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}