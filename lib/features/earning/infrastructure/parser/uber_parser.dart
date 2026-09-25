import 'package:driver_analytics_app/features/earning/infrastructure/parser/parsed_ride.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_parser.dart';

/// Porta em Dart de `app/services/parser/uber_parser.py` (backend Python,
/// branch `develop`) — mesmo texto de entrada (extraído pelo ML Kit),
/// mesmas regras de extração.
class UberParser implements RideParser {
  // Sem `$` no fim: o Uber às vezes cola um badge (“↑ Aumentou”) na
  // mesma linha da tarifa. O lookahead negativo evita casar a própria
  // linha de dinâmico/gorjeta ("R$ 2,25 Preço dinâmico"), que também
  // começa com "R$ X,XX".
  static final RegExp _reFare =
      RegExp(r'^R\$\s+(\d+[.,]\d{2})(?!\s*(?:Preço|Valor))');

  static final RegExp _reSurge = RegExp(
    r'^R\$\s*(\d+[.,]\d{2})\s+Preço\s+dinâmico',
    caseSensitive: false,
  );

  static final RegExp _reTip = RegExp(
    r'^R\$\s*(\d+[.,]\d{2})\s+Valor\s+extra',
    caseSensitive: false,
  );

  /// Padrão usado duas vezes dentro de [_reService] (antes e depois da
  /// duração) — mantido inline nos dois lugares porque interpolar um
  /// `const` dentro de uma raw string (`r'...'`) não funciona, e trocar
  /// pra string normal exigiria escapar `\d`/`\s` manualmente no resto
  /// do padrão.
  ///
  /// O separador (·/•/-/*/.) e os espaços ao redor dele são opcionais —
  /// no OCR real do Uber ele às vezes some (“Uber X5 min 30 seg…”, sem
  /// nada entre “X” e “5”) ou vira um ponto (“Uber X . 48 min”). A
  /// palavra depois da duração usa `[^\d\s]+` (qualquer coisa que não
  /// seja dígito/espaço) em vez de exigir "segundos"/"segs"
  /// literalmente, porque o OCR ocasionalmente lê "segundos" como
  /// "sequndos" (g→q) — não dá pra prever todo erro de caractere,
  /// então não trava nisso. Precisa ser `[^\d\s]+` e não `\S+`: `\S+`
  /// também casa dígitos, então quando não há espaço antes da distância
  /// (“sequndos·8.11”) ele invade os dígitos por backtracking e captura
  /// só o último caractere como distância (“8.11” virava “1”).
  ///
  /// Os grupos numéricos aceitam `l`/`I` além de dígitos — o OCR
  /// ocasionalmente lê "1" como letra minúscula/maiúscula ("2l min",
  /// "1l min"); `_normalizeDigits` converte de volta antes de fazer o
  /// parse. O "km" no fim é opcional: em alguns prints reais essa
  /// palavra some inteiramente do texto reconhecido, e sem isso a
  /// corrida inteira era descartada por só faltar a unidade.
  static final RegExp _reService = RegExp(
    r'^(.+?)\s*(?:·|•|-|\*|\.)?\s*'
    r'(?:([\dlI]+)\s+min\s+([\dlI]+)\s+[^\d\s]+\s*(?:·|•|-|\*|\.)?\s*'
    r'([\dlI]+(?:[.,][\dlI]+)?)\s*(?:km)?'
    r'|(Você cancelou|Cancelado pelo usuário))$',
  );

  static final RegExp _reDate = RegExp(
    r'^(?:seg|ter|qua|qui|sex|sáb|dom)\.,?\s+(\d{1,2})\s+de\s+'
    r'(jan|fev|mar|abr|mai|jun|jul|ago|set|out|nov|dez)\.?$',
    caseSensitive: false,
  );

  static final RegExp _reTime = RegExp(r'\b(\d{1,2}):(\d{2})\b');
  static final RegExp _reCep = RegExp(r'(\d{5}-\d{3})');

  static const _months = {
    'jan': 1,
    'fev': 2,
    'mar': 3,
    'abr': 4,
    'mai': 5,
    'jun': 6,
    'jul': 7,
    'ago': 8,
    'set': 9,
    'out': 10,
    'nov': 11,
    'dez': 12,
  };

  @override
  bool canParse(String rawText) =>
      rawText.contains('Uber') || rawText.contains('Comfort');

