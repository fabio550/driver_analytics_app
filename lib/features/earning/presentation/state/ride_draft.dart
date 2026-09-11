import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';

/// Uma corrida ainda não persistida, enquanto o motorista detalha o
/// turno no diálogo de finalizar. Só vira [RideEarningEntity] depois
/// que a jornada é finalizada e tem id — é ele que vincula a corrida.
class RideDraft {
  final RideServiceType serviceType;
  final DateTime occurredAt;
  final double fare;
  final int durationSeconds;
  final double distanceKm;

  const RideDraft({
    required this.serviceType,
    required this.occurredAt,
    required this.fare,
    required this.durationSeconds,
    required this.distanceKm,
  });

  /// Dinâmico e gorjeta ficam de fora do lançamento rápido: entram na
  /// tela completa de corrida, que é onde se corrige depois.
  double get amount => fare;

  Duration get duration => Duration(seconds: durationSeconds);
}
