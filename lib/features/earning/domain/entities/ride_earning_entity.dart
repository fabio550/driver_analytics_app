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
  });

  @override
  EarningKind get kind => EarningKind.ride;

  /// Fare + dinâmico + gorjeta — nunca guardado, sempre somado.
  @override
  double get amount => fare + surge + tip;

  Duration get duration => Duration(seconds: durationSeconds);
}