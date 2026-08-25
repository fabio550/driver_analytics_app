import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';

class CostState {
  final LoadStatus status;
  final List<CostEntity> costs;
  final Object? error;
  final List<ValidationFailure<CostField>> validationFailures;

  const CostState({
    this.status = LoadStatus.initial,
    this.costs = const [],
    this.error,
    this.validationFailures = const [],
  });

  CostState copyWith({
    LoadStatus? status,
    List<CostEntity>? costs,
    Object? error,
    List<ValidationFailure<CostField>>? validationFailures,
    bool clearError = false,
    bool clearValidationFailures = false,
  }) {
    return CostState(
      status: status ?? this.status,
      costs: costs ?? this.costs,
      error: clearError ? null : error ?? this.error,
      validationFailures: clearValidationFailures
          ? const []
          : validationFailures ?? this.validationFailures,
    );
  }
}
