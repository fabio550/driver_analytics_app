// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/domain/validators/earning_validator.dart';

class CreatePromotionEarningUseCase {
  final EarningRepository _repository;
  final EarningValidator _validator;
  final IdGenerator _idGenerator;

  const CreatePromotionEarningUseCase({
    required EarningRepository repository,
    required EarningValidator validator,
    required IdGenerator idGenerator,
  })  : _repository = repository,
        _validator = validator,
        _idGenerator = idGenerator;

  Future<Result<EarningEntity, List<ValidationFailure<EarningField>>>> execute({
    String? shiftId,
    required DateTime occurredAt,
    required double amount,
    String? description,
  }) async {
    final earning = PromotionEarningEntity(
      id: _idGenerator.generate(),
      shiftId: shiftId,
      occurredAt: occurredAt,
      description: description,
      amount: amount,
    );

    final failures = _validator.validate(earning);
    if (failures.isNotEmpty) {
      return Failure<EarningEntity, List<ValidationFailure<EarningField>>>(failures);
    }

    await _repository.create(earning);
    return Success<EarningEntity, List<ValidationFailure<EarningField>>>(earning);
  }
}