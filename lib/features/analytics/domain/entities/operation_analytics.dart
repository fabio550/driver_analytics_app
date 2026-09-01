/// Quanto do tempo/km ativo teve passageiro dentro vs. disponível esperando
/// ou deslocando. Só existe quando [ShiftCompleteness.isFullyComplete] —
/// ver o comentário em cima dela.
class TimeSplit {
  final Duration withPassenger;
  final Duration available;
  final Duration paused;

  const TimeSplit({
    required this.withPassenger,
    required this.available,
    required this.paused,
  });

  Duration get total => withPassenger + available + paused;
}

class DistanceSplit {
  final double withPassengerKm;
  final double idleKm;

  const DistanceSplit({required this.withPassengerKm, required this.idleKm});

  double get total => withPassengerKm + idleKm;
}

class PaceStats {
  final int rideCount;
  final int completedRideCount;
  final int cancelledRideCount;
  final double? ridesPerActiveHour;
  final double? cancellationRate;
  final Duration? averageRideDuration;
  final double? averageRideDistanceKm;

  const PaceStats({
    required this.rideCount,
    required this.completedRideCount,
    required this.cancelledRideCount,
    required this.ridesPerActiveHour,
    required this.cancellationRate,
    required this.averageRideDuration,
    required this.averageRideDistanceKm,
  });
}

/// Ganho médio por hora de corrida dentro de uma janela de 3h do dia
/// (00–03, 03–06, ...). `amountPerHour` nulo quando não houve corrida
/// concluída na janela no período — vira barra "sem dado", não barra zero.
class HourlyEarningEntry {
  final int startHour;
  final double? amountPerHour;

  const HourlyEarningEntry({required this.startHour, required this.amountPerHour});
}

/// Ranking por bairro de embarque. `districtId` é o valor bruto salvo em
/// [RideEarningEntity.pickupDistrictId] — o app não tem um cadastro de
/// bairros com nome, só o id que a tela de lançamento grava.
class DistrictEntry {
  final String districtId;
  final double revenue;
  final double distanceKm;
  final Duration duration;
  final int rideCount;

  const DistrictEntry({
    required this.districtId,
    required this.revenue,
    required this.distanceKm,
    required this.duration,
    required this.rideCount,
  });

  double? get revenuePerKm => distanceKm > 0 ? revenue / distanceKm : null;

  double? get revenuePerHour {
    final hours = duration.inSeconds / 3600;
    return hours > 0 ? revenue / hours : null;
  }
}

/// §checksum: quando a jornada tem lançamentos, a soma deles precisa bater
/// com o valor declarado ao finalizar — senão falta (ou sobra) lançamento.
/// Jornada sem nenhum lançamento é trivialmente completa (cai no valor
/// declarado, não há o que reconciliar).
class ShiftCompleteness {
  final int totalShifts;
  final int completeShifts;

  /// Soma do módulo da diferença (declarado - lançado) nas jornadas
  /// incompletas. Nulo quando tudo fecha.
  final double? missingAmount;

  const ShiftCompleteness({
    required this.totalShifts,
    required this.completeShifts,
    this.missingAmount,
  });

  static const empty = ShiftCompleteness(totalShifts: 0, completeShifts: 0);

  bool get isFullyComplete => totalShifts == 0 || completeShifts == totalShifts;
}

/// Bloco "Operação". Tempo total/ativo/pausado vem só da jornada e aparece
/// sempre; o resto (splits, ritmo, hora a hora, bairros) só quando
/// [completeness] fecha — ver rail item 3 do design: o app avisa quanto
/// falta em vez de mostrar número que pode estar errado.
class OperationAnalytics {
  final Duration totalTime;
  final Duration activeTime;
  final Duration pausedTime;
  final double totalDistanceKm;
  final ShiftCompleteness completeness;
  final TimeSplit? timeSplit;
  final DistanceSplit? distanceSplit;
  final PaceStats? pace;
  final List<HourlyEarningEntry>? hourlyEarnings;
  final List<DistrictEntry>? districts;

  const OperationAnalytics({
    required this.totalTime,
    required this.activeTime,
    required this.pausedTime,
    required this.totalDistanceKm,
    required this.completeness,
    this.timeSplit,
    this.distanceSplit,
    this.pace,
    this.hourlyEarnings,
    this.districts,
  });

  static const empty = OperationAnalytics(
    totalTime: Duration.zero,
    activeTime: Duration.zero,
    pausedTime: Duration.zero,
    totalDistanceKm: 0,
    completeness: ShiftCompleteness.empty,
  );

  bool get hasDetail => timeSplit != null;

  bool get isEmpty => completeness.totalShifts == 0;
}
