// ignore_for_file: prefer_initializing_formals

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

  static final RegExp _reUberX = RegExp(r'\buber ?x\b');
  static final RegExp _reComfort = RegExp(r'\bcomfort\b');
  static final RegExp _reBlack = RegExp(r'\bblack\b');
  static final RegExp _reMoto = RegExp(r'\bmoto\b');
  static final RegExp _reFlash = RegExp(r'\bflash\b');
  static final RegExp _rePet = RegExp(r'\bpet\b');
  static final RegExp _rePrioridade = RegExp(r'\bprioridade\b');

  /// O OCR às vezes cola um caractere de ícone (um pino/bullet do layout
  /// mal reconhecido) direto na frente do nome do serviço — "8 uber X",
  /// "& uber X", "8 Comfort" — em vez do texto limpo. Comparar por
  /// igualdade exata perdia essas corridas inteiras como "não
  /// reconhecidas" por causa de 1 caractere solto. `\b` (borda de
  /// palavra) tolera esse prefixo solto sem abrir mão de precisão: uma
  /// variante real diferente como "UberXL" não bate com `uber ?x\b`,
  /// porque não há borda de palavra entre o "x" e o "l" que vem colado
  /// nele.
  RideServiceType? _mapServiceType(String raw) {
    final normalized = raw.trim().toLowerCase();

    if (_reUberX.hasMatch(normalized)) return RideServiceType.uberX;
    if (_reComfort.hasMatch(normalized)) return RideServiceType.comfort;
    if (_reBlack.hasMatch(normalized)) return RideServiceType.black;
    if (_reMoto.hasMatch(normalized)) return RideServiceType.moto;
    if (_reFlash.hasMatch(normalized)) return RideServiceType.flash;
    if (_rePet.hasMatch(normalized)) return RideServiceType.pet;
    if (_rePrioridade.hasMatch(normalized)) return RideServiceType.priority;
    return null;
  }

  RideStatus _mapStatus(String raw) {
    return raw == 'completed' ? RideStatus.completed : RideStatus.cancelled;
  }
}
