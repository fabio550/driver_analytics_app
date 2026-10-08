part of 'earning_entity.dart';

class RideEarningEntity extends EarningEntity {
  final RideApp app;
  final RideServiceType serviceType;
  final double fare;
  final double surge;
  final double tip;
  final int durationSeconds;
  final double distanceKm;
  final RideStatus status;
  final String? pickupCep;
  final String? destinationCep;
  final String? pickupDistrictId;
  final String? destinationDistrictId;
  final String? dedupHash;

  const RideEarningEntity({
    required super.id,
    super.shiftId,
    required super.occurredAt,
    super.description,
    required this.app,
    required this.serviceType,
    required this.fare,
    this.surge = 0,
    this.tip = 0,
    required this.durationSeconds,
    required this.distanceKm,
    required this.status,
    this.pickupCep,
    this.destinationCep,
    this.pickupDistrictId,
    this.destinationDistrictId,
    this.dedupHash,
  });

  @override
  EarningKind get kind => EarningKind.ride;

  /// Fare + dinâmico + gorjeta — nunca guardado, sempre somado.
  @override
  double get amount => fare + surge + tip;

  Duration get duration => Duration(seconds: durationSeconds);

  /// Só pra associar a jornada depois de criada — ex.: corridas
  /// importadas sem jornada (print/vídeo abertos fora do fluxo de
  /// finalizar jornada) ganham uma jornada nova logo em seguida.
  RideEarningEntity copyWith({String? shiftId}) {
    return RideEarningEntity(
      id: id,
      shiftId: shiftId ?? this.shiftId,
      occurredAt: occurredAt,
      description: description,
      app: app,
      serviceType: serviceType,
      fare: fare,
      surge: surge,
      tip: tip,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      status: status,
      pickupCep: pickupCep,
      destinationCep: destinationCep,
      pickupDistrictId: pickupDistrictId,
      destinationDistrictId: destinationDistrictId,
      dedupHash: dedupHash,
    );
  }
}