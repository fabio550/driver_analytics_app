import 'package:driver_analytics_app/features/analytics/domain/services/fuel_consumption_calculator.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:flutter_test/flutter_test.dart';

FuelCostEntity _fuel({
  required DateTime date,
  required double amount,
  required double odometerKm,
  required double quantity,
  bool isFullTank = false,
  FuelSubcategory subcategory = FuelSubcategory.gasolineCommon,
}) {
  return FuelCostEntity(
    id: 'fuel-${date.microsecondsSinceEpoch}-$odometerKm',
    amount: amount,
    date: date,
    subcategory: subcategory,
    odometerKm: odometerKm,
    quantity: quantity,
    isFullTank: isFullTank,
  );
}

void main() {
  const calculator = FuelConsumptionCalculator();

  test('empty list returns empty stats', () {
    final stats = calculator.calculate([]);
    expect(stats.kmPerLiter, isNull);
    expect(stats.costPerLiter, isNull);
  });

  test('single full tank is not enough to compute km/L', () {
    final stats = calculator.calculate([
      _fuel(date: DateTime(2026, 1, 10), amount: 200, odometerKm: 1000, quantity: 40, isFullTank: true),
    ]);
    expect(stats.kmPerLiter, isNull);
    // Preço médio já dá pra calcular com 1 lançamento só.
    expect(stats.costPerLiter, closeTo(5.0, 0.0001));
  });

  test('two full tanks compute km/L from the odometer delta between them', () {
    final stats = calculator.calculate([
      _fuel(date: DateTime(2026, 1, 1), amount: 200, odometerKm: 1000, quantity: 40, isFullTank: true),
      _fuel(date: DateTime(2026, 1, 15), amount: 220, odometerKm: 1400, quantity: 40, isFullTank: true),
    ]);
    // 400 km rodados com os 40L do segundo abastecimento (o litro do
    // primeiro tanque cheio já estava no carro, não conta).
    expect(stats.kmPerLiter, closeTo(10.0, 0.0001));
    expect(stats.costPerLiter, closeTo(420 / 80, 0.0001));
  });

  test('partial fill-ups between two full tanks count toward liters used', () {
    final stats = calculator.calculate([
      _fuel(date: DateTime(2026, 1, 1), amount: 200, odometerKm: 1000, quantity: 40, isFullTank: true),
      _fuel(date: DateTime(2026, 1, 8), amount: 100, odometerKm: 1200, quantity: 20, isFullTank: false),
      _fuel(date: DateTime(2026, 1, 15), amount: 120, odometerKm: 1400, quantity: 24, isFullTank: true),
    ]);
    // 400 km com 20L (parcial) + 24L (tanque cheio final) = 44L.
    expect(stats.kmPerLiter, closeTo(400 / 44, 0.0001));
  });

  test('energy (electric) entries are excluded from liters/cost-per-liter', () {
    final stats = calculator.calculate([
      _fuel(
        date: DateTime(2026, 1, 1),
        amount: 300,
        odometerKm: 1000,
        quantity: 50,
        subcategory: FuelSubcategory.energy,
      ),
    ]);
    expect(stats.costPerLiter, isNull);
  });

  test('two full tanks at the same odometer reading yield no km/L', () {
    final stats = calculator.calculate([
      _fuel(date: DateTime(2026, 1, 1), amount: 200, odometerKm: 1000, quantity: 40, isFullTank: true),
      _fuel(date: DateTime(2026, 1, 15), amount: 220, odometerKm: 1000, quantity: 40, isFullTank: true),
    ]);
    expect(stats.kmPerLiter, isNull);
  });
}
