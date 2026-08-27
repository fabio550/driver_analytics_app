// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/domain/validators/earning_validator.dart';

class CreateRideEarningUseCase {
  final EarningRepository _repository;
  final EarningValidator _validator;
  final IdGenerator _idGenerator;

  const CreateRideEarningUseCase({
    required EarningRepository repository,
    required EarningValidator validator,
    required IdGenerator idGenerator,
  })  : _repository = repository,
        _validator = validator,
        _idGenerator = idGenerator;

  Future<Result<EarningEntity, List<ValidationFailure<EarningField>>>> execute({
    String? shiftId,
    required DateTime occurredAt,
    String? description,
    required RideApp app,
    required RideServiceType serviceType,
    required double fare,
    double surge = 0,
    double tip = 0,
    required int durationSeconds,
    required double distanceKm,
    required RideStatus status,
    String? pickupCep,
    String? destinationCep,
    String? pickupDistrictId,
    String? destinationDistrictId,
  }) async {
    final earning = RideEarningEntity(
      id: _idGenerator.generate(),
      shiftId: shiftId,
      occurredAt: occurredAt,
      description: description,
      app: app,
      serviceType: serviceType,
      fare: fare,
      surge: surge,
      tip: tip,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      status: status,
      pickupCep: pickupCep,
      destinationCep: destinationCep,
      pickupDistrictId: pickupDistrictId,
      destinationDistrictId: destinationDistrictId,
    );

    final failures = _validator.validate(earning);
    if (failures.isNotEmpty) {
      return Failure<EarningEntity, List<ValidationFailure<EarningField>>>(failures);
    }

    await _repository.create(earning);
    return Success<EarningEntity, List<ValidationFailure<EarningField>>>(earning);
  }
}