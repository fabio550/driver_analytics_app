import 'package:driver_analytics_app/features/earning/application/use_cases/ride_import_candidate.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/dedup/ride_hash.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_parser.dart';

/// Parser -> geo lookup -> dedup, sem persistir nada — o resultado é uma
/// lista de candidatos pra o usuário revisar e confirmar antes de salvar.
class PreviewRideImportUseCase {
  final RideParser _parser;
  final GeoLookupService _geoLookupService;
  final EarningRepository _repository;

  const PreviewRideImportUseCase({
    required RideParser parser,
    required GeoLookupService geoLookupService,
    required EarningRepository repository,
  })  : _parser = parser,
        _geoLookupService = geoLookupService,
        _repository = repository;

  Future<List<RideImportCandidate>> execute(String rawText) async {
    final parsedRides = _parser.parse(rawText);
    final candidates = <RideImportCandidate>[];

    for (final ride in parsedRides) {
      final pickupGeo = ride.pickupPostalCode != null
          ? _geoLookupService.resolvePostalCode(ride.pickupPostalCode!)
          : null;
      final destinationGeo = ride.destinationPostalCode != null
          ? _geoLookupService.resolvePostalCode(ride.destinationPostalCode!)
          : null;

      final dedupHash = RideHash.compute(
        app: RideApp.uber.name,
        rideTimestamp: ride.startedAt,
        fareBrl: ride.fareBrl,
        pickupPostalCode: ride.pickupPostalCode,
        destinationPostalCode: ride.destinationPostalCode,
      );

      final isDuplicate = await _repository.existsRideWithDedupHash(dedupHash);

      candidates.add(RideImportCandidate(
        app: RideApp.uber,
        serviceTypeRaw: ride.serviceType,
        serviceType: _mapServiceType(ride.serviceType),
        status: _mapStatus(ride.status),
        occurredAt: ride.startedAt,
        fareBrl: ride.fareBrl,
        surgeBrl: ride.surgeBrl ?? 0,
        tipBrl: ride.tipBrl ?? 0,
        durationSeconds: ride.durationSeconds ?? 0,
        distanceKm: ride.distanceKm ?? 0,
        pickupCep: ride.pickupPostalCode,
        destinationCep: ride.destinationPostalCode,
        pickupGeo: pickupGeo,
        destinationGeo: destinationGeo,
        dedupHash: dedupHash,
        isDuplicate: isDuplicate,
        rawOcrText: ride.rawOcrText,
      ));
    }

    return candidates;
  }

  RideServiceType? _mapServiceType(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'uber x':
      case 'uberx':
        return RideServiceType.uberX;
      case 'comfort':
        return RideServiceType.comfort;
      case 'uber black':
      case 'black':
        return RideServiceType.black;
      case 'uber moto':
      case 'moto':
        return RideServiceType.moto;
      case 'uber flash':
      case 'flash':
        return RideServiceType.flash;
      case 'uber pet':
      case 'pet':
        return RideServiceType.pet;
      case 'prioridade':
        return RideServiceType.priority;
      default:
        return null;
    }
  }

  RideStatus _mapStatus(String raw) {
    return raw == 'completed' ? RideStatus.completed : RideStatus.cancelled;
  }
}
