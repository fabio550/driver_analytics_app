enum AnalyticsPeriodPreset { week, month, custom }

class AnalyticsPeriod {
  final DateTime start;
  final DateTime end;
  final AnalyticsPeriodPreset preset;

  const AnalyticsPeriod._({
    required this.start,
    required this.end,
    required this.preset,
  });

  /// Semana que contém [anchor], de segunda a segunda.
  factory AnalyticsPeriod.week(DateTime anchor) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    final start = day.subtract(Duration(days: day.weekday - 1));
    return AnalyticsPeriod._(
      start: start,
      end: start.add(const Duration(days: 7)),
      preset: AnalyticsPeriodPreset.week,
    );
  }

  /// Mês que contém [anchor].
  factory AnalyticsPeriod.month(DateTime anchor) {
    return AnalyticsPeriod._(
      start: DateTime(anchor.year, anchor.month),
      end: DateTime(anchor.year, anchor.month + 1),
      preset: AnalyticsPeriodPreset.month,
    );
  }

  /// Intervalo escolhido à mão. [end] é inclusivo na intenção do usuário
  /// ("até dia 20"), então guarda-se o dia seguinte.
  factory AnalyticsPeriod.custom({
    required DateTime start,
    required DateTime end,
  }) {
    return AnalyticsPeriod._(
      start: DateTime(start.year, start.month, start.day),
      end: DateTime(end.year, end.month, end.day).add(const Duration(days: 1)),
      preset: AnalyticsPeriodPreset.custom,
    );
  }

  bool contains(DateTime dateTime) {
    return !dateTime.isBefore(start) && dateTime.isBefore(end);
  }

  /// Período anterior de mesmo tamanho — semana/mês andam pro seu vizinho
  /// natural, custom desliza pela própria duração.
  AnalyticsPeriod get previous => _shifted(-1);

  /// Período seguinte de mesmo tamanho. Ver [previous].
  AnalyticsPeriod get next => _shifted(1);

  AnalyticsPeriod _shifted(int steps) {
    switch (preset) {
      case AnalyticsPeriodPreset.week:
        return AnalyticsPeriod.week(start.add(Duration(days: 7 * steps)));
      case AnalyticsPeriodPreset.month:
        return AnalyticsPeriod.month(DateTime(start.year, start.month + steps));
      case AnalyticsPeriodPreset.custom:
        final span = end.difference(start);
        return AnalyticsPeriod._(
          start: start.add(span * steps),
          end: end.add(span * steps),
          preset: AnalyticsPeriodPreset.custom,
        );
    }
  }
}