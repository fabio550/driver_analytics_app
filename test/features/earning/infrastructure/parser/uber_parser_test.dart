import 'package:driver_analytics_app/features/earning/infrastructure/parser/uber_parser.dart';
import 'package:flutter_test/flutter_test.dart';

// Mesmo texto de exemplo de tests/test_uber_parser.py (backend Python,
// branch develop) — simula o que o ML Kit entregaria a partir de um
// screenshot da tela de corridas do Uber.
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

// Data fixa para que o teste não dependa da data real de execução — o
// texto de exemplo é sempre "passado" em relação a ela, então o ano
// inferido é sempre 2026 (ver UberParser._inferYear).
final _now = DateTime(2026, 9, 23, 12);

void main() {
  group('UberParser', () {
    final parser = UberParser();

    test('canParse reconhece texto do Uber', () {
      expect(parser.canParse(_rawText), isTrue);
      expect(parser.canParse('nada a ver aqui'), isFalse);
    });

    test('extrai as 7 corridas do texto de exemplo', () {
      final rides = parser.parse(_rawText, now: _now);
      expect(rides, hasLength(7));
    });

    test('corrida 1: Uber X completa com surge', () {
      final ride = parser.parse(_rawText, now: _now)[0];
      expect(ride.startedAt, DateTime(2026, 6, 5, 18, 43));
      expect(ride.serviceType, 'Uber X');
      expect(ride.status, 'completed');
      expect(ride.fareBrl, 18.92);
      expect(ride.surgeBrl, 2.25);
      expect(ride.tipBrl, isNull);
      expect(ride.durationSeconds, 872);
      expect(ride.distanceKm, 5.87);
      expect(ride.pickupPostalCode, '03317-000');
      expect(ride.destinationPostalCode, '03310-000');
    });

    test('corrida 2: cancelada pelo usuário (rider) sem duração/distância',
        () {
      final ride = parser.parse(_rawText, now: _now)[1];
      expect(ride.startedAt, DateTime(2026, 6, 5, 19, 2));
      expect(ride.serviceType, 'Uber X');
      expect(ride.status, 'cancelled_by_rider');
      expect(ride.fareBrl, 0.0);
      expect(ride.surgeBrl, isNull);
      expect(ride.durationSeconds, isNull);
      expect(ride.distanceKm, isNull);
      expect(ride.pickupPostalCode, '03312-001');
      expect(ride.destinationPostalCode, '03319-000');
    });

    test('corrida 3: Comfort completa com gorjeta (sem surge)', () {
      final ride = parser.parse(_rawText, now: _now)[2];
      expect(ride.startedAt, DateTime(2026, 6, 5, 20, 11));
      expect(ride.serviceType, 'Comfort');
      expect(ride.status, 'completed');
      expect(ride.fareBrl, 12.47);
      expect(ride.surgeBrl, isNull);
      expect(ride.tipBrl, 3.0);
      expect(ride.durationSeconds, 588);
      expect(ride.distanceKm, 3.0);
    });

    test('corrida 4: distância com ponto decimal (11.4 km)', () {
      final ride = parser.parse(_rawText, now: _now)[3];
      expect(ride.startedAt, DateTime(2026, 6, 6, 8, 17));
      expect(ride.serviceType, 'Uber Flash');
      expect(ride.fareBrl, 34.9);
      expect(ride.durationSeconds, 1335);
      expect(ride.distanceKm, 11.4);
    });

    test('corrida 5: Uber Moto com surge e gorjeta juntos', () {
      final ride = parser.parse(_rawText, now: _now)[4];
      expect(ride.startedAt, DateTime(2026, 6, 6, 13, 54));
      expect(ride.serviceType, 'Uber Moto');
      expect(ride.fareBrl, 27.35);
      expect(ride.surgeBrl, 1.5);
      expect(ride.tipBrl, 4.0);
      expect(ride.durationSeconds, 1089);
      expect(ride.distanceKm, 8.6);
    });

    test('corrida 6: cancelada pelo motorista, pickup == destino', () {
      final ride = parser.parse(_rawText, now: _now)[5];
      expect(ride.startedAt, DateTime(2026, 6, 6, 23, 41));
      expect(ride.serviceType, 'Uber Pet');
      expect(ride.status, 'cancelled_by_driver');
      expect(ride.fareBrl, 0.0);
      expect(ride.pickupPostalCode, '04010-100');
      expect(ride.destinationPostalCode, '04010-100');
    });

    test('corrida 7: Uber Black completa, separador "-"', () {
      final ride = parser.parse(_rawText, now: _now)[6];
      expect(ride.startedAt, DateTime(2026, 6, 6, 23, 58));
      expect(ride.serviceType, 'Uber Black');
      expect(ride.fareBrl, 42.9);
      expect(ride.surgeBrl, 6.5);
      expect(ride.tipBrl, 10.0);
      expect(ride.durationSeconds, 1304);
      expect(ride.distanceKm, 11.2);
      expect(ride.pickupPostalCode, '04551-060');
      expect(ride.destinationPostalCode, '01310-100');
    });

    test('rawOcrText preserva as linhas originais da corrida', () {
      final ride = parser.parse(_rawText, now: _now)[0];
      expect(ride.rawOcrText, contains('R\$ 18,92'));
      expect(ride.rawOcrText, contains('Uber X • 14 min 32 seg • 5,87 km'));
    });

    test('texto sem nenhuma corrida retorna lista vazia', () {
      expect(parser.parse('', now: _now), isEmpty);
      expect(parser.parse('Uber sem mais nada', now: _now), isEmpty);
    });

    group('serviço · duração · distância quebrado em 2 linhas de OCR', () {
      // Reproduz a tela "Histórico de ganhos" real do Uber (com
      // mapinha), onde o texto embrulha em telas estreitas e o ML Kit
      // devolve isso como duas linhas de OCR em vez de uma. A regra é:
      // só tenta juntar linha atual + próxima quando ainda não achou o
      // serviço desta corrida — senão a tentativa de junção roda de
      // novo pra endereço/tarifa da próxima corrida e pode bater com o
      // regex por acidente, misturando dados de corridas diferentes.
      final now = DateTime(2026, 9, 24, 12);

      const rawText = '''
sáb., 19 de set.

R\$ 27,59

Prioridade · 19 min 43 segundos ·
10.08 km

3:41

Butantã Shopping Av. Prof. Francisco Morato, Butantã - São Paulo - SP, 05512-300, Brasil

Rua Vicente Amato, Campo Limpo - São Paulo - SP, 05794-390, Brasil

R\$ 12,98

Uber X · 5 min 30 segundos · 4.02
km

3:39

Rod. Raposo Tavares, Jardim Boa Vista - São Paulo - SP, 05576-100, Brasil

Avenida Imigrante Japones, Vila Sônia - São Paulo - SP, 05521-000, Brasil
''';

      test('as 2 corridas são extraídas mesmo com a linha quebrada', () {
        final rides = parser.parse(rawText, now: now);
        expect(rides, hasLength(2));
      });

      test('quebra logo após o separador ("· 19 min 43 segundos ·" '
          '/ "10.08 km")', () {
        final ride = parser.parse(rawText, now: now)[0];
        expect(ride.serviceType, 'Prioridade');
        expect(ride.fareBrl, 27.59);
        expect(ride.durationSeconds, 1183);
        expect(ride.distanceKm, 10.08);
        expect(ride.startedAt, DateTime(2026, 9, 19, 3, 41));
        expect(ride.pickupPostalCode, '05512-300');
        expect(ride.destinationPostalCode, '05794-390');
      });

      test('quebra no meio do valor, antes da unidade '
          '("· 4.02" / "km")', () {
        final ride = parser.parse(rawText, now: now)[1];
        expect(ride.serviceType, 'Uber X');
        expect(ride.fareBrl, 12.98);
        expect(ride.durationSeconds, 330);
        expect(ride.distanceKm, 4.02);
        expect(ride.startedAt, DateTime(2026, 9, 19, 3, 39));
      });
    });

    group('OCR real do celular (tela "Histórico de ganhos" com mapa)', () {
      // Texto reconstruído a partir de um print real, na ordem visual
      // correta (o fix de MlKitTextRecognizerService ordena por posição
      // Y antes de virar string) — mas mantendo os erros de OCR que
      // apareceram de verdade: separador sumido ("Uber X5 min" sem
      // nada entre X e 5), "segundos" lido como "sequndos", o badge
      // "↑ Aumentou" colado na mesma linha da tarifa, e rótulos de
      // bairro/rodovia do mapa intercalados entre os campos.
      final now = DateTime(2026, 9, 25, 12);

      const rawText = '''
sáb., 19 de set.

R\$ 27,59

Prioridade- 19 min 43 sequndos
10.08 km

3:41

rocaba-
250

Butantá Shopping Av. Prof. Francisco Morato,
Butantä - São Paulo - SP 05512-300, Brasil

Rua Vicente Amato, Campo Limpo - São Paulo -S
05794-390, Brasil

R\$ 12,98

Uber X5 min 30 sequndos 4.02
km

3:39

cÒNJUNTO
PROMORAR-
RAPOso
TẦV A RES
021

Rod. Raposo Tavares, Jardim Boa Vista - São Paulc
SP. 05576-100, Brasil

Avenida Imigrante Japones, Vila Sônia - São Paulc
SP, 05521-000, Brasil

R\$ 38,73 ↑ Aumentou

Uber X 27 min 53 sequndos
21.03 km

2:59

Cotia
Embu das Artes
Itapecerièa da Serra

Rua Taquaruçu, Jabaquara - São Paulo - SP,
04346-040, Brasil

R. Eusébio de Paula Marcondes, Rio Pequeno - Sãc
Paulo - SP, 05398-020, Brasil
''';

      test('extrai as 3 corridas apesar do ruído e dos erros de OCR', () {
        final rides = parser.parse(rawText, now: now);
        expect(rides, hasLength(3));
      });

      test('separador sumido entre serviço e duração ("Uber X5 min")', () {
        final ride = parser.parse(rawText, now: now)[1];
        expect(ride.serviceType, 'Uber X');
        expect(ride.fareBrl, 12.98);
        expect(ride.durationSeconds, 330);
        expect(ride.distanceKm, 4.02);
        expect(ride.pickupPostalCode, '05576-100');
        expect(ride.destinationPostalCode, '05521-000');
      });

      test('"segundos" lido como "sequndos" não trava o match', () {
        final ride = parser.parse(rawText, now: now)[0];
        expect(ride.serviceType, 'Prioridade');
        expect(ride.durationSeconds, 1183);
      });

      test('badge "↑ Aumentou" colado na linha da tarifa', () {
        final ride = parser.parse(rawText, now: now)[2];
        expect(ride.fareBrl, 38.73);
        expect(ride.serviceType, 'Uber X');
        expect(ride.durationSeconds, 1673);
        expect(ride.distanceKm, 21.03);
      });

      test('ruído de rótulo de mapa entre os campos não é confundido '
          'com corrida', () {
        final rides = parser.parse(rawText, now: now);
        expect(rides.map((r) => r.serviceType),
            everyElement(isNot(contains('CONJUNTO'))));
      });
    });

    group('OCR real do celular (horário ANTES da linha de serviço)', () {
      // Segundo print real do usuário: com o fix de ordenação por
      // posição Y, o horário passou a aparecer numa linha própria logo
      // após a tarifa — ANTES de serviço/duração/distância — em vez de
      // depois (caso já coberto pelo grupo acima). Sem tratar essa
      // ordem, o horário nunca era capturado e nenhuma corrida entrava
      // no resultado ("0 corridas encontradas").
      final now = DateTime(2026, 9, 25, 12);

      const rawText = '''
sex., 18 de set.

R\$ 22,40

3:15

Uber X · 14 min 20 segundos · 6.7 km

Jardim das Flores, Rua Aurora,
04567-120, Brasil

Vila Nova, Rua das Palmeiras,
04890-050, Brasil

R\$ 18,90

3:02

Uber X · 11 min 5 segundos · 5.2 km

Centro, Rua XV de Novembro,
01013-000, Brasil

Bela Vista, Rua Bela Cintra,
01415-000, Brasil
''';

      test('extrai as 2 corridas com horário antes da linha de serviço', () {
        final rides = parser.parse(rawText, now: now);
        expect(rides, hasLength(2));
      });

      test('corrida 1: horário, serviço e tarifa corretos', () {
        final ride = parser.parse(rawText, now: now)[0];
        expect(ride.startedAt, DateTime(2026, 9, 18, 3, 15));
        expect(ride.serviceType, 'Uber X');
        expect(ride.fareBrl, 22.40);
        expect(ride.durationSeconds, 860);
        expect(ride.distanceKm, 6.7);
        expect(ride.pickupPostalCode, '04567-120');
        expect(ride.destinationPostalCode, '04890-050');
      });

      test('corrida 2: horário, serviço e tarifa corretos', () {
        final ride = parser.parse(rawText, now: now)[1];
        expect(ride.startedAt, DateTime(2026, 9, 18, 3, 2));
        expect(ride.serviceType, 'Uber X');
        expect(ride.fareBrl, 18.90);
        expect(ride.durationSeconds, 665);
        expect(ride.distanceKm, 5.2);
        expect(ride.pickupPostalCode, '01013-000');
        expect(ride.destinationPostalCode, '01415-000');
      });
    });
  });
}
