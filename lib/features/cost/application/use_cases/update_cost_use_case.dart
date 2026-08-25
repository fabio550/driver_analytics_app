import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/cost/domain/validators/cost_validator.dart';

class UpdateCostUseCase {
  final CostRepository _repository;
  final CostValidator _validator;

  const UpdateCostUseCase({
    required this._repository,
    required this._validator,
  });

  Future<Result<CostEntity, List<ValidationFailure<CostField>>>> execute({
    required CostEntity cost,
  }) async {
    final failures = _validator.validate(cost);
    if (failures.isNotEmpty) {
      return Failure<CostEntity, List<ValidationFailure<CostField>>>(
          failures);
    }

    await _repository.update(cost);
    return Success<CostEntity, List<ValidationFailure<CostField>>>(cost);
  }
}
