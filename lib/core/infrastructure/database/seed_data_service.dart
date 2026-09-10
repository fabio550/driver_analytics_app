import 'dart:math';

import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';

/// Popula ~6 meses de histórico direto nos repositórios (sem passar pelos
/// use cases/validators — mais rápido pra gerar volume, e o objetivo aqui
/// é dado plausível, não validação de formulário). Existe só pra dar
/// massa suficiente pra exercitar o rateio de custo (`CostAllocationCalculator`):
/// janela de combustível que precisa expandir mês a mês, manutenção com
/// um gasto pontual caro que deveria diluir no histórico todo, e
/// financiamento/IPVA/seguro com intervalo real entre lançamentos.
///
/// Debug-only por natureza — ver o botão em `HomePage` atrás de
/// `kDebugMode`. Nunca chame isso fora de um ambiente de desenvolvimento:
/// ele não limpa dado existente, só acrescenta.
class SeedDataService {
  final ShiftRepository shiftRepository;
  final CostRepository costRepository;
  final IdGenerator idGenerator;

  const SeedDataService({
    required this.shiftRepository,
    required this.costRepository,
    required this.idGenerator,
  });

  Future<void> seed() async {
    final now = DateTime.now();
    final random = Random(42); // determinístico — mesmo dado toda vez que roda

    const kmPerLiter = 12.0;
    const pricePerLiter = 5.85;
    const revenuePerKm = 2.6;

    var odometer = 30000.0;
    var lastFuelOdometer = odometer;

    final start = DateTime(now.year, now.month - 6, now.day);
    var day = start;
    while (day.isBefore(now)) {
      // 3 jornadas por semana: segunda, quarta, sexta.
      if (day.weekday == DateTime.monday ||
          day.weekday == DateTime.wednesday ||
          day.weekday == DateTime.friday) {
        final km = 60.0 + random.nextInt(40); // 60-99km por jornada
        final initialKm = odometer;
        odometer += km;
        final earnings = km * (revenuePerKm + random.nextDouble());

        await shiftRepository.create(
          ShiftEntity(
            id: idGenerator.generate(),
            status: ShiftStatus.submitted,
            initialKm: initialKm,
            finalKm: odometer,
            earnings: double.parse(earnings.toStringAsFixed(2)),
            startTime: DateTime(day.year, day.month, day.day, 8),
            endTime: DateTime(day.year, day.month, day.day, 16),
          ),
        );

        // Abastecimento a cada ~500km rodados desde o último tanque cheio.
        if (odometer - lastFuelOdometer >= 500) {
          final liters = (odometer - lastFuelOdometer) / kmPerLiter;
          await costRepository.create(
            FuelCostEntity(
              id: idGenerator.generate(),
              amount: double.parse((liters * pricePerLiter).toStringAsFixed(2)),
              date: DateTime(day.year, day.month, day.day),
              subcategory: FuelSubcategory.gasolineCommon,
              odometerKm: odometer,
              quantity: double.parse(liters.toStringAsFixed(1)),
              isFullTank: true,
            ),
          );
          lastFuelOdometer = odometer;
        }
      }
      day = day.add(const Duration(days: 1));
    }

    // Manutenção: uma troca de óleo barata há 5 meses, um pneu caro há 1
    // mês — pra mostrar a suavização de verdade (sem ela, o mês do pneu
    // teria um R$/km absurdo).
    await costRepository.create(
      MaintenanceCostEntity(
        id: idGenerator.generate(),
        amount: 180,
        date: DateTime(now.year, now.month - 5, 10),
        subcategory: MaintenanceSubcategory.oilChange,
      ),
    );
    await costRepository.create(
      MaintenanceCostEntity(
        id: idGenerator.generate(),
        amount: 950,
        date: DateTime(now.year, now.month - 1, 15),
        subcategory: MaintenanceSubcategory.tireReplacement,
      ),
    );

    // Financiamento: parcela mensal nos últimos 6 meses.
    for (var i = 0; i < 6; i++) {
      await costRepository.create(
        ExpenseCostEntity(
          id: idGenerator.generate(),
          amount: 650,
          date: DateTime(now.year, now.month - i, 5),
          subcategory: ExpenseSubcategory.financing,
        ),
      );
    }

    // IPVA e seguro: cadência anual — 2 lançamentos espaçados o
    // suficiente pra medir um intervalo real de verdade.
    await costRepository.create(
      ExpenseCostEntity(
        id: idGenerator.generate(),
        amount: 1200,
        date: DateTime(now.year - 1, now.month, 20),
        subcategory: ExpenseSubcategory.taxes,
      ),
    );
    await costRepository.create(
      ExpenseCostEntity(
        id: idGenerator.generate(),
        amount: 1350,
        date: DateTime(now.year, now.month, 20),
        subcategory: ExpenseSubcategory.taxes,
      ),
    );
    await costRepository.create(
      ExpenseCostEntity(
        id: idGenerator.generate(),
        amount: 900,
        date: DateTime(now.year - 1, now.month - 1, 1),
        subcategory: ExpenseSubcategory.insurance,
      ),
    );
    await costRepository.create(
      ExpenseCostEntity(
        id: idGenerator.generate(),
        amount: 980,
        date: DateTime(now.year, now.month - 1, 1),
        subcategory: ExpenseSubcategory.insurance,
      ),
    );

    // Despesas diretas espalhadas nos últimos 2 meses — não deveriam
    // aparecer suavizadas em lugar nenhum.
    const directSubcategories = [
      ExpenseSubcategory.parking,
      ExpenseSubcategory.toll,
      ExpenseSubcategory.carWash,
      ExpenseSubcategory.fine,
    ];
    for (var i = 0; i < 10; i++) {
      final date = now.subtract(Duration(days: random.nextInt(60)));
      await costRepository.create(
        ExpenseCostEntity(
          id: idGenerator.generate(),
          amount: (10 + random.nextInt(90)).toDouble(),
          date: DateTime(date.year, date.month, date.day),
          subcategory: directSubcategories[random.nextInt(directSubcategories.length)],
        ),
      );
    }
  }
}
