import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';

class CostValidator {
  const CostValidator();

  List<ValidationFailure<CostField>> validate(CostEntity cost) {
    final failures = <ValidationFailure<CostField>>[];

    _validateAmount(cost, failures);
    _validateOtherDescription(cost, failures);

    switch (cost) {
      case FuelCostEntity():
        _validateFuel(cost, failures);
      case MaintenanceCostEntity():
        _validateMaintenance(cost, failures);
      case ExpenseCostEntity():
        break;
    }

    return failures;
  }

  void _validateAmount(
    CostEntity cost,
    List<ValidationFailure<CostField>> failures,
  ) {
    if (cost.amount <= 0) {
      failures.add(const ValidationFailure(
        field: CostField.amount,
        message: 'Valor deve ser maior que zero.',
      ));
    }
  }

  void _validateOtherDescription(
    CostEntity cost,
    List<ValidationFailure<CostField>> failures,
  ) {
    final isOther = switch (cost) {
      FuelCostEntity() => false,
      MaintenanceCostEntity(:final subcategory) =>
        subcategory == MaintenanceSubcategory.other,
      ExpenseCostEntity(:final subcategory) =>
        subcategory == ExpenseSubcategory.other,
    };

    final hasDescription =
        cost.description != null && cost.description!.trim().isNotEmpty;

    if (isOther && !hasDescription) {
      failures.add(const ValidationFailure(
        field: CostField.description,
        message: 'Descreva o que é esse custo quando a subcategoria for "outros".',
      ));
    }
  }

  void _validateFuel(
    FuelCostEntity cost,
    List<ValidationFailure<CostField>> failures,
  ) {
    if (cost.odometerKm <= 0) {
      failures.add(const ValidationFailure(
        field: CostField.odometerKm,
        message: 'Km do odômetro deve ser maior que zero.',
      ));
    }
    if (cost.quantity <= 0) {
      failures.add(ValidationFailure(
        field: CostField.quantity,
        message: cost.subcategory.family == FuelFamily.electric
            ? 'Quantidade (kWh) deve ser maior que zero.'
            : 'Quantidade (litros) deve ser maior que zero.',
      ));
    }
  }

  void _validateMaintenance(
    MaintenanceCostEntity cost,
    List<ValidationFailure<CostField>> failures,
  ) {
    final odometerKm = cost.odometerKm;
    if (odometerKm != null && odometerKm <= 0) {
      failures.add(const ValidationFailure(
        field: CostField.odometerKm,
        message: 'Km do odômetro deve ser maior que zero.',
      ));
    }
  }
}
