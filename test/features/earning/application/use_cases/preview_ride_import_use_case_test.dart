import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/preview_ride_import_use_case.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/dedup/ride_hash.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/uber_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

class FakeEarningRepository implements EarningRepository {
  final Set<String> seenHashes;

  FakeEarningRepository([Set<String>? seenHashes])
      : seenHashes = seenHashes ?? {};

  @override
  Future<bool> existsRideWithDedupHash(String dedupHash) async {
    return seenHashes.contains(dedupHash);
  }

  @override
  Future<void> create(EarningEntity earning) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<List<EarningEntity>> getAll() => throw UnimplementedError();

  @override
  Future<EarningEntity?> getById(String id) => throw UnimplementedError();

  @override
  Future<void> update(EarningEntity earning) => throw UnimplementedError();
}

const _rawText = '''
SEX., 05 de JUN.

R\$ 18,92

Uber X • 14 min 32 seg • 5,87 km

18:43

R\$ 2,25 Preço dinâmico

Rua Serra de Botucatu, Tatuape - Sao Paulo - SP, 03317-000, BR

Rua Itapura, Tatuape - Sao Paulo - SP, 03310-000, BR



R\$ 0,00

Uber X - Cancelado pelo usuário

19:02

Rua Monte Serrat, Tatuape - Sao Paulo - SP, 03312-001, BR

Rua Cantagalo, Tatuape - Sao Paulo - SP, 03319-000, BR



R\$ 12,47

Comfort * 9 min 48 segs * 3 km

20:11

R\$ 3,00 Valor extra (valor a mais deixado pelo usuario)

Rua Antonio de Barros, Tatuape - Sao Paulo - SP, 03401-000, BR

Avenida Radial Leste, Vila Matilde - Sao Paulo - SP, 03502-000, BR


sáb., 6 de jun.

R\$ 34,90

Uber Flash · 22 min 15 segundos · 11.4 km

08:17

Rua da Consolação, Consolacao - Sao Paulo - SP, 01302-000, BR

Avenida Brigadeiro Faria Lima, Itaim Bibi - Sao Paulo - SP, 04538-132, BR


R\$ 27,35

Uber Moto • 18 min 09 seg • 8,6 km

13:54

R\$ 1,50 Preço dinâmico

R\$ 4,00 Valor extra

Rua Vergueiro, Liberdade - Sao Paulo - SP, 01504-001, BR

Praça da Se, Se - Sao Paulo - SP, 01001-000, BR


R\$ 0,00

Uber Pet · Você cancelou

23:41

Rua Domingos de Morais, Vila Mariana - Sao Paulo - SP, 04010-100, BR

Rua Domingos de Morais, Vila Mariana - Sao Paulo - SP, 04010-100, BR


R\$ 42,90

Uber Black - 21 min 44 seg - 11,2 km

23:58

R\$ 6,50 Preço dinâmico

R\$ 10,00 Valor extra (valor a mais deixado pelo usuário)

Rua Funchal, Vila Olimpia - Sao Paulo - SP, 04551-060, BR

Avenida Paulista, Bela Vista - Sao Paulo - SP, 01310-100, BR
''';

