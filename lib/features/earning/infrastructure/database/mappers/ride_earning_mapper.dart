import 'package:drift/drift.dart';
import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';

class RideEarningMapper {
  const RideEarningMapper();

  RideEarningEntity fromRows(Earning earningRow, RideEarning rideRow) {
    return RideEarningEntity(
      id: earningRow.id,
      shiftId: earningRow.shiftId,
      occurredAt: earningRow.occurredAt,
      description: earningRow.description,
      app: RideApp.values.byName(rideRow.app),
      serviceType: RideServiceType.values.byName(rideRow.serviceType),
      fare: rideRow.fare,
      surge: rideRow.surge,
      tip: rideRow.tip,
      durationSeconds: rideRow.durationSeconds,
      distanceKm: rideRow.distanceKm,
      status: RideStatus.values.byName(rideRow.status),
      pickupCep: rideRow.pickupCep,
      destinationCep: rideRow.destinationCep,
      pickupDistrictId: rideRow.pickupDistrictId,
      destinationDistrictId: rideRow.destinationDistrictId,
    );
  }

  RideEarningsCompanion toCompanion(RideEarningEntity earning) {
    return RideEarningsCompanion(
      earningId: Value(earning.id),
      app: Value(earning.app.name),
      serviceType: Value(earning.serviceType.name),
      fare: Value(earning.fare),
      surge: Value(earning.surge),
      tip: Value(earning.tip),
      durationSeconds: Value(earning.durationSeconds),
      distanceKm: Value(earning.distanceKm),
      status: Value(earning.status.name),
      pickupCep: Value(earning.pickupCep),
      destinationCep: Value(earning.destinationCep),
      pickupDistrictId: Value(earning.pickupDistrictId),
      destinationDistrictId: Value(earning.destinationDistrictId),
    );
  }
}