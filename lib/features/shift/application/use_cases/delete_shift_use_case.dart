import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';

class DeleteShiftUseCase {
  final ShiftRepository _repository;

  const DeleteShiftUseCase({
    required this._repository,
  });

  Future<Result<void, Object>> execute({
    required String shiftId,
  }) async {
    try {
      await _repository.delete(shiftId);
      return const Success<void, Object>(null);
    } catch (error) {
      return Failure<void, Object>(error);
    }
  }
}
