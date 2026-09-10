import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/fuel_consumption_calculator.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_allocation_method.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/extensions/cost_allocation_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

/// Decompõe o custo do período em 6 fatias e calcula, pra cada uma, uma
/// taxa suavizada em cima de todo o histórico disponível — em vez da
/// soma bruta do que caiu dentro da janela exibida, que distorce quando
/// um lançamento caro (ou um custo fixo anual) cai perto da borda do
/// período. Ver a discussão de arquitetura: cada método de rateio usa a
/// janela que faz sentido pro próprio ciclo de vida do custo, não uma
/// janela única — manutenção e combustível têm ciclos completamente
/// diferentes, e um pneu não se paga em 90 dias.
class CostAllocationCalculator {
  const CostAllocationCalculator();

  CostAllocationResult calculate({
    required List<CostEntity> costs,
    required List<ShiftEntity> shifts,
    required AnalyticsPeriod period,
  }) {
    final groups = [
      _maintenanceGroup(costs, shifts, period),
      _fuelGroup(costs, shifts, period),
      _timeDrivenGroup(
        CostAllocationGroupKind.financing,
        ExpenseSubcategory.financing,
        costs,
        period,
      ),
      _timeDrivenGroup(
        CostAllocationGroupKind.taxes,
        ExpenseSubcategory.taxes,
        costs,
        period,
      ),
      _timeDrivenGroup(
        CostAllocationGroupKind.insurance,
        ExpenseSubcategory.insurance,
        costs,
        period,
      ),
      _directGroup(costs, period),
    ];

    final rawTotal = groups.fold<double>(0, (t, g) => t + g.rawCost);
    final attributedTotal = groups.fold<double>(0, (t, g) => t + g.effectiveCost);
    final isFullyEstimated = groups
        .where((g) => g.method != CostAllocationMethod.direct)
        .every((g) => g.isEstimated);

    return CostAllocationResult(
      groups: groups,
      rawTotal: rawTotal,
      attributedTotal: attributedTotal,
      isFullyEstimated: isFullyEstimated,
    );
  }

  /// Km rodado (jornadas confirmadas) entre [start] (inclusive) e [end]
  /// (exclusive) — mesma semântica de [AnalyticsPeriod.contains], só que
  /// parametrizada por datas soltas em vez de um período fechado, pra
  /// poder medir janelas arbitrárias (histórico todo, mês passado, etc).
  double _distanceInRange(List<ShiftEntity> shifts, DateTime start, DateTime end) {
    return shifts
        .where((s) => s.status == ShiftStatus.submitted)
        .where((s) => !s.startTime.isBefore(start) && s.startTime.isBefore(end))
        .fold<double>(0, (t, s) => t + s.distanceKm);
  }

