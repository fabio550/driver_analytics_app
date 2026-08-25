// state/entry_state.dart

import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';

class ShiftState {
  final LoadStatus status;
  final List<ShiftEntity> shifts;
  final Object? error;
  final List<ValidationFailure<ShiftField>> validationFailures;

  const ShiftState({
    this.status = LoadStatus.initial,
    this.shifts = const [],
    this.error,
    this.validationFailures = const [],
  });

  ShiftState copyWith({
    LoadStatus? status,
    List<ShiftEntity>? shifts,
    Object? error,
    List<ValidationFailure<ShiftField>>? validationFailures,
    bool clearError = false,
    bool clearValidationFailures = false,
  }) {
    return ShiftState(
      status: status ?? this.status,
      shifts: shifts ?? this.shifts,
      error: clearError ? null : error ?? this.error,
      validationFailures: clearValidationFailures
          ? const []
          : validationFailures ?? this.validationFailures,
    );
  }
}
