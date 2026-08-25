import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/cost/domain/validators/cost_validator.dart';

class CreateFuelCostUseCase {
  final CostRepository _repository;
  final CostValidator _validator;
  final IdGenerator _idGenerator;

  const CreateFuelCostUseCase({
    required this._repository,
    required this._validator,
    required this._idGenerator,
  });

  Future<Result<FuelCostEntity, List<ValidationFailure<CostField>>>> execute({
    required FuelSubcategory subcategory,
    required double amount,
    required DateTime date,
    required double odometerKm,
    required double quantity,
    bool isFullTank = false,
    bool previousFillUpMissing = false,
    String? description,
  }) async {
    final cost = FuelCostEntity(
      id: _idGenerator.generate(),
      subcategory: subcategory,
      amount: amount,
      date: date,
      description: description,
      odometerKm: odometerKm,
      quantity: quantity,
      isFullTank: isFullTank,
      previousFillUpMissing: previousFillUpMissing,
    );

    final failures = _validator.validate(cost);
    if (failures.isNotEmpty) {
      return Failure<FuelCostEntity, List<ValidationFailure<CostField>>>(
          failures);
    }

    await _repository.create(cost);
    return Success<FuelCostEntity, List<ValidationFailure<CostField>>>(cost);
  }
}