  /// Manutenção: taxa R$/km sobre TODO o histórico até o fim do período.
  /// Nada de janela curta — um pneu ou uma correia dentada não se pagam
  /// em poucos meses, então diluir num recorte curto exagera a taxa.
  CostAllocationGroup _maintenanceGroup(
    List<CostEntity> costs,
    List<ShiftEntity> shifts,
    AnalyticsPeriod period,
  ) {
    final maintenanceCosts = costs.whereType<MaintenanceCostEntity>().toList();
    final rawCost = maintenanceCosts
        .where((c) => period.contains(c.date))
        .fold<double>(0, (t, c) => t + c.amount);

    final history = maintenanceCosts.where((c) => c.date.isBefore(period.end)).toList();

    if (history.isEmpty) {
      return CostAllocationGroup(
        kind: CostAllocationGroupKind.maintenance,
        method: CostAllocationMethod.kmDriven,
        rawCost: rawCost,
        attributedCost: 0,
      );
    }
    if (history.length < 2) {
      return CostAllocationGroup(
        kind: CostAllocationGroupKind.maintenance,
        method: CostAllocationMethod.kmDriven,
        rawCost: rawCost,
        attributedCost: null,
        note: 'Só 1 lançamento de manutenção no histórico — falta um '
            'segundo pra estabelecer uma taxa confiável.',
      );
    }

    final earliest = history.map((c) => c.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final totalCostAllTime = history.fold<double>(0, (t, c) => t + c.amount);
    final totalKmAllTime = _distanceInRange(shifts, earliest, period.end);

    if (totalKmAllTime <= 0) {
      return CostAllocationGroup(
        kind: CostAllocationGroupKind.maintenance,
        method: CostAllocationMethod.kmDriven,
        rawCost: rawCost,
        attributedCost: null,
        note: 'Sem km rodado registrado desde o primeiro lançamento de '
            'manutenção.',
      );
    }

    final rate = totalCostAllTime / totalKmAllTime;
    final periodKm = _distanceInRange(shifts, period.start, period.end);

    return CostAllocationGroup(
      kind: CostAllocationGroupKind.maintenance,
      method: CostAllocationMethod.kmDriven,
      rawCost: rawCost,
      attributedCost: rate * periodKm,
      note: 'Taxa baseada em todo o histórico de manutenção.',
    );
  }

  /// Combustível: taxa R$/km via consumo (custo/litro ÷ km/litro),
  /// reaproveitando [FuelConsumptionCalculator] — mesmo algoritmo do
  /// card "Combustível", só que alimentado com uma janela diferente.
  /// Começa no mês passado (preço de combustível varia rápido, uma
  /// janela curta reage mais rápido a isso) e expande um mês por vez
  /// até achar 2 tanques cheios, no limite usando o histórico inteiro.
  CostAllocationGroup _fuelGroup(
    List<CostEntity> costs,
    List<ShiftEntity> shifts,
    AnalyticsPeriod period,
  ) {
    final allFuel = costs
        .whereType<FuelCostEntity>()
        .where((c) => c.date.isBefore(period.end))
        .toList();
    final rawCost = allFuel
        .where((c) => period.contains(c.date))
        .fold<double>(0, (t, c) => t + c.amount);

    if (allFuel.isEmpty) {
      return CostAllocationGroup(
        kind: CostAllocationGroupKind.fuel,
        method: CostAllocationMethod.kmDriven,
        rawCost: rawCost,
        attributedCost: 0,
      );
    }

    final earliestFuel = allFuel.map((c) => c.date).reduce((a, b) => a.isBefore(b) ? a : b);

    // Âncora no último dia real do período, não em period.end — period.end
    // é o limite exclusivo (já é o 1º dia do mês seguinte quando o período
    // é um mês fechado), então usar period.end.month direto pra subtrair
    // mês dava o próprio mês do período, não o anterior.
    final periodLastDay = period.end.subtract(const Duration(days: 1));

    var monthsBack = 1;
    var reachedAllTime = false;
    var windowStart = periodLastDay;
    var stats = FuelConsumptionStats.empty;
    while (true) {
      windowStart = DateTime(periodLastDay.year, periodLastDay.month - monthsBack, 1);
      reachedAllTime = !windowStart.isAfter(earliestFuel);
      if (reachedAllTime) windowStart = earliestFuel;

      final windowFuel = allFuel.where((c) => !c.date.isBefore(windowStart)).toList();
      stats = const FuelConsumptionCalculator().calculate(windowFuel);

      if (stats.kmPerLiter != null || reachedAllTime) break;
      monthsBack++;
    }

    final rate = (stats.kmPerLiter != null && stats.costPerLiter != null)
        ? stats.costPerLiter! / stats.kmPerLiter!
        : null;

    if (rate == null) {
      return CostAllocationGroup(
        kind: CostAllocationGroupKind.fuel,
        method: CostAllocationMethod.kmDriven,
        rawCost: rawCost,
        attributedCost: null,
        note: 'Menos de 2 tanques cheios mesmo em todo o histórico.',
      );
    }

    final periodKm = _distanceInRange(shifts, period.start, period.end);

    return CostAllocationGroup(
      kind: CostAllocationGroupKind.fuel,
      method: CostAllocationMethod.kmDriven,
      rawCost: rawCost,
      attributedCost: rate * periodKm,
      note: reachedAllTime
          ? 'Taxa baseada em todo o histórico de combustível.'
          : 'Taxa baseada em combustível desde ${windowStart.formattedDDMMYYYY}.',
    );
  }

  /// Financiamento/IPVA/seguro: cada subcategoria isolada, taxa derivada
  /// do intervalo real entre os 2 lançamentos mais recentes — se adapta
  /// sozinho à cadência de cada uma (mensal pro financiamento, anual pro
  /// IPVA/seguro) sem eu precisar assumir esse número em lugar nenhum.
  CostAllocationGroup _timeDrivenGroup(
    CostAllocationGroupKind kind,
    ExpenseSubcategory subcategory,
    List<CostEntity> costs,
    AnalyticsPeriod period,
  ) {
    final rawCost = costs
        .whereType<ExpenseCostEntity>()
        .where((c) => c.subcategory == subcategory && period.contains(c.date))
        .fold<double>(0, (t, c) => t + c.amount);

    final history = costs
        .whereType<ExpenseCostEntity>()
        .where((c) => c.subcategory == subcategory && c.date.isBefore(period.end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (history.isEmpty) {
      return CostAllocationGroup(
        kind: kind,
        method: CostAllocationMethod.timeDriven,
        rawCost: rawCost,
        attributedCost: 0,
      );
    }
    if (history.length < 2) {
      return CostAllocationGroup(
        kind: kind,
        method: CostAllocationMethod.timeDriven,
        rawCost: rawCost,
        attributedCost: null,
        note: 'Só 1 lançamento no histórico — falta um segundo pra medir '
            'o intervalo real entre lançamentos.',
      );
    }

    final last = history.last;
    final previous = history[history.length - 2];
    final intervalDays = last.date.difference(previous.date).inDays;

    if (intervalDays <= 0) {
      return CostAllocationGroup(
        kind: kind,
        method: CostAllocationMethod.timeDriven,
        rawCost: rawCost,
        attributedCost: null,
        note: 'Os 2 últimos lançamentos caem na mesma data.',
      );
    }

    final ratePerDay = last.amount / intervalDays;
    final periodDays = period.end.difference(period.start).inDays;

    return CostAllocationGroup(
      kind: kind,
      method: CostAllocationMethod.timeDriven,
      rawCost: rawCost,
      attributedCost: ratePerDay * periodDays,
      note: 'Taxa baseada no intervalo entre os 2 últimos lançamentos '
          '($intervalDays dias).',
    );
  }

  /// Estacionamento, lavagem, multa, pedágio, outros: soma bruta, sem
  /// taxa — não fazem sentido suavizados.
  CostAllocationGroup _directGroup(List<CostEntity> costs, AnalyticsPeriod period) {
    final rawCost = costs
        .whereType<ExpenseCostEntity>()
        .where((c) => c.allocationMethod == CostAllocationMethod.direct)
        .where((c) => period.contains(c.date))
        .fold<double>(0, (t, c) => t + c.amount);

    return CostAllocationGroup(
      kind: CostAllocationGroupKind.direct,
      method: CostAllocationMethod.direct,
      rawCost: rawCost,
      attributedCost: rawCost,
    );
  }
}