void main() {
  group('PreviewRideImportUseCase', () {
    late Database geoDb;
    late GeoLookupService geoLookupService;

    setUpAll(() {
      geoDb = sqlite3.open('assets/geo/geo.db', mode: OpenMode.readOnly);
      geoLookupService = SqliteGeoLookupService(geoDb);
    });

    tearDownAll(() {
      geoDb.close();
    });

    test('todas as 7 corridas do texto de exemplo são reconhecidas e '
        'resolvidas geograficamente, sem duplicatas num repo vazio', () async {
      final useCase = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository(),
      );

      final candidates = await useCase.execute(_rawText);

      expect(candidates, hasLength(7));
      expect(candidates.every((c) => c.isRecognized), isTrue);
      expect(candidates.every((c) => !c.isDuplicate), isTrue);
      expect(candidates.every((c) => c.isImportable), isTrue);

      final ride1 = candidates[0];
      expect(ride1.serviceType, RideServiceType.uberX);
      expect(ride1.status, RideStatus.completed);
      expect(ride1.pickupGeo?.districtName, 'Tatuape');
      expect(ride1.destinationGeo?.districtName, 'Tatuape');

      final ride5 = candidates[4];
      expect(ride5.serviceType, RideServiceType.moto);
      expect(ride5.pickupGeo?.districtName, 'Liberdade');
      expect(ride5.destinationGeo?.districtName, 'Se');

      final ride6 = candidates[5];
      expect(ride6.serviceType, RideServiceType.pet);
      expect(ride6.status, RideStatus.cancelled);
    });

    test('corrida já vista antes (hash no repositório) marca isDuplicate',
        () async {
      final probe = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository(),
      );
      final firstPass = await probe.execute(_rawText);
      final ride1Hash = firstPass[0].dedupHash;

      final useCase = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository({ride1Hash}),
      );
      final candidates = await useCase.execute(_rawText);

      expect(candidates[0].isDuplicate, isTrue);
      expect(candidates[0].isImportable, isFalse);
      expect(candidates[1].isDuplicate, isFalse);
    });

    test('tipo de serviço desconhecido não é importável, mas aparece na '
        'lista pra revisão', () async {
      const rawTextTipoDesconhecido = '''
SEX., 05 de JUN.

R\$ 50,00

UberXL • 20 min 00 seg • 10 km

10:00

Rua Serra de Botucatu, Tatuape - Sao Paulo - SP, 03317-000, BR
''';
      final useCase = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository(),
      );

      final candidates = await useCase.execute(rawTextTipoDesconhecido);

      expect(candidates, hasLength(1));
      expect(candidates[0].isRecognized, isFalse);
      expect(candidates[0].serviceType, isNull);
      expect(candidates[0].serviceTypeRaw, 'UberXL');
      expect(candidates[0].isImportable, isFalse);
    });

    test('nome do serviço com ruído de OCR colado na frente ainda é '
        'reconhecido', () async {
      // O OCR às vezes lê um ícone/pino do layout como um caractere
      // solto colado antes do nome real do serviço ("8 uber X", "&
      // uber X", "8 Comfort") — visto em prints reais. Isso não pode
      // ser confundido com uma variante de verdade diferente, como
      // "UberXL" (caso acima), que precisa continuar não reconhecida.
      const rawTextComRuido = '''
SEX., 05 de JUN.

R\$ 26,47

8 uber X- 37 min 42 segundos-13.88 km

16:45

Rua Serra de Botucatu, Tatuape - Sao Paulo - SP, 03317-000, BR
''';
      final useCase = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository(),
      );

      final candidates = await useCase.execute(rawTextComRuido);

      expect(candidates, hasLength(1));
      expect(candidates[0].isRecognized, isTrue);
      expect(candidates[0].serviceType, RideServiceType.uberX);
      expect(candidates[0].isImportable, isTrue);
    });

    test('dedupHash bate com RideHash.compute nos mesmos campos', () async {
      final useCase = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository(),
      );
      final candidates = await useCase.execute(_rawText);
      final ride1 = candidates[0];

      final expectedHash = RideHash.compute(
        app: 'uber',
        rideTimestamp: DateTime(2026, 6, 5, 18, 43),
        fareBrl: 18.92,
        pickupPostalCode: '03317-000',
        destinationPostalCode: '03310-000',
      );

      expect(ride1.dedupHash, expectedHash);
    });

    test('texto sem nenhuma corrida retorna lista vazia', () async {
      final useCase = PreviewRideImportUseCase(
        parser: UberParser(),
        geoLookupService: geoLookupService,
        repository: FakeEarningRepository(),
      );
      final candidates = await useCase.execute('nada aqui');
      expect(candidates, isEmpty);
    });
  });
}
