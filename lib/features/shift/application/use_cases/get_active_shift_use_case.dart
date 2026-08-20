import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';

/// Recupera uma jornada em andamento (`active`/`paused`) já persistida —
/// usado para restaurar o timer se o app for reaberto no meio de uma
/// jornada. Assume no máximo uma jornada em andamento por vez (a UI não
/// permite iniciar uma nova enquanto outra estiver ativa).
class GetActiveShiftUseCase {
  final ShiftRepository _repository;

  const GetActiveShiftUseCase({
    required this._repository,
  });

  Future<ShiftEntity?> execute() async {
    final shifts = await _repository.getAll();
    for (final shift in shifts) {
      if (shift.status == ShiftStatus.active ||
          shift.status == ShiftStatus.paused) {
        return shift;
      }
    }
    return null;
  }
}
