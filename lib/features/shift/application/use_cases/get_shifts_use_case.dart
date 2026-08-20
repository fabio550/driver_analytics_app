import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';

class GetShiftsUseCase {
  final ShiftRepository _repository;

  const GetShiftsUseCase({
    required this._repository,
  });

  Future<List<ShiftEntity>> execute() {
    return _repository.getAll();
  }
}
