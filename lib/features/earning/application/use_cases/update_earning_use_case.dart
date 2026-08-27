// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/domain/validators/earning_validator.dart';

class UpdateEarningUseCase {
  final EarningRepository _repository;
  final EarningValidator _validator;

  const UpdateEarningUseCase({
    required EarningRepository repository,
    required EarningValidator validator,
  })  : _repository = repository,
        _validator = validator;

  Future<Result<EarningEntity, List<ValidationFailure<EarningField>>>> execute({
    required EarningEntity earning,
  }) async {
    final failures = _validator.validate(earning);
    if (failures.isNotEmpty) {
      return Failure<EarningEntity, List<ValidationFailure<EarningField>>>(failures);
    }
    await _repository.update(earning);
    return Success<EarningEntity, List<ValidationFailure<EarningField>>>(earning);
  }
}