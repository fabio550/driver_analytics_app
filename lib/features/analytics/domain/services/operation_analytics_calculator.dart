import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

class OperationAnalyticsCalculator {
  const OperationAnalyticsCalculator();

  static const _epsilon = 0.01;

  OperationAnalytics calculate({
    required List<ShiftEntity> shifts,
    required List<EarningEntity> earnings,
    required AnalyticsPeriod period,
    required DateTime now,
  }) {
    final periodShifts = shifts
        .where((s) => s.status == ShiftStatus.submitted)
        .where((s) => period.contains(s.startTime))
        .toList();

    if (periodShifts.isEmpty) return OperationAnalytics.empty;

    final earningsByShift = <String, List<EarningEntity>>{};
    for (final earning in earnings) {
      final shiftId = earning.shiftId;
      if (shiftId == null) continue;
      earningsByShift.putIfAbsent(shiftId, () => []).add(earning);
    }

    var totalTime = Duration.zero;
    var activeTime = Duration.zero;
    var pausedTime = Duration.zero;
    var totalDistanceKm = 0.0;
    var completeShifts = 0;
    var missingAmount = 0.0;
    var hasMissing = false;

    for (final shift in periodShifts) {
      totalTime += shift.elapsedTime(now);
      activeTime += shift.workedTime(now);
      pausedTime += shift.totalPausedTime(now);
      totalDistanceKm += shift.distanceKm;

      final shiftEarnings = earningsByShift[shift.id] ?? const [];
      if (shiftEarnings.isEmpty) {
        completeShifts++;
        continue;
      }

      final declared = shift.earnings;
      final actual = shiftEarnings.fold<double>(0, (t, e) => t + e.amount);
      if (declared == null || (actual - declared).abs() < _epsilon) {
        completeShifts++;
      } else {
        hasMissing = true;
        missingAmount += (declared - actual).abs();
      }
    }

    final completeness = ShiftCompleteness(
      totalShifts: periodShifts.length,
      completeShifts: completeShifts,
      missingAmount: hasMissing ? missingAmount : null,
    );

    if (!completeness.isFullyComplete) {
      return OperationAnalytics(
        totalTime: totalTime,
        activeTime: activeTime,
        pausedTime: pausedTime,
        totalDistanceKm: totalDistanceKm,
        completeness: completeness,
      );
    }

    // Corridas do período: as ligadas às jornadas confirmadas + as soltas
    // que caem na janela — mesmo critério de "receita" da SummaryAnalytics.
    final shiftIds = periodShifts.map((s) => s.id).toSet();
    final rides = earnings.whereType<RideEarningEntity>().where((ride) {
      final inShift = ride.shiftId != null && shiftIds.contains(ride.shiftId);
      return inShift || period.contains(ride.occurredAt);
    }).toList();

    final completedRides = rides.where((r) => r.status == RideStatus.completed).toList();
    final cancelledCount = rides.length - completedRides.length;

    var passengerTime = Duration.zero;
    var passengerKm = 0.0;
    for (final ride in completedRides) {
      passengerTime += ride.duration;
      passengerKm += ride.distanceKm;
    }
    // Clampa: corrida solta sem shift pode inflar a soma além do tempo
    // ativo medido pela jornada (relógio de corrida != relógio de turno).
    if (passengerTime > activeTime) passengerTime = activeTime;
    if (passengerKm > totalDistanceKm) passengerKm = totalDistanceKm;

    final timeSplit = TimeSplit(
      withPassenger: passengerTime,
      available: activeTime - passengerTime,
      paused: pausedTime,
    );
    final distanceSplit = DistanceSplit(
      withPassengerKm: passengerKm,
      idleKm: totalDistanceKm - passengerKm,
    );

    final activeHours = activeTime.inMinutes / 60;
    final pace = PaceStats(
      rideCount: rides.length,
      completedRideCount: completedRides.length,
      cancelledRideCount: cancelledCount,
      ridesPerActiveHour: activeHours > 0 ? completedRides.length / activeHours : null,
      cancellationRate: rides.isNotEmpty ? cancelledCount / rides.length : null,
      averageRideDuration: completedRides.isNotEmpty
          ? Duration(seconds: passengerTime.inSeconds ~/ completedRides.length)
          : null,
      averageRideDistanceKm:
          completedRides.isNotEmpty ? passengerKm / completedRides.length : null,
    );

    final hourlyEarnings = _hourlyEarnings(completedRides);
    final districts = _districtRanking(completedRides);

    return OperationAnalytics(
      totalTime: totalTime,
      activeTime: activeTime,
      pausedTime: pausedTime,
      totalDistanceKm: totalDistanceKm,
      completeness: completeness,
      timeSplit: timeSplit,
      distanceSplit: distanceSplit,
      pace: pace,
      hourlyEarnings: hourlyEarnings,
      districts: districts,
    );
  }

  List<HourlyEarningEntry> _hourlyEarnings(List<RideEarningEntity> completedRides) {
    final revenueByBucket = <int, double>{};
    final minutesByBucket = <int, int>{};

    for (final ride in completedRides) {
      final bucket = (ride.occurredAt.hour ~/ 3) * 3;
      revenueByBucket[bucket] = (revenueByBucket[bucket] ?? 0) + ride.amount;
      minutesByBucket[bucket] = (minutesByBucket[bucket] ?? 0) + ride.duration.inMinutes;
    }

    return [
      for (var hour = 0; hour < 24; hour += 3)
        HourlyEarningEntry(
          startHour: hour,
          amountPerHour: (minutesByBucket[hour] ?? 0) > 0
              ? revenueByBucket[hour]! / (minutesByBucket[hour]! / 60)
              : null,
        ),
    ];
  }

  List<DistrictEntry> _districtRanking(List<RideEarningEntity> completedRides) {
    final byDistrict = <String, List<RideEarningEntity>>{};
    for (final ride in completedRides) {
      final districtId = ride.pickupDistrictId;
      if (districtId == null || districtId.isEmpty) continue;
      byDistrict.putIfAbsent(districtId, () => []).add(ride);
    }

    return [
      for (final entry in byDistrict.entries)
        DistrictEntry(
          districtId: entry.key,
          revenue: entry.value.fold<double>(0, (t, r) => t + r.amount),
          distanceKm: entry.value.fold<double>(0, (t, r) => t + r.distanceKm),
          duration: entry.value.fold<Duration>(Duration.zero, (t, r) => t + r.duration),
          rideCount: entry.value.length,
        ),
    ]..sort((a, b) => b.revenue.compareTo(a.revenue));
  }
}
