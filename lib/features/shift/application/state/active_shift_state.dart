import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';

class ActiveShiftState {
  final ShiftEntity? shift;
  final bool isSubmitting;
  final Object? error;
  final List<ValidationFailure<ShiftField>> validationFailures;

  const ActiveShiftState({
    this.shift,
    this.isSubmitting = false,
    this.error,
    this.validationFailures = const [],
  });

  bool get hasActiveShift => shift != null;

  ActiveShiftState copyWith({
    ShiftEntity? shift,
    bool? isSubmitting,
    Object? error,
    List<ValidationFailure<ShiftField>>? validationFailures,
    bool clearError = false,
    bool clearValidationFailures = false,
  }) {
    return ActiveShiftState(
      shift: shift ?? this.shift,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      validationFailures: clearValidationFailures
          ? const []
          : validationFailures ?? this.validationFailures,
    );
  }
}
