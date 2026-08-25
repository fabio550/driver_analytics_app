import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/cost/domain/validators/cost_validator.dart';

class CreateExpenseCostUseCase {
  final CostRepository _repository;
  final CostValidator _validator;
  final IdGenerator _idGenerator;

  const CreateExpenseCostUseCase({
    required this._repository,
    required this._validator,
    required this._idGenerator,
  });

  Future<Result<ExpenseCostEntity, List<ValidationFailure<CostField>>>>
      execute({
    required ExpenseSubcategory subcategory,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final cost = ExpenseCostEntity(
      id: _idGenerator.generate(),
      subcategory: subcategory,
      amount: amount,
      date: date,
      description: description,
    );

    final failures = _validator.validate(cost);
    if (failures.isNotEmpty) {
      return Failure<ExpenseCostEntity, List<ValidationFailure<CostField>>>(
          failures);
    }

    await _repository.create(cost);
    return Success<ExpenseCostEntity, List<ValidationFailure<CostField>>>(
        cost);
  }
}
