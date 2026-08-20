import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_pause_form_entry.dart';

class ShiftFormState {
  final String initialKm;
  final String finalKm;
  final String earnings;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<ShiftPauseFormEntry> pauses;
  final List<ValidationFailure<ShiftField>> failures;
  final bool isSubmitting;
  final int _nextPauseId;

  const ShiftFormState({
    this.initialKm = '',
    this.finalKm = '',
    this.earnings = '',
    this.startTime,
    this.endTime,
    this.pauses = const [],
    this.failures = const [],
    this.isSubmitting = false,
    int nextPauseId = 0,
  }) : _nextPauseId = nextPauseId;

  /// Próximo id local disponível para uma nova [ShiftPauseFormEntry].
  int get nextPauseId => _nextPauseId;

  ShiftFormState copyWith({
    String? initialKm,
    String? finalKm,
    String? earnings,
    DateTime? startTime,
    DateTime? endTime,
    List<ShiftPauseFormEntry>? pauses,
    List<ValidationFailure<ShiftField>>? failures,
    bool? isSubmitting,
    int? nextPauseId,
  }) {
    return ShiftFormState(
      initialKm: initialKm ?? this.initialKm,
      finalKm: finalKm ?? this.finalKm,
      earnings: earnings ?? this.earnings,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pauses: pauses ?? this.pauses,
      failures: failures ?? this.failures,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      nextPauseId: nextPauseId ?? _nextPauseId,
    );
  }

  /// Falhas de nível de turno (não associadas a uma pausa específica).
  List<ValidationFailure<ShiftField>> failuresFor(ShiftField field) {
    return failures
        .where((f) => f.field == field && f.index == null)
        .toList();
  }

  /// Falhas associadas à pausa de índice [pauseIndex] (posição na lista
  /// [pauses] no momento em que a validação foi executada).
  List<ValidationFailure<ShiftField>> failuresForPause(int pauseIndex) {
    return failures.where((f) => f.index == pauseIndex).toList();
  }

  bool get hasFailures => failures.isNotEmpty;
}
