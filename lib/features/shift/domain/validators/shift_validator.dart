import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';

class ShiftValidator {
  const ShiftValidator();

  List<ValidationFailure<ShiftField>> validate(ShiftEntity shift) {
    final failures = <ValidationFailure<ShiftField>>[];
    _validateInitialKm(shift, failures);
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
}