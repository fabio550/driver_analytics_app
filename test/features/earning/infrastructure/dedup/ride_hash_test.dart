import 'package:driver_analytics_app/features/earning/infrastructure/dedup/ride_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RideHash', () {
    final timestamp = DateTime.utc(2026, 6, 5, 18, 43);

    test('mesmos campos geram o mesmo hash (idempotente)', () {
      final a = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
        pickupPostalCode: '03317-000',
        destinationPostalCode: '03310-000',
      );
      final b = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
        pickupPostalCode: '03317-000',
        destinationPostalCode: '03310-000',
      );
      expect(a, b);
      expect(a, hasLength(64)); // sha256 hex
    });

    test('fare diferente muda o hash', () {
      final a = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
      );
      final b = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.93,
      );
      expect(a, isNot(b));
    });

    test('CEP de origem ou destino diferente muda o hash', () {
      final base = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
        pickupPostalCode: '03317-000',
        destinationPostalCode: '03310-000',
      );
      final pickupDiferente = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
        pickupPostalCode: '01310-100',
        destinationPostalCode: '03310-000',
      );
      final destinoDiferente = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
        pickupPostalCode: '03317-000',
        destinationPostalCode: '01310-100',
      );
      expect(base, isNot(pickupDiferente));
      expect(base, isNot(destinoDiferente));
    });

    test('timestamp diferente muda o hash (mesmo 1 minuto)', () {
      final a = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
      );
      final b = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp.add(const Duration(minutes: 1)),
        fareBrl: 18.92,
      );
      expect(a, isNot(b));
    });

    test('app diferente muda o hash', () {
      final a = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
      );
      final b = RideHash.compute(
        app: '99',
        rideTimestamp: timestamp,
        fareBrl: 18.92,
      );
      expect(a, isNot(b));
    });

    test('CEPs nulos não colidem com CEPs vazios equivalentes a outra corrida',
        () {
      final semCep = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 0.0,
      );
      final cancelada1 = RideHash.compute(
        app: 'uber',
        rideTimestamp: timestamp,
        fareBrl: 0.0,
        pickupPostalCode: '03312-001',
        destinationPostalCode: '03319-000',
      );
      expect(semCep, isNot(cancelada1));
    });
  });
}
