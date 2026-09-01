import 'package:driver_analytics_app/features/analytics/domain/entities/revenue_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

class RevenueAnalyticsCalculator {
  const RevenueAnalyticsCalculator();

  RevenueAnalytics calculate({
    required List<ShiftEntity> shifts,
    required List<EarningEntity> earnings,
    required AnalyticsPeriod period,
  }) {
    final periodShifts = shifts
        .where((s) => s.status == ShiftStatus.submitted)
        .where((s) => period.contains(s.startTime))
        .toList();

    final earningsByShift = <String, List<EarningEntity>>{};
    final knownShiftIds = shifts.map((s) => s.id).toSet();
    final looseEarnings = <EarningEntity>[];

    for (final earning in earnings) {
      final shiftId = earning.shiftId;
      if (shiftId == null || !knownShiftIds.contains(shiftId)) {
        looseEarnings.add(earning);
        continue;
      }
      earningsByShift.putIfAbsent(shiftId, () => []).add(earning);
    }

    var fareTotal = 0.0;
    var surgeTotal = 0.0;
    var tipTotal = 0.0;
    var promotionTotal = 0.0;
    var adjustmentTotal = 0.0;
    var undetailedTotal = 0.0;
    final serviceTypeAmount = <RideServiceType, double>{};
    final serviceTypeCount = <RideServiceType, int>{};
    final rides = <RideEarningEntity>[];

    void addEarning(EarningEntity earning) {
      switch (earning) {
        case RideEarningEntity():
          fareTotal += earning.fare;
          surgeTotal += earning.surge;
          tipTotal += earning.tip;
          serviceTypeAmount[earning.serviceType] =
              (serviceTypeAmount[earning.serviceType] ?? 0) + earning.amount;
          serviceTypeCount[earning.serviceType] =
              (serviceTypeCount[earning.serviceType] ?? 0) + 1;
          rides.add(earning);
        case PromotionEarningEntity():
          promotionTotal += earning.amount;
        case AdjustmentEarningEntity():
          adjustmentTotal += earning.amount;
      }
    }

    for (final shift in periodShifts) {
      final shiftEarnings = earningsByShift[shift.id] ?? const [];
      if (shiftEarnings.isNotEmpty) {
        for (final earning in shiftEarnings) {
          addEarning(earning);
        }
      } else {
        // §7.1: sem lançamento, a receita da jornada é o valor declarado —
        // entra na receita mas não dá pra decompor em fare/surge/gorjeta.
        undetailedTotal += shift.earnings ?? 0;
      }
    }

    for (final earning in looseEarnings) {
      if (!period.contains(earning.occurredAt)) continue;
      addEarning(earning);
    }

    final totalRevenue = fareTotal +
        surgeTotal +
        tipTotal +
        promotionTotal +
        adjustmentTotal +
        undetailedTotal;

    final bySource = [
      RevenueSourceEntry(source: RevenueSource.rides, amount: fareTotal),
      RevenueSourceEntry(source: RevenueSource.surge, amount: surgeTotal),
      RevenueSourceEntry(source: RevenueSource.tip, amount: tipTotal),
      RevenueSourceEntry(source: RevenueSource.promotion, amount: promotionTotal),
      RevenueSourceEntry(source: RevenueSource.adjustment, amount: adjustmentTotal),
      RevenueSourceEntry(source: RevenueSource.undetailed, amount: undetailedTotal),
    ].where((entry) => entry.amount > 0).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final byServiceType = [
      for (final type in serviceTypeAmount.keys)
        ServiceTypeEntry(
          serviceType: type,
          amount: serviceTypeAmount[type]!,
          rideCount: serviceTypeCount[type]!,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    // Remuneradas: concluídas + canceladas com taxa. As canceladas sem
    // taxa não entram — derrubariam a média sem representar receita real.
    final paidRides =
        rides.where((r) => r.status == RideStatus.completed || r.amount > 0).toList();
    final completedRides = rides.where((r) => r.status == RideStatus.completed).length;

    final averageTicket = AverageTicketStats(
      amountPerPaidRide: paidRides.isNotEmpty
          ? paidRides.fold<double>(0, (t, r) => t + r.amount) / paidRides.length
          : null,
      paidRideCount: paidRides.length,
      completedRideCount: completedRides,
    );

    return RevenueAnalytics(
      bySource: bySource,
      byServiceType: byServiceType,
      averageTicket: averageTicket,
      totalRevenue: totalRevenue,
    );
  }
}
