import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/cost_allocation_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:flutter_test/flutter_test.dart';

int _idCounter = 0;
String _nextId() => 'id-${_idCounter++}';

ShiftEntity _shift({
  required DateTime start,
  required double initialKm,
  required double finalKm,
}) {
  return ShiftEntity(
    id: _nextId(),
    status: ShiftStatus.submitted,
    initialKm: initialKm,
    finalKm: finalKm,
    startTime: start,
    endTime: start.add(const Duration(hours: 8)),
  );
}

FuelCostEntity _fuel({
  required DateTime date,
  required double amount,
  required double odometerKm,
  required double quantity,
  bool isFullTank = false,
}) {
  return FuelCostEntity(
    id: _nextId(),
    amount: amount,
    date: date,
    subcategory: FuelSubcategory.gasolineCommon,
    odometerKm: odometerKm,
    quantity: quantity,
    isFullTank: isFullTank,
  );
}

MaintenanceCostEntity _maintenance({required DateTime date, required double amount}) {
  return MaintenanceCostEntity(
    id: _nextId(),
    amount: amount,
    date: date,
    subcategory: MaintenanceSubcategory.tireReplacement,
  );
}

ExpenseCostEntity _expense({
  required DateTime date,
  required double amount,
  required ExpenseSubcategory subcategory,
}) {
  return ExpenseCostEntity(id: _nextId(), amount: amount, date: date, subcategory: subcategory);
}

CostAllocationGroup _groupOf(CostAllocationResult result, CostAllocationGroupKind kind) {
  return result.groups.firstWhere((g) => g.kind == kind);
}

