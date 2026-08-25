import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/cost/domain/validators/cost_validator.dart';

class CreateMaintenanceCostUseCase {
  final CostRepository _repository;
  final CostValidator _validator;
  final IdGenerator _idGenerator;

  const CreateMaintenanceCostUseCase({
    required this._repository,
    required this._validator,
    required this._idGenerator,
  });

  Future<Result<MaintenanceCostEntity, List<ValidationFailure<CostField>>>>
      execute({
    required MaintenanceSubcategory subcategory,
    required double amount,
    required DateTime date,
    double? odometerKm,
    String? description,
  }) async {
    final cost = MaintenanceCostEntity(
      id: _idGenerator.generate(),
      subcategory: subcategory,
      amount: amount,
      date: date,
      description: description,
      odometerKm: odometerKm,
    );

    final failures = _validator.validate(cost);
    if (failures.isNotEmpty) {
      return Failure<MaintenanceCostEntity,
          List<ValidationFailure<CostField>>>(failures);
    }

    await _repository.create(cost);
    return Success<MaintenanceCostEntity, List<ValidationFailure<CostField>>>(
        cost);
  }
}
