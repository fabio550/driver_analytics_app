// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/features/earning/application/use_cases/ride_batch_deduper.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/ride_import_candidate.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/dedup/ride_hash.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_parser.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_service_type_matcher.dart';

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

    // Um vídeo de scroll gera vários frames sobrepostos — a mesma
    // corrida pode ser parseada mais de uma vez, a partir de frames
    // diferentes, com pequenas divergências de leitura entre eles. O
    // deduper agrupa essas leituras e decide um valor único por campo
    // antes de virar candidato — a checagem contra o banco (abaixo) só
    // pega duplicata de uma importação anterior, não dentro do mesmo
    // lote.
    final reconciledRides = const RideBatchDeduper().reconcile(parsedRides);
    final candidates = <RideImportCandidate>[];

    for (final reconciled in reconciledRides) {
      final ride = reconciled.ride;

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
        serviceType: RideServiceTypeMatcher.match(ride.serviceType),
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
        hasDivergentReadings: reconciled.hasDivergentReadings,
      ));
    }

    return candidates;
  }

  RideStatus _mapStatus(String raw) {
    return raw == 'completed' ? RideStatus.completed : RideStatus.cancelled;
  }
}
