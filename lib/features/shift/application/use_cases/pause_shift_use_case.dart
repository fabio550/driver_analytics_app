import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/validators/shift_validator.dart';

class PauseShiftUseCase {
  final ShiftRepository _repository;
  final ShiftValidator _validator;
  final IdGenerator _idGenerator;

  const PauseShiftUseCase({
    required this._repository,
    required this._validator,
    required this._idGenerator,
  });

  Future<Result<ShiftEntity, List<ValidationFailure<ShiftField>>>> execute({
    required ShiftEntity shift,
    required DateTime now,
  }) async {
    final paused = shift.pause(
      pauseId: _idGenerator.generate(),
      now: now,
    );

    final failures = _validator.validate(paused);
    if (failures.isNotEmpty) {
      return Failure<ShiftEntity, List<ValidationFailure<ShiftField>>>(
          failures);
    }

    await _repository.update(paused);
    return Success<ShiftEntity, List<ValidationFailure<ShiftField>>>(paused);
  }
}