  @override
  List<ParsedRide> parse(String rawText, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final rides = <ParsedRide>[];
    (int day, int month)? currentDate;

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];

      final dateMatch = _reDate.matchAsPrefix(line);
      if (dateMatch != null) {
        final day = int.parse(dateMatch.group(1)!);
        final month = _months[dateMatch.group(2)!.toLowerCase()]!;
        currentDate = (day, month);
        i++;
        continue;
      }

      final fareMatch = _reFare.matchAsPrefix(line);
      if (fareMatch != null && currentDate != null) {
        final fareBrl = _parseBrl(fareMatch.group(1)!);

        double? surgeBrl;
        double? tipBrl;
        String? serviceType;
        var status = 'completed';
        int? durationSecs;
        double? distanceKm;
        String? pickupCep;
        String? destCep;
        (int hour, int minute)? rideTime;

        final rawLines = <String>[line];
        i++;

        while (i < lines.length) {
          final l = lines[i];
          rawLines.add(l);

          final surgeMatch = _reSurge.matchAsPrefix(l);
          if (surgeMatch != null) {
            surgeBrl = _parseBrl(surgeMatch.group(1)!);
            i++;
            continue;
          }

          final tipMatch = _reTip.matchAsPrefix(l);
          if (tipMatch != null) {
            tipBrl = _parseBrl(tipMatch.group(1)!);
            i++;
            continue;
          }

          // No print real (após ordenar por posição Y), o horário
          // ("3:41") aparece numa linha própria logo após a tarifa —
          // ANTES da linha de serviço/duração/distância, não depois
          // dela. Sem checar isso aqui, essa linha cai no fallthrough
          // genérico (i++) e o horário nunca é capturado, derrubando a
          // corrida inteira (startedAt fica null).
          if (rideTime == null) {
            final standaloneTimeMatch = _reTime.matchAsPrefix(l);
            if (standaloneTimeMatch != null) {
              rideTime = (
                int.parse(standaloneTimeMatch.group(1)!),
                int.parse(standaloneTimeMatch.group(2)!),
              );
              i++;
              continue;
            }
          }

          // Só tenta achar o serviço enquanto ainda não achou o desta
          // corrida — sem essa guarda, a tentativa de juntar linha atual
          // + próxima (abaixo) roda de novo pra cada linha seguinte
          // (endereço, tarifa da próxima corrida etc.) e pode por
          // coincidência bater com o regex, misturando texto de blocos
          // diferentes.
          var svcMatch = serviceType == null ? _reService.matchAsPrefix(l) : null;
          var svcText = l;
          var svcLinesConsumed = 1;

          // Em telas estreitas o ML Kit às vezes quebra "serviço ·
          // duração · distância" em duas linhas de OCR (o texto era uma
          // frase só na UI, só que embrulhada). Tenta juntar com a
          // próxima linha antes de desistir do match.
          if (serviceType == null && svcMatch == null && i + 1 < lines.length) {
            final joined = '$l ${lines[i + 1]}';
            final joinedMatch = _reService.matchAsPrefix(joined);
            if (joinedMatch != null) {
              svcMatch = joinedMatch;
              svcText = joined;
              svcLinesConsumed = 2;
              rawLines.add(lines[i + 1]);
            }
          }

          // Outro jeito real de quebra: o horário sai intercalado NO
          // MEIO do bloco de serviço — "serviço · duração" numa linha,
          // o horário sozinho na linha seguinte, e só depois a
          // distância (ex.: "Uber X 48 min 29 seg" / "22:01" / "29.44
          // km"). Nem o match de uma linha só nem o join com a linha
          // imediatamente seguinte cobrem isso, porque a linha do meio
          // não faz parte do texto de serviço. Se a linha seguinte for
          // um horário isolado, tenta juntar a atual com a de DUAS
          // linhas à frente (pulando o horário) e guarda esse horário
          // separadamente.
          var skippedTimeMatch = serviceType == null && svcMatch == null && i + 2 < lines.length
              ? _reTime.matchAsPrefix(lines[i + 1])
              : null;
          if (skippedTimeMatch != null) {
            final joined = '$l ${lines[i + 2]}';
            final joinedMatch = _reService.matchAsPrefix(joined);
            if (joinedMatch != null) {
              svcMatch = joinedMatch;
              svcText = joined;
              svcLinesConsumed = 3;
              rawLines.add(lines[i + 1]);
              rawLines.add(lines[i + 2]);
            } else {
              skippedTimeMatch = null;
            }
          }

          if (svcMatch != null) {
            serviceType = svcMatch.group(1)!.trim();
            status = _normalizeStatus(svcMatch.group(5));

            if (status == 'completed') {
              durationSecs =
                  _parseDuration(svcMatch.group(2)!, svcMatch.group(3)!);
              distanceKm = _parseDistance(svcMatch.group(4)!);
            }

            i += svcLinesConsumed;

            if (skippedTimeMatch != null) {
              rideTime ??= (
                int.parse(skippedTimeMatch.group(1)!),
                int.parse(skippedTimeMatch.group(2)!),
              );
            } else if (rideTime == null) {
              Match? timeMatch = _reTime.firstMatch(svcText);

              if (timeMatch == null && i < lines.length) {
                final nextLine = lines[i];
                timeMatch = _reTime.matchAsPrefix(nextLine);
                if (timeMatch != null) {
                  rawLines.add(nextLine);
                  i++;
                }
              }

              if (timeMatch != null) {
                rideTime = (
                  int.parse(timeMatch.group(1)!),
                  int.parse(timeMatch.group(2)!),
                );
              }
            }

            continue;
          }

          final cepMatch = _reCep.firstMatch(l);
          if (cepMatch != null) {
            final cep = cepMatch.group(1)!;
            if (pickupCep == null) {
              pickupCep = cep;
            } else {
              destCep = cep;
            }
            i++;
            continue;
          }

          if (_reFare.matchAsPrefix(l) != null ||
              _reDate.matchAsPrefix(l) != null) {
            break;
          }

          i++;
        }

        DateTime? startedAt;
        if (rideTime != null) {
          final (day, month) = currentDate;
          final year = _inferYear(month, day, effectiveNow);
          if (_isValidDate(year, month, day)) {
            startedAt = DateTime(year, month, day, rideTime.$1, rideTime.$2);
          }
        }

        if (serviceType != null && startedAt != null) {
          rides.add(ParsedRide(
            startedAt: startedAt,
            serviceType: serviceType,
            status: status,
            fareBrl: fareBrl,
            surgeBrl: surgeBrl,
            tipBrl: tipBrl,
            durationSeconds: durationSecs,
            distanceKm: distanceKm,
            pickupPostalCode: pickupCep,
            destinationPostalCode: destCep,
            rawOcrText: rawLines.join('\n'),
          ));
        }

        continue;
      }

