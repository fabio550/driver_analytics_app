import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/validators/shift_validator.dart';

class StartShiftUseCase {
  final ShiftRepository _repository;
  final ShiftValidator _validator;
  final IdGenerator _idGenerator;

  const StartShiftUseCase({
    required ShiftRepository repository,
    required ShiftValidator validator,
    required IdGenerator idGenerator,
  })  : _repository = repository,
        _validator = validator,
        _idGenerator = idGenerator;

  Future<Result<ShiftEntity, List<ValidationFailure<ShiftField>>>> execute({
    required double initialKm,
    required DateTime now,
  }) async {
    final shift = ShiftEntity.start(
      id: _idGenerator.generate(),
      initialKm: initialKm,
      now: now,
    );

    final failures = _validator.validate(shift);
    if (failures.isNotEmpty) {
      return Failure<ShiftEntity, List<ValidationFailure<ShiftField>>>(
          failures);
    }

    await _repository.create(shift);
    return Success<ShiftEntity, List<ValidationFailure<ShiftField>>>(shift);
  }
}
