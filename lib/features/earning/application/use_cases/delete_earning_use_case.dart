// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';

class DeleteEarningUseCase {
  final EarningRepository _repository;

  const DeleteEarningUseCase({required EarningRepository repository}) : _repository = repository;

  Future<Result<void, List<ValidationFailure<EarningField>>>> execute({
    required String earningId,
  }) async {
    await _repository.delete(earningId);
    return const Success<void, List<ValidationFailure<EarningField>>>(null);
  }
}