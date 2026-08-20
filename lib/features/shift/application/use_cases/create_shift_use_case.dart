import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/inputs/pause_input.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/validators/shift_validator.dart';

class CreateShiftUseCase {
  final ShiftRepository _repository;
  final ShiftValidator _validator;
  final IdGenerator _idGenerator;

  const CreateShiftUseCase({
    required this._repository,
    required this._validator,
    required this._idGenerator,
  });

  Future<Result<ShiftEntity, List<ValidationFailure<ShiftField>>>> execute({
    required double initialKm,
    required DateTime startTime,
    required ShiftStatus status,
    double? finalKm,
    double? earnings,
    DateTime? endTime,
    List<PauseInput> pauses = const [],
  }) async {
    final shift = ShiftEntity(
      id: _idGenerator.generate(),
      initialKm: initialKm,
      finalKm: finalKm,
      earnings: earnings,
      startTime: startTime,
      endTime: endTime,
      status: status,
      pauses: pauses
          .map((p) => ShiftPauseEntity(
                id: _idGenerator.generate(),
                startTime: p.startTime,
                endTime: p.endTime,
              ))
          .toList(),
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
