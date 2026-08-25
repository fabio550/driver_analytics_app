import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

class ShiftValidator {
  const ShiftValidator();

  List<ValidationFailure<ShiftField>> validate(ShiftEntity shift) {
    final failures = <ValidationFailure<ShiftField>>[];

    _validateInitialKm(shift, failures);
    _validateFinalKm(shift, failures);
    _validateTimeRange(shift, failures);
    _validatePauses(shift, failures);
    _validateSubmittedCompleteness(shift, failures);
    
    return failures;
  }

  void _validateInitialKm(
    ShiftEntity shift,
    List<ValidationFailure<ShiftField>> failures,
  ) {
    if (shift.initialKm < 1.0) {
      failures.add(
        const ValidationFailure(
          field: ShiftField.initialKm,
          message: 'initial Km is required.',
        ),
      );
      return;
    }
  }

  void _validateSubmittedCompleteness(
    ShiftEntity shift,
    List<ValidationFailure<ShiftField>> failures,
  ) {
    if (shift.status != ShiftStatus.submitted) return;

    if (shift.endTime == null) {
      failures.add(const ValidationFailure(
        field: ShiftField.endTime,
        message: 'Horário de fim é obrigatório.',
      ));
    }
    if (shift.finalKm == null) {
      failures.add(const ValidationFailure(
        field: ShiftField.finalKm,
        message: 'Km final é obrigatório.',
      ));
    }
    if (shift.earnings == null) {
      failures.add(const ValidationFailure(
        field: ShiftField.earnings,
        message: 'Ganhos é obrigatório.',
      ));
    }
  }

  void _validateFinalKm(
    ShiftEntity shift,
    List<ValidationFailure<ShiftField>> failures,
  ) {
    final finalKm = shift.finalKm;
    if (finalKm != null && finalKm <= shift.initialKm) {
      failures.add(const ValidationFailure(
        field: ShiftField.finalKm,
        message: 'Final Km must be greater than initial Km.',
      ));
    }
  }

  void _validateTimeRange(
    ShiftEntity shift,
    List<ValidationFailure<ShiftField>> failures,
  ) {
    final endTime = shift.endTime;
    if (endTime != null && !endTime.isAfter(shift.startTime)) {
      failures.add(const ValidationFailure(
        field: ShiftField.endTime,
        message: 'End time must be after start time.',
      ));
    }
  }

  void _validatePauses(
    ShiftEntity shift,
    List<ValidationFailure<ShiftField>> failures,
  ) {
    final shiftEnd = shift.endTime;

    for (var i = 0; i < shift.pauses.length; i++) {
      final pause = shift.pauses[i];
      final pauseEnd = pause.endTime;

      if (pauseEnd != null && !pauseEnd.isAfter(pause.startTime)) {
        failures.add(ValidationFailure(
          field: ShiftField.pauseEndTime,
          message: 'Pause end time must be after start time.',
          index: i,
        ));
      }

      if (pause.startTime.isBefore(shift.startTime) ||
          (pauseEnd != null && shiftEnd != null && pauseEnd.isAfter(shiftEnd))) {
        failures.add(ValidationFailure(
          field: ShiftField.pauseStartTime,
          message: 'Pause must be within shift time range.',
          index: i,
        ));
      }
    }
    _validatePauseOverlaps(shift, failures);
  }

  void _validatePauseOverlaps(
    ShiftEntity shift,
    List<ValidationFailure<ShiftField>> failures,
  ) {
    final sorted = [...shift.pauses]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (var i = 0; i < sorted.length - 1; i++) {
      final currentEnd = sorted[i].endTime;
      if (currentEnd != null && currentEnd.isAfter(sorted[i + 1].startTime)) {
        failures.add(ValidationFailure(
          field: ShiftField.pauseOverlap,
          message: 'Pauses #${i + 1} and #${i + 2} overlap.',
          index: i,
        ));
      }
    }
  }
}
