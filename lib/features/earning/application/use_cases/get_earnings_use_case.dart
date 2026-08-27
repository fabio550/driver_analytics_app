// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';

class GetEarningsUseCase {
  final EarningRepository _repository;

  const GetEarningsUseCase({required EarningRepository repository}) : _repository = repository;

  Future<List<EarningEntity>> execute() {
    return _repository.getAll();
  }
}