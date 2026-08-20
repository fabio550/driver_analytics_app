import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/validators/shift_validator.dart';

class UpdateShiftUseCase {
  final ShiftRepository _repository;
  final ShiftValidator _validator;

  const UpdateShiftUseCase({
    required this._repository,
    required this._validator,
  });

  Future<Result<ShiftEntity, List<ValidationFailure<ShiftField>>>> execute({
    required ShiftEntity shift,
  }) async {
    final failures = _validator.validate(shift);

    if (failures.isNotEmpty) {
      return Failure<ShiftEntity, List<ValidationFailure<ShiftField>>>(
          failures);
    }

    await _repository.update(shift);
    return Success<ShiftEntity, List<ValidationFailure<ShiftField>>>(shift);
  }
}
