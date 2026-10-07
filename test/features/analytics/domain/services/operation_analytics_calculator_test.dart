import 'package:driver_analytics_app/core/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/domain/services/operation_analytics_calculator.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:flutter_test/flutter_test.dart';

RideEarningEntity _ride({
  required String id,
  required String shiftId,
  required DateTime occurredAt,
  required RideServiceType serviceType,
  required double fare,
  required int durationSeconds,
  required double distanceKm,
}) {
  return RideEarningEntity(
    id: id,
    shiftId: shiftId,
    occurredAt: occurredAt,
    app: RideApp.uber,
    serviceType: serviceType,
    fare: fare,
    durationSeconds: durationSeconds,
    distanceKm: distanceKm,
    status: RideStatus.completed,
  );
}

void main() {
  group('OperationAnalyticsCalculator', () {
    const calculator = OperationAnalyticsCalculator();
    final now = DateTime(2026, 9, 25, 12);
    final period = AnalyticsPeriod.month(DateTime(2026, 9));

    final shift = ShiftEntity(
      id: 'shift-1',
      status: ShiftStatus.submitted,
      initialKm: 0,
      finalKm: 100,
      earnings: 110, // soma das 4 corridas abaixo: 10+20+30+50
      startTime: DateTime(2026, 9, 10, 8),
      endTime: DateTime(2026, 9, 10, 18),
    );

    final rides = [
      // curta: 2 km
      _ride(
        id: 'r1',
        shiftId: 'shift-1',
        occurredAt: DateTime(2026, 9, 10, 9),
        serviceType: RideServiceType.uberX,
        fare: 10,
        durationSeconds: 600,
        distanceKm: 2,
      ),
      // media: 5 km
      _ride(
        id: 'r2',
        shiftId: 'shift-1',
        occurredAt: DateTime(2026, 9, 10, 10),
        serviceType: RideServiceType.comfort,
        fare: 20,
        durationSeconds: 900,
        distanceKm: 5,
      ),
      // longa: 15 km
      _ride(
        id: 'r3',
        shiftId: 'shift-1',
        occurredAt: DateTime(2026, 9, 10, 11),
        serviceType: RideServiceType.uberX,
        fare: 30,
        durationSeconds: 1800,
        distanceKm: 15,
      ),
      // viagem: 25 km
      _ride(
        id: 'r4',
        shiftId: 'shift-1',
        occurredAt: DateTime(2026, 9, 10, 12),
        serviceType: RideServiceType.black,
        fare: 50,
        durationSeconds: 2400,
        distanceKm: 25,
      ),
    ];

    final result = calculator.calculate(
      shifts: [shift],
      earnings: rides,
      period: period,
      now: now,
    );

    test('gera as 4 faixas de distância, na ordem fixa curta -> viagem', () {
      final ranges = result.distanceRanges!;
      expect(ranges.map((r) => r.range), [
        DistanceRange.curta,
        DistanceRange.media,
        DistanceRange.longa,
        DistanceRange.viagem,
      ]);
    });

    test('faixa curta (<=3km) recebe a corrida de 2km', () {
      final curta = result.distanceRanges!.firstWhere((r) => r.range == DistanceRange.curta);
      expect(curta.rideCount, 1);
      expect(curta.revenue, 10);
      expect(curta.distanceKm, 2);
    });

    test('faixa média (3-8km) recebe a corrida de 5km', () {
      final media = result.distanceRanges!.firstWhere((r) => r.range == DistanceRange.media);
      expect(media.rideCount, 1);
      expect(media.revenue, 20);
    });

    test('faixa longa (8-20km) recebe a corrida de 15km', () {
      final longa = result.distanceRanges!.firstWhere((r) => r.range == DistanceRange.longa);
      expect(longa.rideCount, 1);
      expect(longa.revenue, 30);
    });

    test('faixa viagem (>20km) recebe a corrida de 25km', () {
      final viagem = result.distanceRanges!.firstWhere((r) => r.range == DistanceRange.viagem);
      expect(viagem.rideCount, 1);
      expect(viagem.revenue, 50);
    });

    test('revenuePerKm e revenuePerHour calculados corretamente numa faixa', () {
      final curta = result.distanceRanges!.firstWhere((r) => r.range == DistanceRange.curta);
      expect(curta.revenuePerKm, 5.0); // 10 / 2
      expect(curta.revenuePerHour, closeTo(60.0, 0.001)); // 10 / (600s/3600h)
    });

    test('agrupa por tipo de serviço, 2 corridas de Uber X juntas', () {
      final types = result.serviceTypes!;
      final uberX = types.firstWhere((t) => t.serviceType == RideServiceType.uberX);
      expect(uberX.rideCount, 2);
      expect(uberX.revenue, 40); // 10 + 30
    });

    test('tipos de serviço vêm ordenados por receita (maior primeiro)', () {
      // Receita por tipo: black=50 (r4), uberX=40 (r1+r3), comfort=20 (r2).
      final types = result.serviceTypes!;
      expect(types.map((t) => t.serviceType), [
        RideServiceType.black,
        RideServiceType.uberX,
        RideServiceType.comfort,
      ]);
      expect(types.map((t) => t.revenue), [50, 40, 20]);
    });

    test('tipo de serviço só com 1 corrida (black) aparece certo', () {
      final black = result.serviceTypes!.firstWhere((t) => t.serviceType == RideServiceType.black);
      expect(black.rideCount, 1);
      expect(black.revenue, 50);
    });
  });
}
