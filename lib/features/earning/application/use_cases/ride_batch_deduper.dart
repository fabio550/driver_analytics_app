import 'package:driver_analytics_app/features/earning/infrastructure/parser/parsed_ride.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_service_type_matcher.dart';

/// Uma corrida já reconciliada a partir de 1+ leituras agrupadas — ex.:
/// a mesma corrida OCR'd em vários frames sobrepostos de um vídeo.
class ReconciledRide {
  final ParsedRide ride;

  /// true quando as leituras agrupadas divergiram em algum campo (tarifa,
  /// duração, distância ou CEP) e o valor usado veio de voto de maioria
  /// (3+ leituras com um valor mais frequente) ou, sem maioria clara
  /// (empate, ou só 2 leituras discordando), da primeira leitura — nos
  /// dois casos vale conferir com atenção antes de confirmar.
  final bool hasDivergentReadings;

  const ReconciledRide({required this.ride, required this.hasDivergentReadings});
}

/// Agrupa leituras da mesma corrida vindas do mesmo lote de OCR (um
/// vídeo gera uma leitura independente por frame, e frames vizinhos se
/// sobrepõem) e decide um valor único por campo quando elas divergem.
///
/// A checagem "oficial" de duplicata contra o histórico já salvo
/// continua em `PreviewRideImportUseCase`, por hash exato — isso aqui só
/// evita que o MESMO lote de leituras vire candidatos repetidos, ou
/// perca precisão por causa de ruído de OCR isolado num frame.
///
/// Critério de agrupamento, do mais rígido pro mais solto — a primeira
/// leitura que bater com o representante de um grupo existente entra
/// nele, senão vira grupo novo:
/// 1. Hora + tarifa + CEPs idênticos (equivalente ao hash completo).
/// 2. Hora + tarifa + tipo de serviço idênticos, CEP pode divergir — a
///    linha de endereço é a mais longa e mais sujeita a corte/ruído no
///    frame, então é o primeiro campo a relaxar.
/// 3. Hora + tipo de serviço idênticos, tarifa/duração/distância podem
///    divergir — último nível antes de considerar corrida nova.
class RideBatchDeduper {
  const RideBatchDeduper();

  List<ReconciledRide> reconcile(List<ParsedRide> rides) {
    final groups = <List<ParsedRide>>[];

    for (final ride in rides) {
      final group = _findMatchingGroup(groups, ride);
      if (group != null) {
        group.add(ride);
      } else {
        groups.add([ride]);
      }
    }

    return groups.map(_reconcileGroup).toList();
  }

  List<ParsedRide>? _findMatchingGroup(
    List<List<ParsedRide>> groups,
    ParsedRide ride,
  ) {
    for (final group in groups) {
      final representative = group.first;
      if (_sameByExactFields(representative, ride) ||
          _sameByTimeFareService(representative, ride) ||
          _sameByTimeAndService(representative, ride)) {
        return group;
      }
    }
    return null;
  }

  bool _sameByExactFields(ParsedRide a, ParsedRide b) {
    return a.startedAt == b.startedAt &&
        a.fareBrl == b.fareBrl &&
        a.pickupPostalCode == b.pickupPostalCode &&
        a.destinationPostalCode == b.destinationPostalCode;
  }

  bool _sameByTimeFareService(ParsedRide a, ParsedRide b) {
    return a.startedAt == b.startedAt &&
        a.fareBrl == b.fareBrl &&
        _sameServiceType(a, b);
  }

  bool _sameByTimeAndService(ParsedRide a, ParsedRide b) {
    return a.startedAt == b.startedAt && _sameServiceType(a, b);
  }

  // Compara pelo tipo já normalizado (ex.: "Uber X" e "8 uber X" são o
  // mesmo tipo apesar do ruído de OCR diferente), não pelo texto bruto.
  bool _sameServiceType(ParsedRide a, ParsedRide b) {
    return RideServiceTypeMatcher.match(a.serviceType) ==
        RideServiceTypeMatcher.match(b.serviceType);
  }

  ReconciledRide _reconcileGroup(List<ParsedRide> group) {
    final first = group.first;

    if (group.length == 1) {
      return ReconciledRide(ride: first, hasDivergentReadings: false);
    }

    final fareBrl = _reconcileValues(group.map((r) => r.fareBrl).toList());
    final durationSeconds =
        _reconcileValues(group.map((r) => r.durationSeconds).toList());
    final distanceKm = _reconcileValues(group.map((r) => r.distanceKm).toList());

    final hasDivergentReadings =
        fareBrl.divergent || durationSeconds.divergent || distanceKm.divergent;

    return ReconciledRide(
      ride: ParsedRide(
        startedAt: first.startedAt,
        serviceType: first.serviceType,
        status: first.status,
        fareBrl: fareBrl.value,
        surgeBrl: first.surgeBrl,
        tipBrl: first.tipBrl,
        durationSeconds: durationSeconds.value,
        distanceKm: distanceKm.value,
        pickupPostalCode: _preferNonNull(group.map((r) => r.pickupPostalCode)),
        destinationPostalCode:
            _preferNonNull(group.map((r) => r.destinationPostalCode)),
        rawOcrText: first.rawOcrText,
      ),
      hasDivergentReadings: hasDivergentReadings,
    );
  }

  /// CEP não entra na votação nem conta como divergência — vazio numa
  /// leitura só significa que o endereço foi cortado/ilegível naquele
  /// frame específico, não um valor conflitante de verdade. Fica com a
  /// primeira leitura não nula do grupo, se houver.
  String? _preferNonNull(Iterable<String?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  /// Todas as leituras concordando: usa o valor, sem divergência. Senão,
  /// com 3+ leituras e um valor mais frequente sem empate, esse valor
  /// vence por maioria; em qualquer outro caso (empate, ou só 2
  /// discordando) fica a primeira leitura, e [_Reconciled.divergent]
  /// sinaliza que vale conferir.
  _Reconciled<T> _reconcileValues<T>(List<T> values) {
    if (values.toSet().length == 1) {
      return _Reconciled(value: values.first, divergent: false);
    }

    final counts = <T, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    final maxCount = counts.values.reduce((a, b) => a > b ? a : b);
    final winners = counts.entries.where((e) => e.value == maxCount).toList();

    if (values.length >= 3 && winners.length == 1) {
      return _Reconciled(value: winners.first.key, divergent: true);
    }

    return _Reconciled(value: values.first, divergent: true);
  }
}

class _Reconciled<T> {
  final T value;
  final bool divergent;

  const _Reconciled({required this.value, required this.divergent});
}
