import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';

class EarningValidator {
  const EarningValidator();

  List<ValidationFailure<EarningField>> validate(EarningEntity earning) {
    final failures = <ValidationFailure<EarningField>>[];

    switch (earning) {
      case RideEarningEntity():
        _validateRide(earning, failures);
      case PromotionEarningEntity():
        _validatePromotion(earning, failures);
      case AdjustmentEarningEntity():
        break; // sem regra própria por enquanto — pode corrigir pra cima ou pra baixo
    }

    return failures;
  }

  void _validateRide(
    RideEarningEntity earning,
    List<ValidationFailure<EarningField>> failures,
  ) {
    if (earning.fare < 0) {
      failures.add(const ValidationFailure(
        field: EarningField.fare,
        message: 'Valor da corrida não pode ser negativo.',
      ));
    }
    if (earning.durationSeconds < 0) {
      failures.add(const ValidationFailure(
        field: EarningField.durationSeconds,
        message: 'Duração não pode ser negativa.',
      ));
    }
    if (earning.distanceKm < 0) {
      failures.add(const ValidationFailure(
        field: EarningField.distanceKm,
        message: 'Distância não pode ser negativa.',
      ));
    }
  }

  void _validatePromotion(
    PromotionEarningEntity earning,
    List<ValidationFailure<EarningField>> failures,
  ) {
    if (earning.amount <= 0) {
      failures.add(const ValidationFailure(
        field: EarningField.amount,
        message: 'Valor da promoção deve ser maior que zero.',
      ));
    }
  }
}