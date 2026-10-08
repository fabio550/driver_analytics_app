import 'package:driver_analytics_app/features/earning/application/use_cases/ride_batch_deduper.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/parsed_ride.dart';
import 'package:flutter_test/flutter_test.dart';

ParsedRide _ride({
  DateTime? startedAt,
  String serviceType = 'Uber X',
  String status = 'completed',
  double fareBrl = 18.92,
  int? durationSeconds = 600,
  double? distanceKm = 5.0,
  String? pickupPostalCode = '03317-000',
  String? destinationPostalCode = '03310-000',
}) {
  return ParsedRide(
    startedAt: startedAt ?? DateTime(2026, 6, 5, 18, 43),
    serviceType: serviceType,
    status: status,
    fareBrl: fareBrl,
    durationSeconds: durationSeconds,
    distanceKm: distanceKm,
    pickupPostalCode: pickupPostalCode,
    destinationPostalCode: destinationPostalCode,
    rawOcrText: 'raw',
  );
}

void main() {
  group('RideBatchDeduper', () {
    const deduper = RideBatchDeduper();

    test('lista vazia retorna lista vazia', () {
      expect(deduper.reconcile([]), isEmpty);
    });

    test('leitura única não diverge', () {
      final result = deduper.reconcile([_ride()]);
      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isFalse);
    });

    test('nível 1: leituras idênticas em tudo viram 1 candidato', () {
      final result = deduper.reconcile([_ride(), _ride()]);
      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isFalse);
    });

    test('nível 2: mesma hora/tarifa/tipo com CEP diferente (um nulo) '
        'ainda agrupa, sem contar como divergência, e usa o CEP não nulo',
        () {
      final result = deduper.reconcile([
        _ride(pickupPostalCode: null, destinationPostalCode: null),
        _ride(pickupPostalCode: '03317-000', destinationPostalCode: '03310-000'),
      ]);

      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isFalse);
      expect(result[0].ride.pickupPostalCode, '03317-000');
      expect(result[0].ride.destinationPostalCode, '03310-000');
    });

    test('tipo de serviço com ruído de OCR diferente ainda agrupa (nível 2)',
        () {
      final result = deduper.reconcile([
        _ride(serviceType: 'Uber X'),
        _ride(serviceType: '8 uber X'),
      ]);

      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isFalse);
    });

    test('nível 3: só 2 leituras discordando na tarifa — fica a primeira, '
        'marcado como divergente', () {
      final result = deduper.reconcile([
        _ride(fareBrl: 18.92, pickupPostalCode: null, destinationPostalCode: null),
        _ride(fareBrl: 78.92, pickupPostalCode: '01000-000', destinationPostalCode: null),
      ]);

      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isTrue);
      expect(result[0].ride.fareBrl, 18.92);
    });

    test('3+ leituras com maioria clara: o valor mais frequente vence, '
        'mas ainda marca divergência (nem todas concordaram)', () {
      final result = deduper.reconcile([
        _ride(fareBrl: 18.92, pickupPostalCode: null, destinationPostalCode: null),
        _ride(fareBrl: 18.92, pickupPostalCode: null, destinationPostalCode: null),
        _ride(fareBrl: 78.92, pickupPostalCode: null, destinationPostalCode: null),
      ]);

      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isTrue);
      expect(result[0].ride.fareBrl, 18.92);
    });

    test('3 leituras empatadas (sem maioria) — fica a primeira, divergente',
        () {
      final result = deduper.reconcile([
        _ride(durationSeconds: 600, pickupPostalCode: null, destinationPostalCode: null),
        _ride(durationSeconds: 650, pickupPostalCode: null, destinationPostalCode: null),
        _ride(durationSeconds: 700, pickupPostalCode: null, destinationPostalCode: null),
      ]);

      expect(result, hasLength(1));
      expect(result[0].hasDivergentReadings, isTrue);
      expect(result[0].ride.durationSeconds, 600);
    });

    test('horários diferentes nunca agrupam, mesmo com tudo mais igual', () {
      final result = deduper.reconcile([
        _ride(startedAt: DateTime(2026, 6, 5, 18, 43)),
        _ride(startedAt: DateTime(2026, 6, 5, 19, 2)),
      ]);

      expect(result, hasLength(2));
      expect(result.every((r) => !r.hasDivergentReadings), isTrue);
    });

    test('mesma hora mas tipos de serviço genuinamente diferentes não '
        'agrupam', () {
      final result = deduper.reconcile([
        _ride(serviceType: 'Uber X', fareBrl: 18.92),
        _ride(serviceType: 'Comfort', fareBrl: 25.00),
      ]);

      expect(result, hasLength(2));
    });
  });
}