void main() {
  const calculator = CostAllocationCalculator();
  // Outubro/2026: start=01/10, end=01/11 (exclusivo) — 31 dias.
  final october = AnalyticsPeriod.month(DateTime(2026, 10));

  group('maintenance (kmDriven, histórico total)', () {
    test('spreads a lumpy cost across all km driven since the first record', () {
      final costs = [
        _maintenance(date: DateTime(2026, 1, 10), amount: 100),
        _maintenance(date: DateTime(2026, 3, 5), amount: 300),
      ];
      final shifts = [
        _shift(start: DateTime(2026, 1, 15), initialKm: 1000, finalKm: 1200), // 200km
        _shift(start: DateTime(2026, 3, 10), initialKm: 1200, finalKm: 1600), // 400km
        _shift(start: DateTime(2026, 10, 5), initialKm: 1600, finalKm: 1800), // 200km (no período)
      ];

      final result = calculator.calculate(costs: costs, shifts: shifts, period: october);
      final group = _groupOf(result, CostAllocationGroupKind.maintenance);

      // Janela "todo o histórico" vai do 1º lançamento de manutenção
      // (10/jan) até o fim do período (01/nov) — inclui as 3 jornadas:
      // 200+400+200 = 800km. Taxa = 400/800 = 0.5 R$/km; atribuído =
      // taxa * 200km do período (só a jornada de outubro).
      expect(group.rawCost, 0); // nenhum lançamento de manutenção em outubro
      expect(group.attributedCost, closeTo(400 / 800 * 200, 0.01));
      expect(group.isEstimated, isTrue);
    });

    test('a single lifetime entry is insufficient — locks, does not estimate', () {
      final costs = [_maintenance(date: DateTime(2026, 9, 1), amount: 500)];
      final shifts = [_shift(start: DateTime(2026, 9, 1), initialKm: 0, finalKm: 100)];

      final result = calculator.calculate(costs: costs, shifts: shifts, period: october);
      final group = _groupOf(result, CostAllocationGroupKind.maintenance);

      expect(group.attributedCost, isNull);
      expect(group.note, isNotNull);
      expect(group.effectiveCost, group.rawCost); // cai pro bruto quando trava
    });

    test('never having a maintenance cost is a legitimate zero, not insufficient', () {
      final result = calculator.calculate(costs: const [], shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.maintenance);

      expect(group.attributedCost, 0);
      expect(group.isEstimated, isTrue);
    });

    test('history exists but zero km ever driven locks the rate', () {
      final costs = [
        _maintenance(date: DateTime(2026, 1, 1), amount: 100),
        _maintenance(date: DateTime(2026, 2, 1), amount: 100),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.maintenance);

      expect(group.attributedCost, isNull);
    });
  });

  group('fuel (kmDriven, janela mês passado expansível)', () {
    test('expands past an insufficient recent window to find 2 full tanks', () {
      final costs = [
        // Fora da janela de 1 mês (set) e de 2 meses (ago) — só existe pra
        // provar que a janela NÃO precisou consumir todo o histórico.
        _fuel(date: DateTime(2026, 7, 1), amount: 180, odometerKm: 4200, quantity: 35, isFullTank: true),
        // Dentro da janela de 2 meses (ago–out): 2º tanque cheio mais
        // antigo dela.
        _fuel(date: DateTime(2026, 8, 5), amount: 200, odometerKm: 4600, quantity: 38, isFullTank: true),
        // Único tanque cheio dentro da janela de 1 mês (set–out) —
        // insuficiente sozinho.
        _fuel(date: DateTime(2026, 9, 15), amount: 220, odometerKm: 5000, quantity: 40, isFullTank: true),
      ];
      final shifts = [
        _shift(start: DateTime(2026, 10, 10), initialKm: 5000, finalKm: 5300), // 300km no período
      ];

      final result = calculator.calculate(costs: costs, shifts: shifts, period: october);
      final group = _groupOf(result, CostAllocationGroupKind.fuel);

      // km/L = (5000-4600)/40 = 10; R$/L = (200+220)/(38+40) = 5.3846...
      // taxa = 5.3846/10 = 0.53846 R$/km; atribuído = taxa * 300km.
      final expectedRate = (420 / 78) / 10;
      expect(group.attributedCost, closeTo(expectedRate * 300, 0.05));
      expect(group.rawCost, 0); // nenhum abastecimento caiu dentro de outubro
      // Não devia ter precisado consumir o lançamento de julho.
      expect(group.note, isNot(contains('todo o histórico')));
    });

    test('falls back to the entire history when even that is not enough', () {
      final costs = [
        _fuel(date: DateTime(2026, 9, 20), amount: 220, odometerKm: 5000, quantity: 40, isFullTank: true),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.fuel);

      expect(group.attributedCost, isNull);
      expect(group.note, contains('histórico'));
    });

    test('never having a fuel cost is a legitimate zero', () {
      final result = calculator.calculate(costs: const [], shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.fuel);

      expect(group.attributedCost, 0);
    });
  });

  group('financing/taxes/insurance (timeDriven, intervalo real)', () {
    test('rate adapts to the real interval between the last 2 entries', () {
      final costs = [
        _expense(date: DateTime(2026, 1, 1), amount: 800, subcategory: ExpenseSubcategory.financing),
        _expense(date: DateTime(2026, 1, 31), amount: 850, subcategory: ExpenseSubcategory.financing),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.financing);

      // taxa = 850 / 30 dias; outubro tem 31 dias.
      final expectedRate = 850 / 30;
      expect(group.attributedCost, closeTo(expectedRate * 31, 0.01));
      expect(group.rawCost, 0);
    });

    test('a single lifetime entry cannot establish an interval', () {
      final costs = [
        _expense(date: DateTime(2026, 5, 1), amount: 1200, subcategory: ExpenseSubcategory.insurance),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.insurance);

      expect(group.attributedCost, isNull);
    });

    test('never having this cost is a legitimate zero', () {
      final result = calculator.calculate(costs: const [], shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.taxes);

      expect(group.attributedCost, 0);
    });

    test('two entries on the same date cannot compute a per-day rate', () {
      final sameDay = DateTime(2026, 6, 1);
      final costs = [
        _expense(date: sameDay, amount: 100, subcategory: ExpenseSubcategory.taxes),
        _expense(date: sameDay, amount: 100, subcategory: ExpenseSubcategory.taxes),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.taxes);

      expect(group.attributedCost, isNull);
    });

    test('subcategories are isolated — one does not satisfy another\'s threshold', () {
      final costs = [
        _expense(date: DateTime(2026, 1, 1), amount: 100, subcategory: ExpenseSubcategory.financing),
        _expense(date: DateTime(2026, 2, 1), amount: 100, subcategory: ExpenseSubcategory.taxes),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);

      expect(_groupOf(result, CostAllocationGroupKind.financing).attributedCost, isNull);
      expect(_groupOf(result, CostAllocationGroupKind.taxes).attributedCost, isNull);
    });
  });

  group('direct (soma bruta, sem taxa)', () {
    test('sums only entries inside the period, no smoothing', () {
      final costs = [
        _expense(date: DateTime(2026, 10, 5), amount: 20, subcategory: ExpenseSubcategory.parking),
        _expense(date: DateTime(2026, 10, 6), amount: 15, subcategory: ExpenseSubcategory.toll),
        _expense(date: DateTime(2026, 10, 7), amount: 300, subcategory: ExpenseSubcategory.fine),
        // Fora do período — não deveria contar.
        _expense(date: DateTime(2026, 9, 1), amount: 999, subcategory: ExpenseSubcategory.carWash),
        // Método diferente — não deveria contar aqui.
        _expense(date: DateTime(2026, 10, 1), amount: 500, subcategory: ExpenseSubcategory.financing),
      ];
      final result = calculator.calculate(costs: costs, shifts: const [], period: october);
      final group = _groupOf(result, CostAllocationGroupKind.direct);

      expect(group.rawCost, closeTo(335, 0.01));
      expect(group.attributedCost, group.rawCost); // direto nunca suaviza
    });
  });

  group('CostAllocationResult (agregado)', () {
    test('a locked group falls back to raw without blocking the others (opção b)', () {
      final costs = [
        // Manutenção: só 1 lançamento — trava.
        _maintenance(date: DateTime(2026, 9, 1), amount: 500),
        // Financiamento: 2 lançamentos — estima normal.
        _expense(date: DateTime(2026, 1, 1), amount: 800, subcategory: ExpenseSubcategory.financing),
        _expense(date: DateTime(2026, 1, 31), amount: 850, subcategory: ExpenseSubcategory.financing),
        // Direto.
        _expense(date: DateTime(2026, 10, 5), amount: 50, subcategory: ExpenseSubcategory.parking),
      ];
      final shifts = [
        _shift(start: DateTime(2026, 9, 1), initialKm: 0, finalKm: 100),
      ];

      final result = calculator.calculate(costs: costs, shifts: shifts, period: october);

      expect(result.isFullyEstimated, isFalse);
      final maintenance = _groupOf(result, CostAllocationGroupKind.maintenance);
      expect(maintenance.attributedCost, isNull);
      // O total ainda soma alguma coisa — não trava tudo por causa de um
      // grupo só (opção b, confirmada com o usuário).
      expect(result.attributedTotal, greaterThan(0));
      expect(
        result.attributedTotal,
        closeTo(result.groups.fold<double>(0, (t, g) => t + g.effectiveCost), 0.0001),
      );
    });

    test('with no data anywhere, everything is a legitimate zero and fully estimated', () {
      final result = calculator.calculate(costs: const [], shifts: const [], period: october);

      expect(result.rawTotal, 0);
      expect(result.attributedTotal, 0);
      expect(result.isFullyEstimated, isTrue);
    });
  });
}
