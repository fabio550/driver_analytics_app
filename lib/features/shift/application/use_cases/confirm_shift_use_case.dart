import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';

/// Marca uma jornada já finalizada como [ShiftStatus.submitted] — o "envio"
/// definitivo que o motorista confirma na tela de resumo.
class ConfirmShiftUseCase {
  final ShiftRepository _repository;

  const ConfirmShiftUseCase({
    required this._repository,
  });

  Future<Result<void, Object>> execute({
    required ShiftEntity shift,
  }) async {
    try {
      await _repository.update(shift.copyWith(status: ShiftStatus.submitted));
      return const Success<void, Object>(null);
    } catch (error) {
      return Failure<void, Object>(error);
    }
  }
}
