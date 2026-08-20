import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/validators/shift_validator.dart';

class FinishShiftUseCase {
  final ShiftRepository _repository;
  final ShiftValidator _validator;

  const FinishShiftUseCase({
    required this._repository,
    required this._validator,
  });

  Future<Result<ShiftEntity, List<ValidationFailure<ShiftField>>>> execute({
    required ShiftEntity shift,
    required DateTime now,
    required double finalKm,
    double? earnings,
  }) async {
    final finished = shift.finish(
      now: now,
      finalKm: finalKm,
      earnings: earnings,
    );

    final failures = _validator.validate(finished);
    if (failures.isNotEmpty) {
      return Failure<ShiftEntity, List<ValidationFailure<ShiftField>>>(
          failures);
    }

    await _repository.update(finished);
    return Success<ShiftEntity, List<ValidationFailure<ShiftField>>>(
        finished);
  }
}
