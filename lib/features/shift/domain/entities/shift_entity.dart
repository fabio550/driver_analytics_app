import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';

class ShiftEntity {
  final String id;
  final ShiftStatus status;
  final double initialKm;
  final double? finalKm;
  final double? earnings;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ShiftPauseEntity> pauses;

  const ShiftEntity({
    required this.id,
    required this.status,
    required this.initialKm,
    this.finalKm,
    this.earnings,
    required this.startTime,
    this.endTime,
    this.pauses = const [],
  });

  double get distanceKm {
    if (finalKm == null) return 0;
    return finalKm! - initialKm;
  }

  double? earningsPerKm() {
    if (earnings == null || distanceKm <= 0) return null;
    return earnings! / distanceKm;
  }

  double? earningsPerHour(DateTime now) {
    if (earnings == null || endTime == null) return null;
    final hours = elapsedTime(now).inMinutes / 60;
    if (hours <= 0) return null;
    return earnings! / hours;
  }

  Duration elapsedTime(DateTime now) {
    final end = endTime ?? now;
    return end.difference(startTime);
  }

  Duration totalPausedTime(DateTime now) {
    return pauses.fold(
      Duration.zero,
      (total, pause) => total + pause.duration(now),
    );
  }

  Duration workedTime(DateTime now) {
    return elapsedTime(now) - totalPausedTime(now);
  }

  bool get isPaused => pauses.isNotEmpty && pauses.last.isRunning;

    bool get isPaused => pauses.isNotEmpty && pauses.last.isRunning;

  /// Cria uma jornada recém-iniciada (status [ShiftStatus.active]).
  factory ShiftEntity.start({
    required String id,
    required double initialKm,
    required DateTime now,
  }) {
    return ShiftEntity(
      id: id,
      status: ShiftStatus.active,
      initialKm: initialKm,
      startTime: now,
    );
  }

  /// Abre uma nova pausa. A jornada precisa estar ativa (não pausada).
  ShiftEntity pause({
    required String pauseId,
    required DateTime now,
  }) {
    if (isPaused) {
      throw StateError('Shift $id is already paused.');
    }
    return copyWith(
      status: ShiftStatus.paused,
      pauses: [
        ...pauses,
        ShiftPauseEntity(id: pauseId, startTime: now),
      ],
    );
  }

  /// Fecha a pausa em andamento. A jornada precisa estar pausada.
  ShiftEntity resume({required DateTime now}) {
    if (!isPaused) {
      throw StateError('Shift $id is not paused.');
    }
    final updatedPauses = [...pauses];
    updatedPauses[updatedPauses.length - 1] =
        updatedPauses.last.copyWith(endTime: now);
    return copyWith(
      status: ShiftStatus.active,
      pauses: updatedPauses,
    );
  }
  /// Finaliza a jornada. Se houver uma pausa em andamento, ela é fechada
  /// junto (reaproveitando [resume]) antes de marcar a jornada como
  /// [ShiftStatus.finished].
  ShiftEntity finish({
    required DateTime now,
    required double finalKm,
    double? earnings,
  }) {
    final withClosedPause = isPaused ? resume(now: now) : this;
    return withClosedPause.copyWith(
      status: ShiftStatus.finished,
      finalKm: finalKm,
      earnings: earnings,
      endTime: now,
    );
  }

  ShiftEntity copyWith({
    ShiftStatus? status,
    double? initialKm,
    double? finalKm,
    double? earnings,
    DateTime? startTime,
    DateTime? endTime,
    List<ShiftPauseEntity>? pauses,
  }) {
    return ShiftEntity(
      id: id,
      status: status ?? this.status,
      initialKm: initialKm ?? this.initialKm,
      finalKm: finalKm ?? this.finalKm,
      earnings: earnings ?? this.earnings,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pauses: pauses ?? this.pauses,
    );
  }
}
