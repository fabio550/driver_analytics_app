import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';

class EarningState {
  final LoadStatus status;
  final List<EarningEntity> earnings;
  final Object? error;
  final List<ValidationFailure<EarningField>> validationFailures;

  const EarningState({
    this.status = LoadStatus.initial,
    this.earnings = const [],
    this.error,
    this.validationFailures = const [],
  });

  EarningState copyWith({
    LoadStatus? status,
    List<EarningEntity>? earnings,
    Object? error,
    List<ValidationFailure<EarningField>>? validationFailures,
    bool clearError = false,
    bool clearValidationFailures = false,
  }) {
    return EarningState(
      status: status ?? this.status,
      earnings: earnings ?? this.earnings,
      error: clearError ? null : error ?? this.error,
      validationFailures: clearValidationFailures
          ? const []
          : validationFailures ?? this.validationFailures,
    );
  }
}