import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';

class GetShiftsUseCase {
  final ShiftRepository _repository;

  const GetShiftsUseCase({
    required this._repository,
  });

  /// Só retorna jornadas [ShiftStatus.submitted] — rascunhos em andamento
  /// (idle/active/paused) ou finalizados mas ainda não confirmados
  /// (finished) não devem aparecer no histórico.
  Future<List<ShiftEntity>> execute() async {
    final shifts = await _repository.getAll();
    return shifts.where((s) => s.status == ShiftStatus.submitted).toList();
  }
}
