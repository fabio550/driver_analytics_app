import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_match.dart';

/// Uma corrida extraída de um texto importado, já resolvida (geo + dedup),
/// mas ainda não persistida — o usuário confirma antes de salvar.
class RideImportCandidate {
  final RideApp app;

  /// Texto bruto do tipo de serviço como veio do parser (ex: "Uber Moto").
  /// Útil pra exibir quando [serviceType] é null (tipo não reconhecido).
  final String serviceTypeRaw;

  /// Null quando o texto não bate com nenhum valor de [RideServiceType]
  /// conhecido — a corrida não é importável até o enum ser atualizado.
  final RideServiceType? serviceType;

  final RideStatus status;
  final DateTime occurredAt;
  final double fareBrl;
  final double surgeBrl;
  final double tipBrl;
  final int durationSeconds;
  final double distanceKm;
  final String? pickupCep;
  final String? destinationCep;
  final GeoMatch? pickupGeo;
  final GeoMatch? destinationGeo;
  final String dedupHash;
  final bool isDuplicate;
  final String rawOcrText;

  const RideImportCandidate({
    required this.app,
    required this.serviceTypeRaw,
    required this.serviceType,
    required this.status,
    required this.occurredAt,
    required this.fareBrl,
    required this.surgeBrl,
    required this.tipBrl,
    required this.durationSeconds,
    required this.distanceKm,
    required this.pickupCep,
    required this.destinationCep,
    required this.pickupGeo,
    required this.destinationGeo,
    required this.dedupHash,
    required this.isDuplicate,
    required this.rawOcrText,
  });

  bool get isRecognized => serviceType != null;

  /// Pronta pra ser persistida: reconhecida e ainda não vista antes.
  bool get isImportable => isRecognized && !isDuplicate;
}
