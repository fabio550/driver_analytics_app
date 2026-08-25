import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';

class DeleteCostUseCase {
  final CostRepository _repository;

  const DeleteCostUseCase({
    required this._repository,
  });

  Future<Result<void, Object>> execute({
    required String costId,
  }) async {
    try {
      await _repository.delete(costId);
      return const Success<void, Object>(null);
    } catch (error) {
      return Failure<void, Object>(error);
    }
  }
}