      i++;
    }

    return rides;
  }

  static double _parseBrl(String value) =>
      double.parse(value.replaceAll('.', '').replaceAll(',', '.'));

  static int _parseDuration(String minutes, String seconds) =>
      int.parse(_normalizeDigits(minutes)) * 60 +
      int.parse(_normalizeDigits(seconds));

  static double _parseDistance(String value) =>
      double.parse(_normalizeDigits(value).replaceAll(',', '.'));

  /// O OCR ocasionalmente lê "1" como "l" (L minúsculo) ou "I"
  /// (i maiúsculo) — visualmente quase idênticos na fonte do app.
  /// `_reService` aceita esses caracteres nos grupos numéricos
  /// justamente pra não descartar a corrida inteira por causa de um
  /// caractere; aqui eles voltam a ser "1" antes do parse.
  static String _normalizeDigits(String value) =>
      value.replaceAll('l', '1').replaceAll('I', '1');

  static String _normalizeStatus(String? rawStatus) {
    if (rawStatus == null) return 'completed';
    if (rawStatus == 'Você cancelou') return 'cancelled_by_driver';
    if (rawStatus == 'Cancelado pelo usuário') return 'cancelled_by_rider';
    return 'unknown';
  }

  /// Assume que screenshots são recentes: se a data calculada ficar mais de
  /// 30 dias no futuro em relação a `now`, assume que é do ano anterior.
  static int _inferYear(int month, int day, DateTime now) {
    final year = now.year;
    if (!_isValidDate(year, month, day)) {
      return year;
    }
    final candidate = DateTime(year, month, day);
    if (candidate.difference(now).inDays > 30) {
      return year - 1;
    }
    return year;
  }

  static bool _isValidDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1) return false;
    return day <= _daysInMonth(year, month);
  }

  static int _daysInMonth(int year, int month) {
    final firstOfNextMonth = month < 12
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return firstOfNextMonth.subtract(const Duration(days: 1)).day;
  }
}
