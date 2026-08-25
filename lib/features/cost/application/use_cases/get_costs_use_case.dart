import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';

class GetCostsUseCase {
  final CostRepository _repository;

  const GetCostsUseCase({
    required this._repository,
  });

  Future<List<CostEntity>> execute() {
    return _repository.getAll();
  }
}
