import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_ride_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/domain/validators/earning_validator.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/dedup/ride_hash.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEarningRepository implements EarningRepository {
  final Set<String> seenHashes;
  final List<EarningEntity> created = [];

  _FakeEarningRepository([Set<String>? seenHashes]) : seenHashes = seenHashes ?? {};

  @override
  Future<bool> existsRideWithDedupHash(String dedupHash) async =>
      seenHashes.contains(dedupHash);

  @override
  Future<void> create(EarningEntity earning) async => created.add(earning);

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<List<EarningEntity>> getAll() => throw UnimplementedError();

  @override
  Future<EarningEntity?> getById(String id) => throw UnimplementedError();

  @override
  Future<void> update(EarningEntity earning) => throw UnimplementedError();
}

class _FakeIdGenerator implements IdGenerator {
  @override
  String generate() => 'fake-id';
}

void main() {
  group('CreateRideEarningUseCase', () {
    final occurredAt = DateTime(2026, 9, 20, 7, 13);

    test('cria a corrida quando não existe nenhuma igual antes', () async {
      final repository = _FakeEarningRepository();
      final useCase = CreateRideEarningUseCase(
        repository: repository,
        validator: const EarningValidator(),
        idGenerator: _FakeIdGenerator(),
      );

      final result = await useCase.execute(
        occurredAt: occurredAt,
        app: RideApp.uber,
        serviceType: RideServiceType.uberX,
        fare: 18.35,
        durationSeconds: 600,
        distanceKm: 5,
        status: RideStatus.completed,
        pickupCep: '04719-002',
        destinationCep: '04794-000',
      );

      expect(result, isA<Success<EarningEntity, dynamic>>());
      expect(repository.created, hasLength(1));
    });

    test('recusa uma corrida manual com os mesmos dados de uma já '
        'existente (mesmo sem dedupHash calculado por quem chamou)', () async {
      final existingHash = RideHash.compute(
        app: RideApp.uber.name,
        rideTimestamp: occurredAt,
        fareBrl: 18.35,
        pickupPostalCode: '04719-002',
        destinationPostalCode: '04794-000',
      );
      final repository = _FakeEarningRepository({existingHash});
      final useCase = CreateRideEarningUseCase(
        repository: repository,
        validator: const EarningValidator(),
        idGenerator: _FakeIdGenerator(),
      );

      final result = await useCase.execute(
        occurredAt: occurredAt,
        app: RideApp.uber,
        serviceType: RideServiceType.uberX,
        fare: 18.35,
        durationSeconds: 600,
        distanceKm: 5,
        status: RideStatus.completed,
        pickupCep: '04719-002',
        destinationCep: '04794-000',
      );

      switch (result) {
        case Success():
          fail('esperava Failure (duplicata), mas a corrida foi criada');
        case Failure(:final error):
          expect(error, hasLength(1));
          expect(error.first.field, EarningField.occurredAt);
      }
      expect(repository.created, isEmpty);
    });

    test('uma corrida com horário, valor ou trajeto diferente não é '
        'bloqueada', () async {
      final existingHash = RideHash.compute(
        app: RideApp.uber.name,
        rideTimestamp: occurredAt,
        fareBrl: 18.35,
        pickupPostalCode: '04719-002',
        destinationPostalCode: '04794-000',
      );
      final repository = _FakeEarningRepository({existingHash});
      final useCase = CreateRideEarningUseCase(
        repository: repository,
        validator: const EarningValidator(),
        idGenerator: _FakeIdGenerator(),
      );

      final result = await useCase.execute(
        occurredAt: occurredAt.add(const Duration(minutes: 5)),
        app: RideApp.uber,
        serviceType: RideServiceType.uberX,
        fare: 18.35,
        durationSeconds: 600,
        distanceKm: 5,
        status: RideStatus.completed,
        pickupCep: '04719-002',
        destinationCep: '04794-000',
      );

      expect(result, isA<Success<EarningEntity, dynamic>>());
      expect(repository.created, hasLength(1));
    });

    test('quando quem chama já manda um dedupHash (fluxo de importação), '
        'usa esse em vez de recalcular', () async {
      const importedHash = 'hash-ja-calculado-na-preview';
      final repository = _FakeEarningRepository({importedHash});
      final useCase = CreateRideEarningUseCase(
        repository: repository,
        validator: const EarningValidator(),
        idGenerator: _FakeIdGenerator(),
      );

      final result = await useCase.execute(
        occurredAt: occurredAt,
        app: RideApp.uber,
        serviceType: RideServiceType.uberX,
        fare: 18.35,
        durationSeconds: 600,
        distanceKm: 5,
        status: RideStatus.completed,
        dedupHash: importedHash,
      );

      switch (result) {
        case Success():
          fail('esperava Failure (duplicata), mas a corrida foi criada');
        case Failure():
          break;
      }
      expect(repository.created, isEmpty);
    });
  });
}
